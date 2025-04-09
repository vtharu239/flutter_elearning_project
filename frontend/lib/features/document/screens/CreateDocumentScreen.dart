import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/document/model/doc_category_model.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateDocumentScreen extends StatefulWidget {
  const CreateDocumentScreen({super.key});

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  final AuthController _authController = Get.find();
  List<DocumentCategoryModel> categories = [];
  int? selectedCategoryId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final uri =
          Uri.parse(ApiConstants.getUrl(ApiConstants.getAllDocCategories));
      final response = await http.get(uri, headers: ApiConstants.getHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          categories =
              data.map((e) => DocumentCategoryModel.fromJson(e)).toList();
        });
      } else {
        throw Exception("Lỗi lấy danh mục");
      }
    } catch (e) {
      log("Lỗi: $e");
    }
  }

  Future<void> submitDocument() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final author = _authController.user.value?.username ?? '';
    final categoryId = selectedCategoryId;

    if (title.isEmpty || author.isEmpty || categoryId == null) {
      Get.snackbar("Lỗi", "Vui lòng nhập đầy đủ thông tin");
      return;
    }

    setState(() => isLoading = true);
    try {
      final uri = Uri.parse(ApiConstants.getUrl(ApiConstants.createDocument));
      final response = await http.post(
        uri,
        headers: ApiConstants.getHeaders(),
        body: json.encode({
          "title": title,
          "description": desc,
          "imageUrl": imageUrl,
          "author": author,
          "categoryId": categoryId,
          "status": "pending"
        }),
      );

      if (response.statusCode == 201) {
        Get.back();
        Get.snackbar("Thành công", "Tạo tài liệu thành công!");
      } else {
        final error = json.decode(response.body);
        Get.snackbar("Thất bại", error['error'] ?? 'Lỗi không xác định');
      }
    } catch (e) {
      Get.snackbar("Lỗi", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text("Tạo tài liệu"),
      ),
      backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TSectionHeading(
                    title: 'Điền thông tin chi tiết',
                    showActionButton: false,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Tiêu đề",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Mô tả",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: "Ảnh (URL hoặc assets)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        items: categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedCategoryId = value),
                        decoration: const InputDecoration(
                          labelText: "Danh mục",
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: darkMode ? Colors.black : Colors.white,
                        isExpanded:
                            false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton.icon(
                    onPressed: submitDocument,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Gửi bài viết",
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00A2FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
