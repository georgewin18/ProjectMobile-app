import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:project_mobile/pages/home_page.dart';
import 'package:project_mobile/pages/main_page.dart';
import 'package:project_mobile/pages/reset_password_page.dart';
import 'package:project_mobile/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_mobile/pages/login_page.dart';
import 'package:project_mobile/pages/register_page.dart';
import 'package:project_mobile/pages/transaction_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  await dotenv.load();
  await SupabaseService.init();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _sub;
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() async {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((Uri? uri) {
      _handleUri(uri);
    });

    final initialUri = await _appLinks.getInitialAppLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }
  }

  void _handleUri(Uri? uri) {
    if (uri == null) return;

    // debugPrint("scheme: ${uri.scheme}");
    // debugPrint("host: ${uri.host}");
    // debugPrint("path: ${uri.path}");
    // debugPrint("code: ${uri.queryParameters['code']}");

    if (uri.host == 'reset-password') {
      final code = uri.queryParameters['code'];
      if (code != null) {
        widget.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(token: code),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      navigatorKey: widget.navigatorKey,
      title: 'Finance App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: session != null ? '/main' : '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/main': (context) => MainPage(),
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterPage(),
        '/transactions': (context) => TransactionPage(),
      },
    );
  }
}

