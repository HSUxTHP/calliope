import 'package:calliope/app/data/models/post_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_model.dart';
import '../../profile/controllers/profile_controller.dart';

class CommunityController extends GetxController
    with GetSingleTickerProviderStateMixin {
  //TODO: Implement CommunityController
  var selectedTabIndex = 0.obs;
  late TabController tabController;

  final isLoading = false.obs;

  final post = <PostModel>[].obs;

  UserModel? user;
  final profileController = Get.find<ProfileController>();


  void changeTab(int index) async {
    selectedTabIndex.value = index;
    tabController.animateTo(index);
    await reload();
  }

  var searchText = ''.obs;
  final searchController = TextEditingController();
  bool get isSearching => searchText.value.trim().isNotEmpty;

  void updateSearch(String value) {
    searchText.value = value;
  }

  final count = 0.obs;
  @override
  void onInit() async {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
    await reload();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> reload() async {
    if (!await profileController.checkNetworkConnection()) {
      Get.snackbar("No Internet", "Please Check the internet connection",
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    print(selectedTabIndex.value);
    if (selectedTabIndex.value == 0) {
      // Reload trending posts
      await getAllPosts(0);
    } else if (selectedTabIndex.value == 1) {
      // Reload newest posts
      await getAllPosts(1);
    } else {
      // Reload most liked posts
      await getAllPosts(0);
    }
    isLoading.value = false;
  }

  Future<void> getAllPosts(int index) async {
    try {
      isLoading.value = true;
      PostgrestList response;

      if (index == 0) {
        response = await Supabase.instance.client
            .from('posts')
            .select()
            .eq('status', 1)
            .order('views', ascending: false);
      } else if (index == 1) {
        response = await Supabase.instance.client
            .from('posts')
            .select()
            .eq('status', 1)
            .order('created_at', ascending: false);
      } else {
        response = await Supabase.instance.client
            .from('posts')
            .select()
            .eq('status', 1)
            .order('create_at', ascending: false);
      }

      final profileController = Get.find<ProfileController>();

      final postsWithUser = await Future.wait(response.map((post) async {
        final user = await profileController.getUser(post['user_id']);
        return PostModel(
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
          user: user, // gán user ở đây
        );
      }));

      post.value = postsWithUser;
      isLoading.value = false;
    } catch (e) {
      if (kDebugMode) {
        print("Error when geting the post: $e");
      }
      post.value = [];
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchPosts(String query) async {
    if (query.isEmpty) {
      post.value = [];
      return;
    }
    if (!await profileController.checkNetworkConnection()) {
      post.value = [];
      throw Exception("No Internet Connection");
    }
    try {
      isLoading.value = true;
      final response = await Supabase.instance.client
          .from('posts')
          .select()
          .ilike('name', '%$query%');

      final profileController = Get.find<ProfileController>();

      final postsWithUser = await Future.wait(response.map((post) async {
        final user = await profileController.getUser(post['user_id']);
        return PostModel(
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
          user: user, // gán user ở đây
        );
      }));

      post.value = postsWithUser;
    } catch (e) {
      if (kDebugMode) {
        print("Error when searching post: $e");
      }
      post.value = [];
    } finally {
      isLoading.value = false;
    }
  }
}
