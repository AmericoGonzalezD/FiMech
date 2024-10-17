import 'package:flutter/material.dart';

class ProfileData extends StatelessWidget {
  const ProfileData({
    super.key,
    required this.onPressed,
    required this.title,
    required this.value,
    this.icon = Icons.edit,
  });
  final IconData icon;
  final VoidCallback onPressed;
  final String title, value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                maxLines: 2,
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8,),
            Icon(icon, size: 18,color: Color(0xFF258EB4),),
          ],
        ),
      ),
    );
  }
}
