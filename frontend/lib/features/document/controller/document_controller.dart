import 'dart:convert';
import 'package:flutter_elearning_project/features/document/model/RelatedArticle_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_constants.dart';
import '../model/doc_list_model.dart';

class DocumentController extends GetxController {
  final documents = <DocumentsListItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      isLoading.value = true;

      final url = Uri.parse(ApiConstants.getUrl(ApiConstants.getAllDocuments));
      final headers = ApiConstants.getHeaders();

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        documents.value =
            data.map((json) => DocumentsListItem.fromJson(json)).toList();
      } else {
        Get.snackbar('Lỗi', 'Tải tài liệu thất bại (${response.statusCode})');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không kết nối được server: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<RelatedArticle>> fetchRelatedArticles(String category) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/api/documents?category=$category',
    );

    final response = await http.get(uri, headers: ApiConstants.getHeaders());

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => RelatedArticle.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load related articles');
    }
  }
}
