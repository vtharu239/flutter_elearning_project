import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/category_model.dart';
import 'package:flutter_elearning_project/features/document/screens/cate_detail.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_list_view.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_detailview.dart';
import 'package:flutter_elearning_project/features/document/screens/document_appbar.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:flutter_elearning_project/features/document/controller/document_controller.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';

class MainDocScreen extends StatefulWidget {
  const MainDocScreen({super.key});

  @override
  State<MainDocScreen> createState() => _MainDocScreenState();
}

class _MainDocScreenState extends State<MainDocScreen> {
  Map<String, bool> expandedCategories = {};
  final DocumentController docController = Get.put(DocumentController());
  bool showAllDocuments = false;

  @override
  void initState() {
    super.initState();
    for (var category in categories) {
      expandedCategories[category.title] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header section
          const TPrimaryHeaderContainer(
            child: Column(
              children: [
                TDocumentAppBar(),
                SizedBox(height: TSizes.spaceBtwSections),
              ],
            ),
          ),

          // Nội dung bo góc trắng
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "TỔNG HỢP TÀI LIỆU",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Obx(() {
                      if (docController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (docController.documents.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Không có tài liệu nào.'),
                        );
                      }

                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: showAllDocuments
                                ? docController.documents.length
                                : (docController.documents.length > 5
                                    ? 5
                                    : docController.documents.length),
                            itemBuilder: (context, index) {
                              final doc = docController.documents[index];
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DocumentDetailScreen(document: doc),
                                    ),
                                  );
                                  docController.fetchDocuments();
                                },
                                child: DocumentsListView(item: doc),
                              );
                            },
                          ),
                          if (docController.documents.length > 5)
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    showAllDocuments = !showAllDocuments;
                                  });
                                },
                                child: Text(
                                  showAllDocuments ? "Ẩn bớt ▲" : "Xem thêm ▼",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Chuyên mục",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isExpanded =
                            expandedCategories[category.title] ?? false;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  category.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  setState(() {
                                    expandedCategories[category.title] =
                                        !isExpanded;
                                  });
                                },
                              ),
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      category.subCategories.map((subCat) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        subCat,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CategoryDetailScreen(
                                                    category: category),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            const Divider(indent: 16, endIndent: 16),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
