import 'package:flutter/foundation.dart';
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
      // Create form data
      FormData formData = FormData();

      if (kIsWeb) {
        // For web, we need to use blob data
        final bytes = await imageFile.readAsBytes();
        final mime =
            imageFile.name.endsWith('.png')
                ? 'image/png'
                : imageFile.name.endsWith('.gif')
                ? 'image/gif'
                : imageFile.name.endsWith('.webp')
                ? 'image/webp'
                : 'image/jpeg';

        formData.files.add(
          MapEntry(
            'profileImage',
            MultipartFile.fromBytes(
              bytes,
              filename: imageFile.name,
              contentType: DioMediaType.parse(mime),
            ),
          ),
        );
      } else {
        // For mobile
        formData.files.add(
          MapEntry(
            'profileImage',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.name,
            ),
          ),
        );
      }

      // Make API request
      final response = await _apiClient.dio.post(
        '${Endpoints.userEndpoint}/profile/image',
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

  /// Resets the user's profile image to default
  Future<User?> resetProfileImage() async {
    try {
      final response = await _apiClient.dio.post(
        '${Endpoints.userEndpoint}/profile/image-reset',
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
        '${Endpoints.userEndpoint}/profile/username',
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
        '${Endpoints.userEndpoint}/profile/password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating password: $e');
      rethrow; // Rethrow to handle in the UI
    }
  }
}
