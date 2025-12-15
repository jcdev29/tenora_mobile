import 'package:flutter/material.dart';
import 'package:tenora_mobile/presentation/requests/file_request_screen.dart';
import 'package:tenora_mobile/presentation/requests/requests_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/contract/contract_detail_screen.dart';
import '../presentation/payments/payments_screen.dart';
import '../presentation/payments/payment_proof_screen.dart';
import '../presentation/payments/payment_methods_screen.dart';
import '../presentation/utilities/utilities_screen.dart';
import '../presentation/utilities/submit_reading_screen.dart';
import '../presentation/utilities/reading_history_screen.dart';
import '../presentation/profile/profile_screen.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String contract = '/contract';
  static const String payments = '/payments';
  static const String paymentProof = '/payment-proof';
  static const String paymentMethods = '/payment-methods';
  static const String utilities = '/utilities';
  static const String submitReading = '/submit-reading';
  static const String readingHistory = '/reading-history';
  static const String requests = '/requests';
  static const String fileRequest = '/file-request';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case contract:
        return MaterialPageRoute(builder: (_) => const ContractDetailScreen());
      
      case payments:
        return MaterialPageRoute(builder: (_) => const PaymentsScreen());
      
      case paymentProof:
        final paymentId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PaymentProofScreen(paymentId: paymentId),
        );
      
      case paymentMethods:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());
      
      case utilities:
        return MaterialPageRoute(builder: (_) => const UtilitiesScreen());
      
      case submitReading:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SubmitReadingScreen(
            utilityType: args['utilityType'],
            meterType: args['meterType'],
          ),
        );
      
      case readingHistory:
        final utilityType = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ReadingHistoryScreen(utilityType: utilityType),
        );
      
      case requests:
        return MaterialPageRoute(builder: (_) => const RequestsScreen());
      
      case fileRequest:
        return MaterialPageRoute(builder: (_) => const FileRequestScreen());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}