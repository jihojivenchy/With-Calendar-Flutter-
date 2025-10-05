import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:with_calendar/data/network/error/error_type.dart';

abstract class BaseURLs {
  static const String holidayAPI =
      'https://apis.data.go.kr/';
}

/// 네트워크 서비스
class DioService {
  static final DioService _instance = DioService._internal();
  factory DioService() => _instance;

  late final Dio _dio;

  // 생성자 (외부에서 인스턴스를 생성할 수 없음)
  DioService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BaseURLs.holidayAPI,
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    // TODO: - 실제 서비스 출시 전에는 코드 제거 (디버그 환경에서만 호출되는 것이 아님)
    _dio.interceptors.add(
      LogInterceptor(
        logPrint: (o) => debugPrint(o.toString()),
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
  }

  // GET 요청
  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? parameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: parameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST 요청
  Future<T> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? parameters,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: parameters,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT 요청
  Future<T> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? parameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: parameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH 요청
  Future<T> patch<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? parameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: parameters,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE 요청
  Future<T> delete<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? parameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: parameters,
        data: data,
        options: options,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 에러 핸들링
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('요청이 시간 초과했습니다. (잠시 후 다시 시도해주세요)');

      case DioExceptionType.badResponse: // (200-299) 이외의 상태 코드 반환 시
        // 서버 응답에서 메시지 추출
        String responseMessage = '';

        try {
          final response = error.response?.data;
          if (response is Map<String, dynamic> && response['message'] != null) {
            responseMessage = response['message'].toString();
          }
        } catch (e) {
          responseMessage = '서버 오류가 발생했습니다. (잠시 후 다시 시도해주세요)';
        }

        return ServerException(
          responseMessage,
          statusCode: error.response?.statusCode,
        );
      default:
        return NetworkException('네트워킹 오류가 발생했습니다. (잠시 후 다시 시도해주세요)');
    }
  }
}
