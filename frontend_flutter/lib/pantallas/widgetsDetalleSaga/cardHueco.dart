import 'package:flutter/material.dart';

class CardHueco extends StatelessWidget {
  final int volumen;

  const CardHueco({super.key, required this.volumen});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 32, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            'Vol. $volumen',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}