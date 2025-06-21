import 'dart:convert';
import 'dart:io';

import 'package:calliope/app/data/models/drawmodels/frame_model.dart';
import 'package:calliope/app/data/models/drawmodels/layer_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/drawmodels/draw_project_model.dart';
import '../../../data/models/drawmodels/drawn_line_model.dart';
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
  final SupabaseClient client = Supabase.instance.client;

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
      Get.snackbar("No Internet", "Please check your network connection");
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
          if (kDebugMode) {
            print('ID của currentUser không hợp lệ');
          }
        }
      } else {
        if (kDebugMode) {
          print('Không có thông tin currentUser');
        }
      }
    }

    isLoading.value = false;
  }




  Future<void> initProfile(int? userId) async {
    if (userId == null || userId <= 0) {
      if (kDebugMode) {
        print('Không có ID hợp lệ để tải profile');
      }
      return;
    }

    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Unable to load user data");
      return;
    }

    try {
      final user = await getUser(userId);
      viewedUser.value = user;

      final selfId = int.tryParse(currentUser.value?.id ?? '');
      isCurrentUser.value = selfId != null && user.id == selfId;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khi lấy dữ liệu người dùng từ Supabase: $e');
      }
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
      if (kDebugMode) {
        print('Đã tải UserModel từ Hive: ${user.id}');
      }
    } else {
      if (kDebugMode) {
        print('Không tìm thấy current_user trong Hive');
      }
    }
  }

  Future<UserModel> getUser(int userId) async {
    if (!await checkNetworkConnection()) {
      throw Exception("No Internet connection");
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
      Get.snackbar("No Internet", "Unable to load article");
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
      if (kDebugMode) {
        print("Error when getting post: $e");
      }
      post.value = [];
    }
  }

  Future<void> fetchPostsByUser(int userId) async {
    await getAllPostsByCurrentUser(userId);
  }



  Future<void> signInWithGoogleAndSaveToSupabase() async {
    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Cannot login while offline");
      return;
    }
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception("User cancelled the login");

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception("User not found");
      if (user.email == null) throw Exception("Email user not exist");

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

        if (insertResponse == null) throw Exception("Failed to create new user in Supabase");

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
      if (kDebugMode) {
        print('Đã lưu UserModel vào Hive: ${userModel.toJson()}');
      }

      Get.snackbar("Log in successfully", "Hello ${userModel.name}");
      await reload();
    } catch (e) {
      Get.snackbar("Login error", e.toString());
      if (kDebugMode) {
        print("Lỗi đăng nhập: $e");
      }
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
      if (kDebugMode) {
        print('Đã xoá current_user khỏi Hive');
      }
      // Get.toNamed('/layout');
    } catch (e) {
      Get.snackbar("Logout error", e.toString());
      if (kDebugMode) {
        print("Lỗi đăng xuất: $e");
      }
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
                Get.snackbar("No Internet", "Cannot update while offline");
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

              // Cập nhật lại thông tin người dùng trong Hive từ Supabase
              final updatedUser = await Supabase.instance.client
                  .from('users')
                  .select()
                  .eq('id', id)
                  .single();
              final box = await Hive.openBox<UserModel>('users');
              await box.put('current_user', UserModel.fromJson(updatedUser));
              currentUser.value = UserModel.fromJson(updatedUser);
              viewedUser.value = currentUser.value;
              Get.back();
              Get.snackbar("Profile updated", "Your profile has been updated successfully.");
              if (kDebugMode) {
                print("Đã cập nhật thông tin người dùng: ${currentUser.value?.toJson()}");
              }

            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> updateStatus({
    required int id,
    required int status,
  }) async {
    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Cannot delete posts when offline");
      return;
    }
    final editedAt = DateTime.now().toIso8601String();
    await client
        .from('posts')
        .update({
      'status': status,
      'edited_at': editedAt,
    })
        .eq('id', id);
    await reload();
  }

  Future<void> deletePost({
    required int id,
  }) async {
    if (!await checkNetworkConnection()) {
      Get.snackbar("No Internet", "Cannot delete posts when offline");
      return;
    }

    try {
      // Xóa record trong table
      await client.from('posts').delete().eq('id', id);
      Get.snackbar("Success", "The post has been deleted.");
      await reload();
    } catch (e) {
      Get.snackbar("Error", "Unable to delete post: $e");
      if (kDebugMode) {
        print("Lỗi khi xóa bài viết: $e");
      }
    }
  }

  Future<void> confirmDeletePost(int id) async {
    Get.defaultDialog(
      title: 'Confirm',
      middleText: 'Are you sure you want to delete this post?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onError,
      onConfirm: () async {
        Get.back();
        await deletePost(id: id);
      },
    );
  }



  void showStatusOptionsDialog(post) {
    Get.defaultDialog(
      title: 'Choose action',
      content: Column(
        children: [
          ListTile(
            leading: Icon(Icons.delete, color: Get.theme.colorScheme.error),
            title: Text('Delete posts'),
            onTap: () async {
              Get.back();
              await confirmDeletePost(post.id);
            },
          ),
          post.status == 1
              ? ListTile(
            leading: Icon(Icons.lock),
            title: Text('Switch to private'),
            onTap: () async {
              await updateStatus(id: post.id, status: 0);
              Get.back();
              Get.snackbar("Success", "The post has been set to private.");
            },
          )
              : ListTile(
            leading: Icon(Icons.visibility),
            title: Text('Switch to public'),
            onTap: () async {
              await updateStatus(id: post.id, status: 1);
              Get.back();
            },
          )
        ],
      ),
    );
  }

  ////dropdown to show logout options
  void showSettingsOptions() {
    Get.defaultDialog(
      title: 'Settings',
      content: Column(
        children: [
          isLogined.value
          ? ListTile(
              leading: Icon(Icons.logout, color: Get.theme.colorScheme.error),
              title: Text('Sign out'),
              onTap: () async {
                Get.back();
                Get.defaultDialog(
                  title: 'Confirm',
                  middleText: 'Are you sure you want to sign out?',
                  textConfirm: 'Sign out',
                  textCancel: 'Cancel',
                  confirmTextColor: Get.theme.colorScheme.onError,
                  onConfirm: () async {
                    await signOutGoogleAndClearHive();
                    Get.back();
                    Get.snackbar("Sign out", "You have successfully logged out.");
                  },
                );
              },
            )
          : const SizedBox.shrink(),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup data'),
            onTap: () async {
              Get.back();
              await exportAll();
            },
          ),
          ListTile(
            leading: Icon(Icons.restore),
            title: Text('Restore data'),
            onTap: () async {
              Get.back();
              await importAll();
            },
          ),
        ],
      ),
    );
  }

  Future<void> exportAllHiveData(String filePath) async {
    final Map<String, dynamic> exportData = {};

    await checkOpenBox();

    final drawProjectBox = Hive.box<DrawProjectModel>('draw_project');
    final frameBox = Hive.box<FrameModel>('frameModel');
    final layerBox = Hive.box<LayerModel>('layerModel');
    final lineBox = Hive.box<DrawnLine>('drawnLine');

    exportData['drawProjectModel'] = drawProjectBox.toMap().map((key, value) => MapEntry(key.toString(), value));
    exportData['frameModel'] = frameBox.toMap().map((key, value) => MapEntry(key.toString(), value));
    exportData['layerModel'] = layerBox.toMap().map((key, value) => MapEntry(key.toString(), value));
    exportData['drawnLine'] = lineBox.toMap().map((key, value) => MapEntry(key.toString(), value));

    final file = File(filePath);
    await file.writeAsString(jsonEncode(exportData));
  }

  Future<void> exportAll() async {
    // Xin quyền truy cập bộ nhớ
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      print('❌ Không có quyền lưu file');
      return;
    }

    final fileNameController = TextEditingController(text: 'calliope_backup');

    await Get.defaultDialog(
      title: 'Đặt tên file',
      barrierDismissible: false,
      content: Column(
        children: [
          const Text('Nhập tên file:'),
          const SizedBox(height: 8),
          TextField(
            controller: fileNameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          final rawName = fileNameController.text.trim();
          if (rawName.isEmpty) {
            Get.snackbar('Lỗi', 'Tên file không được để trống');
            return;
          }

          final fileName = rawName.endsWith('.json') ? rawName : '$rawName.json';

          Get.back(); // Đóng dialog

          final dir = await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOWNLOAD);
          final filePath = '$dir/$fileName';

          await exportAllHiveData(filePath);

          Get.defaultDialog(
            title: 'Backup successful',
            middleText: 'Your projects has been exported to:\n$filePath',
            confirm: ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          );
          print('✅ Đã lưu file tại: $filePath');
        },
        child: const Text('Lưu'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Hủy'),
      ),
    );
  }



  Future<bool> requestStoragePermission() async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    final status = await Permission.manageExternalStorage.request();

    if (status.isGranted) return true;

    // Mở cài đặt nếu bị từ chối
    await openAppSettings();
    return false;
  }

  Future<void> checkOpenBox() async {
    // Mở các box cần thiết
    if (!Hive.isBoxOpen('draw_project')) {
      await Hive.openBox<DrawProjectModel>('draw_project');
    }
    if (!Hive.isBoxOpen('frameModel')) {
      await Hive.openBox<FrameModel>('frameModel');
    }
    if (!Hive.isBoxOpen('layerModel')) {
      await Hive.openBox<LayerModel>('layerModel');
    }
    if (!Hive.isBoxOpen('drawnLine')) {
      await Hive.openBox<DrawnLine>('drawnLine'); // ✅ đúng kiểu
    }
  }

  Future<void> importAllHiveData(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception("❌ File không tồn tại: $filePath");
    }

    late Map<String, dynamic> jsonData;

    try {
      final contents = await file.readAsString();
      jsonData = jsonDecode(contents);
    } catch (e) {
      throw Exception("❌ File không hợp lệ hoặc không phải định dạng JSON.\nChi tiết: $e");
    }

    // Kiểm tra các khóa bắt buộc
    final requiredKeys = ['drawProjectModel', 'frameModel', 'layerModel', 'drawnLine'];
    for (var key in requiredKeys) {
      if (!jsonData.containsKey(key)) {
        throw Exception("❌ File thiếu dữ liệu: '$key'");
      }
    }

    await checkOpenBox();

    final drawProjectBox = Hive.box<DrawProjectModel>('draw_project');
    final frameBox = Hive.box<FrameModel>('frameModel');
    final layerBox = Hive.box<LayerModel>('layerModel');
    final lineBox = Hive.box<DrawnLine>('drawnLine');

    // Xóa dữ liệu cũ
    await drawProjectBox.clear();
    await frameBox.clear();
    await layerBox.clear();
    await lineBox.clear();

    try {
      for (var entry in (jsonData['drawProjectModel'] as Map<String, dynamic>).entries) {
        final obj = DrawProjectModel.fromJson(entry.value);
        await drawProjectBox.put(entry.key, obj);
      }

      for (var entry in (jsonData['frameModel'] as Map<String, dynamic>).entries) {
        final obj = FrameModel.fromJson(entry.value);
        await frameBox.put(entry.key, obj);
      }

      for (var entry in (jsonData['layerModel'] as Map<String, dynamic>).entries) {
        final obj = LayerModel.fromJson(entry.value);
        await layerBox.put(entry.key, obj);
      }

      for (var entry in (jsonData['drawnLine'] as Map<String, dynamic>).entries) {
        final obj = DrawnLine.fromJson(entry.value);
        await lineBox.put(entry.key, obj);
      }
    } catch (e) {
      throw Exception("❌ Lỗi khi phân tích hoặc ghi dữ liệu Hive.\nChi tiết: $e");
    }
  }


  Future<void> importAll() async {
    try {
      bool isCancel = false;
      //Mở dialog cảnh báo
      await Get.defaultDialog(
        title: 'Warning',
        middleText: 'This will overwrite all your current projects. Are you sure?',
        confirm: ElevatedButton(
          onPressed: () {
            Get.back();
            isCancel = false;
          },
          child: const Text('Yes'),
        ),
        cancel: TextButton(
          onPressed: () {
            Get.back();
            isCancel = true;
          },
          child: const Text('No'),
        ),
      );

      if (isCancel) {
        print('❌ Người dùng đã hủy khôi phục dữ liệu');
        return; // Người dùng đã hủy, không làm gì cả
      }

      // Xin quyền truy cập bộ nhớ
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        print('❌ Không có quyền truy cập file');
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select the backup project file (.json)',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        print('❌ Người dùng đã hủy chọn file');
        return;
      }

      final path = result.files.single.path!;
      await importAllHiveData(path);
      Get.defaultDialog(
        title: 'Restore successfully',
        middleText: 'Data was successfully recovered.',
        confirm: ElevatedButton(
          onPressed: () => Get.back(),
          child: const Text('OK'),
        ),
      );
      print('✅ Khôi phục dữ liệu thành công từ: $path');
    } catch (e) {
      print(e);
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

}
