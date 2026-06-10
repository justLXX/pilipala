import 'package:flutter/material.dart';
import 'package:pilipala/models/user/info.dart';
import 'package:pilipala/models/user/stat.dart';

/// ProfileWidget displays the user profile information.
class ProfileWidget extends StatelessWidget {
  final UserInfoData userInfo;
  final UserStat? userStat;

  const ProfileWidget({
    super.key,
    required this.userInfo,
    this.userStat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User avatar and name
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(userInfo.face ?? ''),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo.uname ?? '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (userStat != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatItem('关注', userStat?.following ?? 0),
                      _buildStatItem('粉丝', userStat?.follower ?? 0),
                      _buildStatItem('动态', userStat?.dynamicCount ?? 0),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
