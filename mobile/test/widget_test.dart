import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/auth/data/models/auth_token_model.dart';
import 'package:mobile_app/features/home/presentation/bloc/home_state.dart';

void main() {
  group('AuthTokenModel Test', () {
    test('should parse json correctly with refresh_token', () {
      final json = {
        'access_token': 'access_123',
        'refresh_token': 'refresh_456',
        'token_type': 'bearer',
      };

      final model = AuthTokenModel.fromJson(json);

      expect(model.accessToken, 'access_123');
      expect(model.refreshToken, 'refresh_456');
      expect(model.tokenType, 'bearer');
    });

    test('toJson should return correct map', () {
      const model = AuthTokenModel(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
        tokenType: 'bearer',
      );

      final json = model.toJson();

      expect(json['access_token'], 'access_123');
      expect(json['refresh_token'], 'refresh_456');
      expect(json['token_type'], 'bearer');
    });
  });

  group('HomeState Test', () {
    test('copyWith should clear actionMessage when clearActionMessage is true', () {
      const state = HomeState(actionMessage: 'Đã thêm công việc!');
      final newState = state.copyWith(clearActionMessage: true);

      expect(newState.actionMessage, isNull);
    });
  });
}
