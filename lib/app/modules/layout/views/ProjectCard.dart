import 'package:calliope/app/modules/draw/views/draw_view.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String createdAt;

  const ProjectCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Theme.of(context).colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DrawView())
          );
        },
        child: ClipRRect(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                "${imageUrl}",
                width: double.infinity, // Match the width of the Card
                height: 140, // Fixed height for the image
                fit: BoxFit.cover, // Ensure the image covers the available space
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("$title",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("$createdAt",
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Xử lý khi chọn Edit
                          print('Edit selected');
                        } else if (value == 'delete') {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text(
                                      'Are you sure want to delete this project ? \n'
                                          'this action cannot be undone.',
                                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.error)
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                      onPressed: () {
                                        // Delete logic here
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onError,
                                          )
                                      ),
                                    ),
                                  ],
                                );
                              }
                          );
                          print('Delete selected');
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      icon: Icon(Icons.more_vert),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}