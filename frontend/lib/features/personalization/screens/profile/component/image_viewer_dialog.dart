import 'package:flutter/material.dart';

class TImageViewerDialog extends StatelessWidget {
  final String imageUrl;
  final bool isNetworkImage;
  final String defaultImage;

  const TImageViewerDialog({
    super.key,
    required this.imageUrl,
    this.isNetworkImage = true,
    required this.defaultImage,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              // Image
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image(
                    image: isNetworkImage
                        ? NetworkImage(
                            imageUrl,
                            headers: {'cache-control': 'no-cache'},
                          )
                        : AssetImage(defaultImage) as ImageProvider,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Close button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}