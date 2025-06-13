
import 'package:dio/dio.dart';
import 'package:machine_test_farhathullah/utils/app_constants.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (status) =>
              status != null && status < 400, // Only 2xx and 3xx are valid
        ),
      ) {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.statusMessage} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'GET request failed for $path: ';
      if (e.response != null) {
        errorMessage +=
            'Status ${e.response!.statusCode} - ${e.response!.data}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage += 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage += 'Receive timeout';
      } else {
        errorMessage += e.message ?? 'Unknown error';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Unexpected error during GET request: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.statusMessage} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'POST request failed for $path: ';
      if (e.response != null) {
        errorMessage +=
            'Status ${e.response!.statusCode} - ${e.response!.data}';
      } else {
        errorMessage += e.message ?? 'Unknown error';
      }
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.statusMessage} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'PUT request failed for $path: ';
      if (e.response != null) {
        errorMessage +=
            'Status ${e.response!.statusCode} - ${e.response!.data}';
      } else {
        errorMessage += e.message ?? 'Unknown error';
      }
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(
          'Server returned status ${response.statusCode}: ${response.statusMessage} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'DELETE request failed for $path: ';
      if (e.response != null) {
        errorMessage +=
            'Status ${e.response!.statusCode} - ${e.response!.data}';
      } else {
        errorMessage += e.message ?? 'Unknown error';
      }
      throw Exception(errorMessage);
    }
  }
}
