import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos({
    bool? isCompleted,
    String? search,
    int skip = 0,
    int limit = 100,
  });

  Future<TodoModel> createTodo({
    required String title,
    String? description,
    bool isCompleted = false,
  });

  Future<TodoModel> updateTodo({
    required int id,
    String? title,
    String? description,
    bool? isCompleted,
  });

  Future<void> deleteTodo(int id);
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final Dio dio;

  TodoRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TodoModel>> getTodos({
    bool? isCompleted,
    String? search,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip,
        'limit': limit,
      };
      if (isCompleted != null) {
        queryParams['is_completed'] = isCompleted;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        ApiConstants.todos,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((item) => TodoModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          message: response.data is Map ? response.data['detail'] ?? 'Failed to fetch todos' : 'Failed to fetch todos',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? e.response?.data['detail'] : e.message;
      throw ServerException(
        message: detail?.toString() ?? 'Network error while fetching todos',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TodoModel> createTodo({
    required String title,
    String? description,
    bool isCompleted = false,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.todos,
        data: {
          'title': title,
          'description': description,
          'is_completed': isCompleted,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return TodoModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data is Map ? response.data['detail'] ?? 'Failed to create todo' : 'Failed to create todo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? e.response?.data['detail'] : e.message;
      throw ServerException(
        message: detail?.toString() ?? 'Network error while creating todo',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TodoModel> updateTodo({
    required int id,
    String? title,
    String? description,
    bool? isCompleted,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (isCompleted != null) data['is_completed'] = isCompleted;

      final response = await dio.put(
        '${ApiConstants.todos}$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return TodoModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data is Map ? response.data['detail'] ?? 'Failed to update todo' : 'Failed to update todo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? e.response?.data['detail'] : e.message;
      throw ServerException(
        message: detail?.toString() ?? 'Network error while updating todo',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      final response = await dio.delete('${ApiConstants.todos}$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data is Map ? response.data['detail'] ?? 'Failed to delete todo' : 'Failed to delete todo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? e.response?.data['detail'] : e.message;
      throw ServerException(
        message: detail?.toString() ?? 'Network error while deleting todo',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
