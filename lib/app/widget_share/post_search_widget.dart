import 'package:calliope/app/data/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PostSearchCard extends StatelessWidget {
  const PostSearchCard({
    super.key,
    required this.post
  });

  final PostModel post;
  @override
  Widget build(BuildContext context) {
    final formattedDate = post.created_at != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(post.created_at)
        : 'Không rõ ngày đăng';
    return GestureDetector(
      onTap: () {
        // Add your tap logic here
      },
      child: Card(
        elevation: 3,
        color: Theme.of(context).colorScheme.surfaceContainer,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Add your tap logic here
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16 , vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 16,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.thumbnail,
                    width: MediaQuery.sizeOf(context).width * 0.2,
                    height: MediaQuery.sizeOf(context).width * 0.13,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Text(
                        post.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        spacing: 16,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(post.user?.avatar_url ?? 'https://via.placeholder.com/150'),
                          ),
                          Expanded(
                            child: Text(
                              post.user?.name ?? 'Unknown User',
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        post.description ?? '',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 16,
                        children: [
                          Text(
                            "${post.views} Views",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            "|",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            formattedDate.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
