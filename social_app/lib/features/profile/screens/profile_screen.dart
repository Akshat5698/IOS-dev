import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mock/mock_database.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../models/post.dart';
import '../../../models/user.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final User user = MockDatabase.instance.currentUser;
  bool _isLoading = true;
  List<Post> _userPosts = [];

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    final posts = await ref.read(supabaseFeedServiceProvider).fetchPostsByUser(user.id);
    if (mounted) {
      setState(() {
        _userPosts = posts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                user.username,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileHeader(theme),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  indicatorColor: theme.colorScheme.onSurface,
                  labelColor: theme.colorScheme.onSurface,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.5),
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.video_library_outlined)),
                    Tab(icon: Icon(Icons.person_pin_outlined)),
                  ],
                ),
              ),
            ),
            _isLoading
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = _userPosts[index];
                        return Image.network(
                          post.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: theme.colorScheme.onSurface.withOpacity(0.1),
                            child: const Icon(Icons.broken_image),
                          ),
                        );
                      },
                      childCount: _userPosts.length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Avatar and Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.avatarUrl ?? 'https://placehold.co/150'),
                    backgroundColor: theme.colorScheme.surface,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                      ),
                      child: const Icon(Icons.add, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('posts', _userPosts.length.toString(), theme),
                    _buildStatColumn('followers', user.followersCount.toString(), theme),
                    _buildStatColumn('following', user.followingCount.toString(), theme),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bio
          Text(
            user.bio ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            '@${user.username}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                    foregroundColor: theme.colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
                    foregroundColor: theme.colorScheme.onSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Share profile', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.person_add_outlined),
                  onPressed: () {},
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Highlights
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildHighlight(theme, title: 'New', isAdd: true),
                _buildHighlight(theme, title: 'Holiiii', imageUrl: 'https://placehold.co/100x100/pink/white.png?text=H'),
                _buildHighlight(theme, title: '.', imageUrl: 'https://placehold.co/100x100/purple/white.png?text=A'),
                _buildHighlight(theme, title: 'Ayodhya', imageUrl: 'https://placehold.co/100x100/orange/white.png?text=A'),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlight(ThemeData theme, {required String title, String? imageUrl, bool isAdd = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.3), width: 1),
            ),
            child: isAdd
                ? const Icon(Icons.add, size: 28)
                : Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl ?? ''),
                      backgroundColor: theme.colorScheme.surface,
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          Text(title, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
