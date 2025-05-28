import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  //TODO: Implement ProfileController

  final isCurrentUser = true.obs;

  var user = UserModel(
    id: '1',
    createdAt: DateTime.parse('2025-05-27T23:52:56Z'),
    editedAt: DateTime.parse('2025-05-27T23:52:54Z'),
    name: 'user 1',
    bio: 'this is a bio',
    email: 'nguyenvana@gmail.com',
    avatarUrl: null,
  ).obs;

  late Box<UserModel> userBox;

  @override
  Future<void> onInit() async {
    super.onInit();
    userBox = await Hive.openBox<UserModel>('users');
    if (userBox.isNotEmpty) {
      user.value = userBox.getAt(0)!;
    }
    else {
      // If no user exists, save the default user
      saveUser();
    }
    // printUser();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void saveUser() {
    userBox.put('current_user', user.value);
  }

  printUser() {
    print('User ID: ${user.value.id}');
    print('Created At: ${user.value.createdAt}');
    print('Edited At: ${user.value.editedAt}');
    print('Name: ${user.value.name}');
    print('Bio: ${user.value.bio}');
    print('Email: ${user.value.email}');
    print('Avatar URL: ${user.value.avatarUrl ?? "No avatar"}');
  }
}
