import 'package:flutter/material.dart';

class SlideBarItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const SlideBarItem(this.icon, this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      child: Row(
        children: [
          Icon(
            icon,
            size: 26,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
