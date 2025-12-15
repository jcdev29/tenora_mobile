import 'package:flutter/material.dart';
import 'package:tenora_mobile/presentation/complaints/file_complaints_screen.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/contract/contract_detail_screen.dart';
import '../presentation/payments/payments_screen.dart';
import '../presentation/payments/payment_proof_screen.dart';
import '../presentation/payments/payment_methods_screen.dart';
import '../presentation/complaints/complaints_screen.dart';
import '../presentation/profile/profile_screen.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String contract = '/contract';
  static const String payments = '/payments';
  static const String paymentProof = '/payment-proof';
  static const String paymentMethods = '/payment-methods';
  static const String complaints = '/complaints';
  static const String fileComplaint = '/file-complaint';
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
      
      case complaints:
        return MaterialPageRoute(builder: (_) => const ComplaintsScreen());
      
      case fileComplaint:
        return MaterialPageRoute(builder: (_) => const FileComplaintScreen());
      
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