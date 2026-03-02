import 'package:flutter/material.dart';
import 'package:hash_mufattish/Screens/internet_error_popup.dart';
import 'package:hash_mufattish/Screens/login.dart';
import 'package:hash_mufattish/Screens/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Just to show splash for a moment
    await Future.delayed(const Duration(seconds: 7));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // saved in login screen
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (token != null && token.isNotEmpty && isLoggedIn) {
      // Read stored user data
      final int? id = prefs.getInt('id');
      final String name = prefs.getString('name') ?? '';
      final String email = prefs.getString('email') ?? '';
      final String password = prefs.getString('password') ?? '';
      final String image = prefs.getString('image') ?? '';
      final String contact = prefs.getString('contact') ?? '';
      final String company = prefs.getString('company') ?? '';
      final String branch = prefs.getString('branch') ?? '';

      if (id != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => NetworkWrapper(
              child: HomeScreen(
                id: id,
                name: name,
                company: company,
                branch: branch,
                email: email,
                password: password,
                image: image,
                contact: contact,
              ),
            ),
          ),
        );
        return;
      }
    }

    // If no token or data is incomplete => go to LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NetworkWrapper(child: const LoginScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Image.asset(
          "assets/allied_splash.gif",
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
