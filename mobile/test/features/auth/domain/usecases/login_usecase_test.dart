import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUseCase(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tAuthToken = AuthToken(
    accessToken: 'access_123',
    refreshToken: 'refresh_456',
    tokenType: 'bearer',
  );

  test('should return AuthToken when login repository succeeds', () async {
    // Arrange
    when(() => mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Right(tAuthToken));

    // Act
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));

    // Assert
    expect(result, const Right(tAuthToken));
    verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return AuthFailure when login repository fails', () async {
    // Arrange
    const tFailure = AuthFailure('Invalid credentials');
    when(() => mockRepository.login(tEmail, tPassword))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
