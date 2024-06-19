import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/pages/Auth/login.dart';
import 'src/pages/History/history.dart';
import 'src/pages/Home.dart';
import 'src/pages/Wallet/wallet.dart'; // Import the Wallet page
import 'src/pages/profile/profile.dart';
import 'src/pages/profile/settings/settings.dart';
import 'src/utilities/User_Model/user.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserData()),
      ],
      child: const MyApp(),
    ),
  );
}

class SessionHandler extends StatefulWidget {
  final bool loggedIn;

  const SessionHandler({Key? key, this.loggedIn = false}) : super(key: key);

  @override
  State<SessionHandler> createState() => _SessionHandlerState();
}
class _SessionHandlerState extends State<SessionHandler> {
  @override
  void initState() {
    super.initState();
    _retrieveUserData();
  }

  Future<void> _retrieveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUser = prefs.getString('user');
    // Access UserData provider and update user data
    Provider.of<UserData>(context, listen: false).updateUserData(storedUser!);
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return userData.username != null
        ? HomePage(userinfo: userData.username)
        : const LoginPage(title: 'Login');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    final ThemeData customTheme = ThemeData(
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );

    return ChangeNotifierProvider<UserData>(
      create: (_) => UserData(), // Initialize UserData provider
      child: MaterialApp(
        title: 'EV',
        debugShowCheckedModeBanner: false,
        theme: customTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SessionHandler(),
          '/home': (context) => const SessionHandler(loggedIn: true),
          '/wallet': (context) {
            final username =
                ModalRoute.of(context)!.settings.arguments as String;
            return WalletPage(
              username: username,
            );
          },
          '/history': (context) {
            final username =
                ModalRoute.of(context)!.settings.arguments as String;
            return historypage(
              username: username,
            );
          },
          '/profile': (context) {
            final username =
                ModalRoute.of(context)!.settings.arguments as String;
            return profilepage(
              username: username,
            );
          },
          '/Settings': (context) {
            final username =
                ModalRoute.of(context)!.settings.arguments as String;
            return ProfileSettingPage(
              username: username,
            );
          },
        },
      ),
    );
  }
}
