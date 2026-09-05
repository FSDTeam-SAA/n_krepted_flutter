import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class LegalContent {
  final String termsHtml;
  final String privacyHtml;

  const LegalContent({this.termsHtml = '', this.privacyHtml = ''});
}

class SiteContentRepository {
  final ApiClient apiClient;

  SiteContentRepository({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient();

  Future<LegalContent> getLegalContent() async {
    final response = await apiClient.get(ApiConstants.legalContent);
    final content = response.data?['content'];
    if (content is! Map) return const LegalContent();
    return LegalContent(
      termsHtml: content['termsHtml']?.toString() ?? '',
      privacyHtml: content['privacyHtml']?.toString() ?? '',
    );
  }
}
