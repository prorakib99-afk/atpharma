import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../bloc/registration/registration_bloc.dart';
import 'otp_screen.dart';

class AuthOtpPage extends StatelessWidget {
  const AuthOtpPage({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocConsumer<RegistrationBloc, RegistrationState>(
        listener: (context, state) {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          if (state.status == RegistrationStatus.verified) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Success! Verification completed.')),
            );
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
          } else if (state.status == RegistrationStatus.failure ||
              state.status == RegistrationStatus.resent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Unable to verify code.'),
              ),
            );
          }
        },
        builder: (context, state) => OtpScreen(
          destination: state.identifier,
          isLoading: state.isLoading,
          resendGeneration: state.resendGeneration,
          onVerify: (code) async =>
              context.read<RegistrationBloc>().add(VerificationSubmitted(code)),
          onResend: state.registration
              ? () async => context.read<RegistrationBloc>().add(
                  const VerificationResendRequested(),
                )
              : null,
        ),
      );
}
