import 'package:flutter/material.dart';

class EmptyFilesState extends StatelessWidget {
  const EmptyFilesState({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF7C4DFF).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                color: Color(0xFF7C4DFF),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No files yet',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload PDFs and documents for the group',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
}