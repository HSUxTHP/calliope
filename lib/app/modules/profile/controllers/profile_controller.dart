import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user_model.dart';

class ProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  final isLoading = false.obs;
  final isCurrentUser = true.obs;

  final videos = <String>["a","b","a","b","a","b","a","b","a","b","a","b"].obs;
  // final videos = <String>[].obs;

  final user = Rx<UserModel?>(null);

  late Box<UserModel> userBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    userBox = await Hive.openBox<UserModel>('users');
    await getUser(1);
  }

  Future<void> getUser(int userId) async {
    isLoading.value = true;
    try {
      final response = await Supabase.instance.client
          .from("users")
          .select()
          .eq("id", userId)
          .limit(1)
          .maybeSingle();

      print(response);
      if (response != null) {
        user.value = UserModel(
          id: response['id'].toString(),
          name: response['name'] ?? '',
          email: response['email'] ?? '',
          bio: response['bio'] ?? '',
          avatar_url: response['avatar_url'],
          created_at: DateTime.parse(response['created_at']),
          edited_at: DateTime.parse(response['edited_at']),
        );
      } else {
        saveUserDEV();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching todos: $e");
        saveUserDEV();
      }
    } finally {
      isLoading.value = false;
    }
  }


  void saveUserDEV() {
    user.value = UserModel(
      id: '1',
      created_at: DateTime.parse('2025-05-27T23:52:56Z'),
      edited_at: DateTime.parse('2025-05-27T23:52:54Z'),
      name: 'user 1',
      bio: 'this is a bio',
      email: 'nguyenvana@gmail.com',
      avatar_url: null,
    );
  }
}
