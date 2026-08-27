import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/home/data/datasources/todo_remote_data_source.dart';
import '../../features/home/data/repositories/todo_repository_impl.dart';
import '../../features/home/domain/repositories/todo_repository.dart';
import '../../features/home/domain/usecases/create_todo_usecase.dart';
import '../../features/home/domain/usecases/delete_todo_usecase.dart';
import '../../features/home/domain/usecases/get_todos_usecase.dart';
import '../../features/home/domain/usecases/update_todo_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Secure Storage for sensitive tokens
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  // Network Client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(secureStorage: sl<FlutterSecureStorage>()),
  );

  //! Feature - Auth
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl<FlutterSecureStorage>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl<AuthRepository>()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      checkAuthStatusUseCase: sl<CheckAuthStatusUseCase>(),
    ),
  );

  //! Feature - Home (Todo)
  // Data sources
  sl.registerLazySingleton<TodoRemoteDataSource>(
    () => TodoRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  // Repository
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(remoteDataSource: sl<TodoRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodosUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => CreateTodoUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => UpdateTodoUseCase(sl<TodoRepository>()));
  sl.registerLazySingleton(() => DeleteTodoUseCase(sl<TodoRepository>()));

  // Bloc
  sl.registerFactory(
    () => HomeBloc(
      getTodosUseCase: sl<GetTodosUseCase>(),
      createTodoUseCase: sl<CreateTodoUseCase>(),
      updateTodoUseCase: sl<UpdateTodoUseCase>(),
      deleteTodoUseCase: sl<DeleteTodoUseCase>(),
    ),
  );
}

