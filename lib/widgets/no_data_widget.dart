import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Using a network image that closely resembles the screenshot
          // (Two clipboards or a clipboard with checkmarks)
          // Since I can't generate the exact one, I'll use a high quality vector
          // or a composed widget with icons.
          // Let's try to compose it with icons for better reliability or use a very standard placeholder.
          // Actually, I'll use a specific image URL that looks like a "No Data" clipboard.
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              'assets/images/logo.jpg',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Data Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey, // text-gray-500
            ),
          ),
        ],
      ),
    );
  }
}
