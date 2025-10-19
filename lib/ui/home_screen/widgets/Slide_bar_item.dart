import 'package:flutter/material.dart';

class SlideBarItem extends StatelessWidget {

  final IconData icon;
  final String title;

  SlideBarItem(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 8)),
        ],
      ),
    );
  }
}
