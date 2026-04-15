import 'dart:io';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../utils/app_logger.dart';

class UploadService {
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  static Future<String> uploadImage({
    required File file,
    String folder = 'general',
  }) async {
    if (!file.existsSync()) {
      throw Exception('File not found: ${file.path}');
    }

    final fileSize = await file.length();
    if (fileSize > _maxFileSizeBytes) {
      throw Exception('File is too large (max 5 MB)');
    }

    final extension = file.path.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(extension)) {
      throw Exception(
        'Invalid file type. Allowed: ${_allowedExtensions.join(', ')}',
      );
    }

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: DioMediaType(
            'image',
            extension == 'jpg' ? 'jpeg' : extension,
          ),
        ),
        'folder': folder,
      });

      final res = await ApiService.dio.post(
        '/upload/image',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final url = res.data['full_image_url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Server did not return an image URL');
      }

      return url;
    } on DioException catch (e) {
      appLogger.e('Image upload failed', error: e);
      throw Exception('Upload failed: ${e.message}');
    } catch (e) {
      appLogger.e('Unexpected upload error', error: e);
      rethrow;
    }
  }
}
