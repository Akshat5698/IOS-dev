import '../../models/user.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../models/conversation.dart';
import '../../models/message.dart';

/// Singleton in-memory mock database.
class MockDatabase {
  static final MockDatabase instance = MockDatabase._internal();
  MockDatabase._internal();

  // ── Seed Data ───────────────────────────────────────────────────────────

  final User currentUser = User(
    id: 'user_1',
    username: 'akshat_mfc',
    email: 'akshat@app.com',
    avatarUrl: 'https://ui-avatars.com/api/?name=Akshat+Dwivedi&background=random',
    bio: 'Akshat Dwivedi',
    followersCount: 40,
    followingCount: 41,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  final List<User> otherUsers = [
    User(id: 'user_2', username: 'alice_smith', email: 'alice@app.com', avatarUrl: 'https://ui-avatars.com/api/?name=Alice+Smith&background=random', createdAt: DateTime.now()),
    User(id: 'user_3', username: 'bob_jones', email: 'bob@app.com', avatarUrl: 'https://ui-avatars.com/api/?name=Bob+Jones&background=random', createdAt: DateTime.now()),
    User(id: 'user_4', username: 'charlie_brown', email: 'charlie@app.com', avatarUrl: 'https://ui-avatars.com/api/?name=Charlie+Brown&background=random', createdAt: DateTime.now()),
  ];

  late final List<Post> posts = [
    Post(
      id: 'post_1',
      userId: 'user_1',
      imageUrl: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
      caption: 'Loving this new static app design! 🚀',
      likesCount: 42,
      commentsCount: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Post(
      id: 'post_2',
      userId: 'user_1',
      imageUrl: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
      caption: 'Coffee time ☕️',
      likesCount: 15,
      commentsCount: 0,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Post(
      id: 'post_3',
      userId: 'user_4',
      imageUrl: 'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
      caption: 'What a beautiful sunset...',
      likesCount: 120,
      commentsCount: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  late final List<Comment> comments = [
    Comment(id: 'comment_1', postId: 'post_1', userId: 'user_3', text: 'Looks amazing!', createdAt: DateTime.now().subtract(const Duration(minutes: 30))),
    Comment(id: 'comment_2', postId: 'post_1', userId: 'user_1', text: 'Thanks for sharing.', createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
  ];

  late final List<Conversation> conversations = [
    Conversation(
      id: 'conv_1',
      participantIds: ['user_1', 'user_2'],
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      otherUser: otherUsers[0],
      lastMessage: Message(
        id: 'msg_1',
        senderId: 'user_2',
        receiverId: 'user_1',
        content: 'Hey, did you see my new post?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ),
    Conversation(
      id: 'conv_2',
      participantIds: ['user_1', 'user_3'],
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      otherUser: otherUsers[1],
      lastMessage: Message(
        id: 'msg_2',
        senderId: 'user_1',
        receiverId: 'user_3',
        content: 'Let\'s grab coffee later.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ),
  ];

  late final List<Message> messages = [
    // conv_1
    Message(id: 'msg_0', senderId: 'user_1', receiverId: 'user_2', content: 'Hey Alice!', createdAt: DateTime.now().subtract(const Duration(minutes: 10))),
    Message(id: 'msg_1', senderId: 'user_2', receiverId: 'user_1', content: 'Hey, did you see my new post?', createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
    // conv_2
    Message(id: 'msg_2', senderId: 'user_1', receiverId: 'user_3', content: 'Let\'s grab coffee later.', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
  ];
  
  // Helper to fetch a user by ID
  User? getUser(String id) {
    if (id == currentUser.id) return currentUser;
    try {
      return otherUsers.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}
