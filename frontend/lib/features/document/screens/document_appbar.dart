import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/document/screens/CreateDocumentScreen.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';

class TDocumentAppBar extends StatelessWidget {
  const TDocumentAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TTexts.documentAppbarTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            softWrap: true, // Ensure the text wraps
            overflow: TextOverflow
                .visible, // Allow text to overflow into next line if necessary
          ),
          Text(
            TTexts.documentAppbarSubTitle,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.white70),
            softWrap: true, // Ensure the text wraps
            overflow: TextOverflow
                .visible, // Allow text to overflow into next line if necessary
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateDocumentScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}
