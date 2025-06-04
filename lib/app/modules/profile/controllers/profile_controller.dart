import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  final isLoading = false.obs;
  final isCurrentUser = false.obs;

  final currentUser = Rxn<UserModel>();
  final viewedUser = Rxn<UserModel>();

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
    final idStr = Get.parameters['id'];
    final userId = int.tryParse(idStr ?? '');
    print('userId: $userId');

    // userId = 1; // Giả sử userId là 1, bạn có thể thay đổi giá trị này để kiểm tra

    if (userId != null) {
      isCurrentUser.value = false;
      await initProfile(userId);
    } else {
      isCurrentUser.value = true;
      await initProfile(null);
    }
  }

  Future<void> initProfile(int? userId) async {
    await loadCurrentUserFromHive();

    final self = currentUser.value;
    if (self == null || self.id == null) {
      print('Không tìm thấy currentUser');
      return;
    }

    int idToLoad = userId ?? int.parse(self.id!);

    try {
      final user = await getUser(idToLoad);
      viewedUser.value = user;
      isCurrentUser.value = user.id != null && user.id.toString() == self.id;
    } catch (e) {
      print('Lỗi khi lấy dữ liệu người dùng từ Supabase: $e');
    }

    checkIsCurrentUser(idToLoad);

    await fetchPostsByUser(idToLoad);
  }


  void checkIsCurrentUser(int userId) {
    final user = currentUser.value;
    if (user != null && user.id != null) {
      isCurrentUser.value = int.parse(user.id!) == userId;
    } else {
      isCurrentUser.value = false;
    }
  }

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
        throw Exception("Không tìm thấy người dùng với id: $userId");
      }
    } catch (e) {
      print("Lỗi khi lấy user: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> getAllPostsByCurrentUser(int userId) async {
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
      print("Lỗi khi lấy bài viết: $e");
      post.value = [];
    }
  }

  Future<void> fetchPostsByUser(int userId) async {
    await getAllPostsByCurrentUser(userId);
  }


  Future<void> signInWithGoogleAndSaveToSupabase() async {
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
          'bio': 'EMPTY',
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

      Get.snackbar("Đăng nhập thành công", "Chào ${userModel.id}");
    } catch (e) {
      Get.snackbar("Lỗi đăng nhập", e.toString());
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
      isLogined.value = false;
      print('Đã xoá current_user khỏi Hive');

      Get.snackbar("Đăng xuất", "Bạn đã đăng xuất thành công");
    } catch (e) {
      Get.snackbar("Lỗi đăng xuất", e.toString());
      print("Lỗi đăng xuất: $e");
    }
  }

}
