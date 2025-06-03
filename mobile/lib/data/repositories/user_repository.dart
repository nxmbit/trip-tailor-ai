import 'package:frontend/data/api/api_client.dart';
import 'package:frontend/data/api/endpoints.dart';
import 'package:frontend/domain/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  /// Fetches the current user's profile
  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get(Endpoints.currentUserEndpoint);

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Updates the user's profile image
  Future<User?> updateProfileImage(XFile imageFile) async {
    try {
      FormData formData = FormData();
      final String mimeType = getMimeType(imageFile.name);
      final bytes = await imageFile.readAsBytes();

      formData.files.add(
        MapEntry(
          'profileImage',
          MultipartFile.fromBytes(
            bytes,
            filename: imageFile.name,
            contentType: DioMediaType.parse(mimeType),
          ),
        ),
      );

      final response = await _apiClient.dio.post(
        Endpoints.imageChangeEndpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error updating profile image: $e');
      rethrow; // Rethrow to handle in the UI
    }
  }

  String getMimeType(String filename) {
    final extension = filename.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  /// Resets the user's profile image to default
  Future<User?> resetProfileImage() async {
    try {
      final response = await _apiClient.dio.post(
        Endpoints.imageResetEndpoint,
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error resetting profile image: $e');
      rethrow; // Rethrow to handle in the UI
    }
  }
  Future<User?> updateUsername(String newUsername) async {
    try {
      final response = await _apiClient.dio.post(
        Endpoints.usernameChangeEndpoint,
        data: {'username': newUsername},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        // Parse user from response if possible
        final user = User.fromJson(response.data);
        // Refresh user credentials
        await getCurrentUser();
        return user;
      } else if (response.statusCode == 200) {
        // If backend returns just a string, refresh and return updated user
        return await getCurrentUser();
      }
      return null;
    } catch (e) {
      print('Error updating username: $e');
      throw Exception(
        'There was a problem updating your username. Please try again.',
      );
    }
  }

  /// Updates the user's password
  Future<bool> updatePassword(
      String currentPassword,
      String newPassword,
      ) async {
    try {
      final response = await _apiClient.dio.post(
        Endpoints.passwordChangeEndpoint,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating password: $e');
      rethrow; // Rethrow to handle in the UI
    }
  }
}
