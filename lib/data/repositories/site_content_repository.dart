import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class LegalContent {
  final String termsHtml;
  final String privacyHtml;
  final String impressumHtml;

  const LegalContent({
    this.termsHtml = '',
    this.privacyHtml = '',
    this.impressumHtml = '',
  });
}

class SiteContentRepository {
  Future<Map<String, dynamic>> getSettings() async => Map<String, dynamic>.from(
    (await apiClient.get('/content/app-settings')).data['settings'],
  );
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
      impressumHtml: content['impressumHtml']?.toString() ?? '',
    );
  }

  Future<Map<String, String>> getSocialLinks() async {
    final response = await apiClient.get('/content/app-settings');
    final settings = response.data['settings'] as Map;
    return {
      for (final entry in {
        'Instagram': settings['instagramUrl'],
        'TikTok': settings['tiktokUrl'],
      }.entries)
        if (entry.value?.toString().isNotEmpty == true)
          entry.key: entry.value.toString(),
    };
  }
}
