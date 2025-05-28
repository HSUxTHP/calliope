import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/community_controller.dart';

class CommunityView extends GetView<CommunityController> {
  const CommunityView({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom AppBar
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            color: Color(0xFFE8EDF1),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo
              const Text(
                'Calliope',
                style: TextStyle(
                  color: Color(0xFF40484C),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Search Bar
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.45,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search your project here',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    print('Search submitted: $value');
                  },
                ),
              ),

              // Avatar
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ),

        // Body Content (Placeholder)
        Expanded(
          child: Center(
            child: Text(
              'HomeView is working',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}
