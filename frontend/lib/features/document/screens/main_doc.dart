import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/features/document/model/category_model.dart';
import 'package:flutter_elearning_project/features/document/screens/cate_detail.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_list_view.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_detailview.dart';
import 'package:flutter_elearning_project/features/document/screens/document_appbar.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';
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
    final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TSectionHeading(
                    title: 'Tổng hợp tài liệu',
                    showActionButton: false,
                  ),
                  Obx(() {
                    if (docController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (docController.documents.isEmpty) {
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Không có tài liệu nào.',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00A2FF)),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),
                  const TSectionHeading(
                    title: 'Chuyên mục',
                    showActionButton: false,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isExpanded =
                          expandedCategories[category.title] ?? false;

                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                category.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: darkMode ? Colors.white : Colors.black,
                              ),
                              onTap: () {
                                setState(() {
                                  expandedCategories[category.title] =
                                      !isExpanded;
                                });
                              },
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      category.subCategories.map((subCat) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        subCat,
                                        style: const TextStyle(fontSize: 16),
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
                            const Divider(),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
