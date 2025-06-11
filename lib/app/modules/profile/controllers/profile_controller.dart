import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  final isLoading = false.obs;
  final isCurrentUser = false.obs;
  RxBool hasNetwork = true.obs;

  var currentUser = Rxn<UserModel>();
  var viewedUser = Rxn<UserModel>();

  final isLogined = false.obs;

  var post = <PostModel>[].obs;

  late Box<UserModel> userBox;

  @override
  void onInit() async {
    super.onInit();
  }

  @override
  void onReady() async {
    super.onReady();
    await reload();
    print('currentUser: ${currentUser.value}');
    print('currentUser.id: ${currentUser.value?.id}');
    print('viewedUser: ${viewedUser.value}');
  }

  Future<bool> checkNetworkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      hasNetwork.value = false;
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasNetwork.value = true;
        return true;
      } else {
        hasNetwork.value = false;
        return false;
      }
    } on SocketException {
      hasNetwork.value = false;
      return false;
    }
  }


  Future<void> reload() async {
    isLoading.value = true;

    final idStr = Get.parameters['id'];
    final routeUserId = int.tryParse(idStr ?? '');

    await loadCurrentUserFromHive();

    final self = currentUser.value;

    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Vui lòng kiểm tra kết nối mạng");
      isLoading.value = false;
      return;
    }

    if (routeUserId != null) {
      // Xem người khác (hoặc bản thân thông qua ID)
      final selfId = int.tryParse(self?.id ?? '');
      final isSelf = selfId != null && selfId == routeUserId;
      isCurrentUser.value = isSelf;

      await initProfile(routeUserId);
    } else {
      // Xem chính mình
      isCurrentUser.value = true;
      if (self != null && self.id != null) {
        final selfId = int.tryParse(self.id!);
        if (selfId != null) {
          viewedUser.value = self;
          await fetchPostsByUser(selfId);
        } else {
          print('ID của currentUser không hợp lệ');
        }
      } else {
        print('Không có thông tin currentUser');
      }
    }

    isLoading.value = false;
  }




  Future<void> initProfile(int? userId) async {
    if (userId == null || userId <= 0) {
      print('Không có ID hợp lệ để tải profile');
      return;
    }

    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Không thể tải dữ liệu người dùng");
      return;
    }

    try {
      final user = await getUser(userId);
      viewedUser.value = user;

      final selfId = int.tryParse(currentUser.value?.id ?? '');
      isCurrentUser.value = selfId != null && user.id == selfId;
    } catch (e) {
      print('Lỗi khi lấy dữ liệu người dùng từ Supabase: $e');
    }

    await fetchPostsByUser(userId);
  }



  // void checkIsCurrentUser(int userId) {
  //   final user = currentUser.value;
  //   if (user != null && user.id != null) {
  //     isCurrentUser.value = int.parse(user.id!) == userId;
  //   } else {
  //     isCurrentUser.value = false;
  //   }
  // }

  //load user from Hive
  Future<void> loadCurrentUserFromHive() async {
    final box = await Hive.openBox<UserModel>('users');
    final user = box.get('current_user');
    if (user != null) {
      currentUser.value = user;
      isLogined.value = true;
      print('Đã tải UserModel từ Hive: ${user.id}');
    } else {
      print('Không tìm thấy current_user trong Hive');
    }
  }

  Future<UserModel> getUser(int userId) async {
    if (!await checkNetworkConnection()) {
      throw Exception("Không có kết nối mạng");
    }
    isLoading.value = true;
    try {
      final response = await Supabase.instance.client
          .from("users")
          .select()
          .eq("id", userId)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromJson(response);
      } else {
        throw Exception("No user found with id: $userId");
      }
    } catch (e) {
      print("Error while taking user: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> getAllPostsByCurrentUser(int userId) async {
    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Không thể tải bài viết");
      return;
    }

    try {

      final response = await Supabase.instance.client
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      post.value = (response as List).map((post) => PostModel(
        id: post['id'],
        created_at: DateTime.parse(post['created_at']),
        edited_at: DateTime.parse(post['edited_at']),
        name: post['name'],
        description: post['description'],
        url: post['url'],
        status: post['status'],
        user_id: post['user_id'],
        views: post['views'],
        thumbnail: post['thumbnail'],
      )).toList();
    } catch (e) {
      print("Error when getting post: $e");
      post.value = [];
    }
  }

  Future<void> fetchPostsByUser(int userId) async {
    await getAllPostsByCurrentUser(userId);
  }


  Future<void> signInWithGoogleAndSaveToSupabase() async {
    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Không thể đăng nhập khi offline");
      return;
    }
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception("Người dùng đã huỷ đăng nhập");

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception("Không lấy được người dùng");
      if (user.email == null) throw Exception("Email người dùng không tồn tại");

      final supabase = Supabase.instance.client;

      final existingUser = await supabase
          .from('users')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      late Map<String, dynamic> userData;

      if (existingUser == null) {
        userData = {
          'name': user.displayName ?? '',
          'email': user.email!,
          'bio': 'This is bio.',
          'avatar_url': user.photoURL ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'edited_at': DateTime.now().toIso8601String(),
        };

        final insertResponse = await supabase.from('users').insert(userData).select().single();

        if (insertResponse == null) throw Exception("Không tạo được user mới");

        userData = Map<String, dynamic>.from(insertResponse);
      } else {
        userData = Map<String, dynamic>.from(existingUser);
        userData['avatar_url'] = user.photoURL ?? existingUser['avatar_url'];
        userData['edited_at'] = DateTime.now().toIso8601String();

        await supabase
            .from('users')
            .update({
          // 'avatar_url': userData['avatar_url'],
          'edited_at': userData['edited_at'],
        })
            .eq('email', user.email!);
      }

      userData = await supabase.from('users').select().eq('email', user.email!).single();

      final box = await Hive.openBox<UserModel>('users');
      final userModel = UserModel.fromJson(userData);
      await box.put('current_user', userModel);
      isLogined.value = true;
      await initProfile(null);
      print('Đã lưu UserModel vào Hive: ${userModel.toJson()}');

      Get.snackbar("Log in successfully", "Hello ${userModel.name}");
      await reload();
    } catch (e) {
      Get.snackbar("Login error", e.toString());
      print("Lỗi đăng nhập: $e");
    }
  }

  Future<void> signOutGoogleAndClearHive() async {
    try {
      // Đăng xuất khỏi Google
      await GoogleSignIn().signOut();

      // Đăng xuất Firebase
      await FirebaseAuth.instance.signOut();

      // Xoá user trong Hive
      final box = await Hive.openBox<UserModel>('users');
      await box.delete('current_user');
      currentUser.value = null;
      viewedUser.value = null;
      isLogined.value = false;
      print('Đã xoá current_user khỏi Hive');
      // Get.toNamed('/layout');
      Get.snackbar("Sign out", "You have successfully logged out.");
    } catch (e) {
      Get.snackbar("Logout error", e.toString());
      print("Lỗi đăng xuất: $e");
    }
  }

  void showEditProfileDialog({
    required String id,
    required String name,
    required String bio,
    required String? avatarUrl,
    required void Function() onUpdated,
  }) {
    final nameController = TextEditingController(text: name);
    final bioController = TextEditingController(text: bio);
    File? avatarFile;

    Get.dialog(
      barrierDismissible:
      false,
      AlertDialog(
        title: const Text('Edit your profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.single.path != null) {
                    avatarFile = File(result.files.single.path!);
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  avatarFile != null ? FileImage(avatarFile!) : (avatarUrl != null ? NetworkImage(avatarUrl) : null) as ImageProvider?,
                  child: avatarUrl == null && avatarFile == null
                      ? const Icon(Icons.camera_alt)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!await checkNetworkConnection()) {
                Get.snackbar("No Internet", "Không thể cập nhật khi offline");
                return;
              }
              final editedAt = DateTime.now().toIso8601String();
              String? newAvatarUrl = avatarUrl;

              if (avatarFile != null) {
                final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
                await Supabase.instance.client.storage
                    .from('users/avatar')
                    .upload(fileName, avatarFile!, fileOptions: const FileOptions(upsert: true));
                newAvatarUrl = Supabase.instance.client.storage
                    .from('users/avatar')
                    .getPublicUrl(fileName);
              }

              await Supabase.instance.client.from('users').update({
                'name': nameController.text,
                'bio': bioController.text,
                'edited_at': editedAt,
                if (newAvatarUrl != avatarUrl) 'avatar_url': newAvatarUrl,
              }).eq('id', id);

              onUpdated();
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

}
