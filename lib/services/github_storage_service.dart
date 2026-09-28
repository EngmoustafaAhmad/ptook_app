import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

enum ImageType {
  competition,
  userAvatar,
}

class GithubStorageService {
  final String owner;
  final String repo;
  final String branch;
  final String token;
  final http.Client _client;

  GithubStorageService({
    required this.token,
    this.owner = 'EngmoustafaAhmad',
    this.repo = 'Ptook_assets',
    this.branch = 'main',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Standard Headers for GitHub REST API v3
  Map<String, String> get _headers => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
        'User-Agent': 'Ptook-App',
      };

  /// Uploads a competition image to `competition/`
  Future<String?> uploadCompetitionImage({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    return _uploadToGithub(
      fileBytes: fileBytes,
      fileName: fileName,
      type: ImageType.competition,
    );
  }

  /// Uploads a user avatar image to `userAvatar/`
  Future<String?> uploadUserAvatar({
    required List<int> fileBytes,
    required String fileName,
  }) async {
    return _uploadToGithub(
      fileBytes: fileBytes,
      fileName: fileName,
      type: ImageType.userAvatar,
    );
  }

  /// Generic GitHub REST API Uploader
  Future<String?> _uploadToGithub({
    required List<int> fileBytes,
    required String fileName,
    required ImageType type,
  }) async {
    if (token.isEmpty) {
      developer.log('❌ GitHub upload aborted: Personal Access Token is empty.', name: 'GithubStorageService');
      return null;
    }

    try {
      final folderPath = switch (type) {
        ImageType.competition => 'competition',
        ImageType.userAvatar => 'userAvatar',
      };

      final path = '$folderPath/$fileName';
      final url = Uri.parse(
        'https://api.github.com/repos/$owner/$repo/contents/$path',
      );

      final base64Content = base64Encode(fileBytes);

      // Fetch SHA if file exists to update it without conflicts
      final existingSha = await _getFileSha(url);

      final bodyData = <String, dynamic>{
        'message': 'Upload ${type.name} image: $fileName',
        'content': base64Content,
        'branch': branch,
      };

      if (existingSha != null) {
        bodyData['sha'] = existingSha;
      }

      final response = await _client.put(
        url,
        headers: _headers,
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return 'https://raw.githubusercontent.com/$owner/$repo/$branch/$path';
      } else {
        developer.log(
          '❌ GitHub Upload Failed [${response.statusCode}]: ${response.body}',
          name: 'GithubStorageService',
        );
        return null;
      }
    } catch (e, st) {
      developer.log('❌ Error uploading to GitHub: $e', stackTrace: st, name: 'GithubStorageService');
      return null;
    }
  }

  /// Fetches existing file's SHA if file already exists in repository
  Future<String?> _getFileSha(Uri url) async {
    try {
      final response = await _client.get(
        url,
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['sha'] as String?;
      }
    } catch (e) {
      developer.log('⚠️ SHA Fetch failed or file does not exist: $e', name: 'GithubStorageService');
    }
    return null;
  }
}

