import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/otp_screen.dart';
import 'features/auth/presentation/screens/profile_screen.dart';
import 'features/auth/presentation/screens/signup_screen.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/cart/provider/cart_provider.dart';
import 'features/orders/provider/orders_provider.dart';
import 'features/catalog/presentation/screens/home_screen.dart';
import 'features/catalog/presentation/screens/product_detail_screen.dart';
import 'features/cart/presentation/screens/cart_screen.dart';
import 'features/checkout/presentation/screens/checkout_screen.dart';
import 'features/checkout/presentation/screens/order_success_screen.dart';
import 'features/orders/presentation/screens/order_history_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SnapBuy',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.home,
        onGenerateRoute: (settings) {
          late final Widget page;

          switch (settings.name) {
            case AppRoutes.home:
              page = const AuthGate();
              break;
            case AppRoutes.productDetail:
              page = const ProductDetailScreen();
              break;
            case AppRoutes.cart:
              page = const CartScreen();
              break;
            case AppRoutes.checkout:
              page = const CheckoutScreen();
              break;
            case AppRoutes.orderSuccess:
              page = const OrderSuccessScreen();
              break;
            case AppRoutes.orders:
              page = const OrderHistoryScreen();
              break;
            case AppRoutes.profile:
              page = const ProfileScreen();
              break;
            case AppRoutes.login:
              page = const LoginScreen();
              break;
            case AppRoutes.signup:
              page = const SignUpScreen();
              break;
            case AppRoutes.otp:
              page = const OtpScreen();
              break;
            default:
              page = const AuthGate();
          }

          return PageRouteBuilder(
            settings: settings,
            transitionDuration: const Duration(milliseconds: 380),
            reverseTransitionDuration: const Duration(milliseconds: 280),
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );

                  return FadeTransition(
                    opacity: Tween<double>(begin: 0.2, end: 1).animate(curved),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoggedIn) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}
