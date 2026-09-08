import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atpharma/core/network/dio_client.dart';
import 'package:atpharma/core/network/api_request_options.dart';
import 'package:atpharma/core/session/session_manager.dart';
import 'package:atpharma/core/storage/local_storage_service.dart';
import 'package:atpharma/core/storage/token_storage.dart';
import 'package:atpharma/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:atpharma/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:atpharma/features/auth/domain/usecases/registration_use_cases.dart';
import 'package:atpharma/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:atpharma/features/auth/presentation/pages/auth_otp_page.dart';

class MemoryStorage implements LocalStorageService {
  final values = <String, dynamic>{};
  @override
  Future<void> write<T>({required String key, required T value}) async {
    values[key] = value;
  }

  @override
  Future<void> writeMap({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Map<String, dynamic>? readMap(String key) =>
      values[key] as Map<String, dynamic>?;
  @override
  bool? readBool(String key) => values[key] as bool?;
  @override
  String? readString(String key) => values[key] as String?;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late RegistrationBloc bloc;
  late SessionManager session;
  late List<RequestOptions> requests;
  late Map<String, dynamic> response;
  late int status;
  late DateTime now;
  Completer<void>? pending;
  setUp(() {
    requests = [];
    response = {'message': 'Code sent'};
    status = 201;
    now = DateTime(2026, 9, 8);
    pending = null;
    final storage = MemoryStorage();
    session = SessionManager(
      tokenStorage: GetStorageTokenStorage(localStorageService: storage),
      localStorageService: storage,
    );
    final dio = Dio(DioClient.createBaseOptions());
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          requests.add(options);
          await pending?.future;
          if (status >= 400) {
            handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: status,
                  data: response,
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          } else {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: status,
                data: response,
              ),
            );
          }
        },
      ),
    );
    final repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(
        dioClient: DioClient(dio: dio),
      ),
      sessionManager: session,
    );
    bloc = RegistrationBloc(
      now: () => now,
      registerUseCase: RegisterUseCase(repository: repository),
      verifyCodeUseCase: VerifyCodeUseCase(repository: repository),
      resendCodeUseCase: ResendRegistrationCodeUseCase(repository: repository),
    );
  });
  tearDown(() async => bloc.close());
  Future<void> send(RegistrationEvent event, RegistrationStatus until) async {
    final done = bloc.stream.firstWhere((state) => state.status == until);
    bloc.add(event);
    await done;
  }

  const submit = RegistrationSubmitted(
    name: ' Sara ',
    phone: '+966500000000',
    email: ' sara@example.com ',
    password: 'secret123',
  );
  Map<String, dynamic> authenticated() {
    final payload = base64Url.encode(
      utf8.encode(
        jsonEncode({
          'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
        }),
      ),
    );
    return {
      'accessToken': 'header.$payload.signature',
      'customer': {'id': 'customer-1', 'email': 'sara@example.com'},
    };
  }

  test(
    'registration sends documented payload publicly without creating a session',
    () async {
      await send(submit, RegistrationStatus.codeSent);
      expect(requests.single.path, '/shop/auth/register');
      expect(requests.single.data, {
        'name': 'Sara',
        'phone': '+966500000000',
        'email': 'sara@example.com',
        'password': 'secret123',
      });
      expect(ApiRequestOptions.requiresAuthentication(requests.single), false);
      expect(ApiRequestOptions.allowsRetry(requests.single), false);
      expect(session.hasAccessToken, false);
    },
  );
  test('invalid form makes no backend request', () async {
    await send(
      const RegistrationSubmitted(
        name: '',
        phone: '',
        email: 'invalid',
        password: '123',
      ),
      RegistrationStatus.failure,
    );
    expect(requests, isEmpty);
  });
  test(
    'duplicate submissions are dropped while a request is pending',
    () async {
      pending = Completer<void>();
      bloc.add(submit);
      await bloc.stream.firstWhere(
        (s) => s.status == RegistrationStatus.submitting,
      );
      bloc.add(submit);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      pending!.complete();
      await bloc.stream.firstWhere(
        (s) => s.status == RegistrationStatus.codeSent,
      );
      expect(requests, hasLength(1));
    },
  );
  test(
    'wrong OTP fails without authentication; valid retry persists customer session',
    () async {
      await send(submit, RegistrationStatus.codeSent);
      status = 400;
      response = {'message': 'Invalid or expired code'};
      await send(
        const VerificationSubmitted('123456'),
        RegistrationStatus.failure,
      );
      expect(bloc.state.message, contains('Invalid or expired code'));
      expect(session.hasAccessToken, false);
      status = 201;
      response = authenticated();
      await send(
        const VerificationSubmitted('654321'),
        RegistrationStatus.verified,
      );
      expect(requests.last.path, '/shop/auth/verify-email');
      expect(requests.last.data, {
        'email': 'sara@example.com',
        'code': '654321',
      });
      expect(session.isAuthenticated, true);
    },
  );
  test('malformed success response cannot authenticate', () async {
    await send(submit, RegistrationStatus.codeSent);
    await send(
      const VerificationSubmitted('123456'),
      RegistrationStatus.failure,
    );
    expect(session.hasAccessToken, false);
  });
  test(
    'login OTP uses identifier contract and preserves remember me',
    () async {
      await send(
        const LoginVerificationStarted(
          identifier: 'user@example.com',
          rememberMe: true,
        ),
        RegistrationStatus.codeSent,
      );
      response = authenticated();
      await send(
        const VerificationSubmitted('123456'),
        RegistrationStatus.verified,
      );
      expect(requests.single.path, '/auth/login/verify-code');
      expect(requests.single.data, {
        'identifier': 'user@example.com',
        'code': '123456',
      });
      expect(session.rememberedIdentifier, 'user@example.com');
    },
  );
  testWidgets('OTP verification navigates home only after backend success', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() => send(submit, RegistrationStatus.codeSent));
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const AuthOtpPage()),
        routes: {'/home': (_) => const Scaffold(body: Text('AT Pharma home'))},
      ),
    );
    await tester.enterText(find.byType(TextField).first, '123456');
    status = 400;
    response = {'message': 'Invalid or expired code'};
    await tester.runAsync(() async {
      final done = bloc.stream.firstWhere(
        (state) =>
            state.status ==
            (status == 201
                ? RegistrationStatus.verified
                : RegistrationStatus.failure),
      );
      await tester.tap(find.text('Verify'));
      await done;
    });
    await tester.pumpAndSettle();
    expect(find.text('AT Pharma home'), findsNothing);
    expect(find.text('Invalid or expired code'), findsOneWidget);
    status = 201;
    response = authenticated();
    await tester.runAsync(() async {
      final done = bloc.stream.firstWhere(
        (state) =>
            state.status ==
            (status == 201
                ? RegistrationStatus.verified
                : RegistrationStatus.failure),
      );
      await tester.tap(find.text('Verify'));
      await done;
    });
    await tester.pumpAndSettle();
    expect(find.text('AT Pharma home'), findsOneWidget);
    expect(find.text('Success! Verification completed.'), findsOneWidget);
  });
  test(
    'resend uses email endpoint after cooldown and resets only on success',
    () async {
      await send(submit, RegistrationStatus.codeSent);
      bloc.add(const VerificationResendRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(requests, hasLength(1));
      now = now.add(const Duration(seconds: 91));
      status = 429;
      response = {'message': 'Please try again later'};
      await send(
        const VerificationResendRequested(),
        RegistrationStatus.failure,
      );
      expect(bloc.state.resendGeneration, 0);
      status = 201;
      response = {'message': 'Code sent'};
      await send(
        const VerificationResendRequested(),
        RegistrationStatus.resent,
      );
      expect(requests.last.path, '/shop/auth/request-code');
      expect(requests.last.data, {'email': 'sara@example.com'});
      expect(bloc.state.resendGeneration, 1);
    },
  );
}
