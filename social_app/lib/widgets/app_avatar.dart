import 'package:flutter/material.dart';

/// Reusable circular avatar with network image and fallback icon.
class AppAvatar extends StatelessWidget {
  /// The URL for the avatar image. Falls back to a person icon if `null`.
  final String? imageUrl;

  /// Radius of the avatar circle.
  final double radius;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
        onBackgroundImageError: (_, __) {},
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
      child: Icon(
        Icons.person,
        size: radius,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
      ),
    );
  }
}
