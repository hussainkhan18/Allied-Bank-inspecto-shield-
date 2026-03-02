import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hash_mufattish/LanguageTranslate/app_localizations.dart';
import 'package:hash_mufattish/Screens/HomeScreen.dart';
import 'package:loading_icon_button/loading_icon_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:hash_mufattish/services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  /*=========================================================
      SAVE TOKEN + USER DETAILS LOCALLY
  ==========================================================*/
  Future<void> saveUserLogin(Map jsonResponse) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", jsonResponse["access_token"]);
    await prefs.setInt("id", jsonResponse["user"]["id"]);
    await prefs.setString("name", jsonResponse["user"]["fullname"]);
    await prefs.setString("email", jsonResponse["user"]["email"]);
    await prefs.setString("password", password.text);
    await prefs.setString("image", jsonResponse["user"]["profile_img"]);
    await prefs.setString("contact", jsonResponse["user"]["contact_number"]);
    await prefs.setString("company", jsonResponse["user"]["company_name"]);
    await prefs.setString("branch", jsonResponse["user"]["branch_name"]);
    await prefs.setBool("isLoggedIn", true);
    print("USER LOGIN SAVED SUCCESSFULLY");
  }

  /*=========================================================
      LOGIN API
  ==========================================================*/
  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?>
      login() async {
    try {
      if (email.text.trim().isEmpty) {
        return ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Email required")));
      }
      if (password.text.trim().isEmpty) {
        return ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Password required")));
      }

      String? fcmToken = await NotificationService().getToken();

      final response = await http.post(
        Uri.parse('https://inspectoshield.com/api/login'),
        body: {
          "email": email.text,
          "password": password.text,
          if (fcmToken != null) "fcm_token": fcmToken,
        },
      );

      if (response.body.isEmpty) {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Server returned an empty response")),
        );
      }

      Map jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (e) {
        print("JSON Parse Error: $e");
        return ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid response from server: $e")),
        );
      }

      print("Response status: ${response.statusCode}");
      print(jsonResponse);

      if (response.statusCode != 200) {
        print("HTTP Error: ${response.statusCode}");
        return ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }

      if (jsonResponse["success"] == true) {
        await saveUserLogin(jsonResponse);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${AppLocalizations.of(context)!.translate("Welcome")} ${jsonResponse["user"]["fullname"]}",
            ),
          ),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                id: jsonResponse["user"]["id"],
                name: jsonResponse["user"]["fullname"],
                company: jsonResponse["user"]["company_name"],
                branch: jsonResponse["user"]["branch_name"],
                email: jsonResponse["user"]["email"],
                password: password.text,
                image: jsonResponse["user"]["profile_img"],
                contact: jsonResponse["user"]["contact_number"],
              ),
            ),
          );
        }
      } else {
        if (jsonResponse["message"] is String) {
          return ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse["message"])),
          );
        } else {
          if (jsonResponse["message"]["email"] != null) {
            return ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse["message"]["email"][0])),
            );
          }
          if (jsonResponse["message"]["password"] != null) {
            return ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(jsonResponse["message"]["password"][0])),
            );
          }
        }
      }
      return null;
    } catch (e) {
      print("Login Error: $e");
      return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: $e")),
      );
    }
  }

  /*=========================================================
      UI
  ==========================================================*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ── Logo ──────────────────────────────────────
              Image.asset("assets/allied_icon.png", scale: 6),

              const SizedBox(height: 36),

              // ── Card ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE4E8EF), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 26,
                      spreadRadius: 4,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Text(
                      AppLocalizations.of(context)!.translate('Sign In'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter your credentials to continue",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontFamily: "Poppins",
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Email
                    _fieldLabel(
                        AppLocalizations.of(context)!.translate('Email')),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: email,
                      hint: AppLocalizations.of(context)!.translate('Email'),
                      prefixIcon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 20),

                    // Password
                    _fieldLabel(
                        AppLocalizations.of(context)!.translate('Password')),
                    const SizedBox(height: 8),
                    _inputField(
                      controller: password,
                      hint: AppLocalizations.of(context)!.translate('Password'),
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),

                    const SizedBox(height: 28),

                    // Sign In Button
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return ArgonButton(
                          width: constraints.maxWidth,
                          height: 50,
                          borderRadius: 10.0,
                          elevation: 0,
                          color: const Color(0xFF1A1A2E),
                          borderSide: const BorderSide(color: Colors.blue),
                          child: Text(
                            AppLocalizations.of(context)!.translate('SIGN IN'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                              fontFamily: "Poppins",
                            ),
                          ),
                          onTap: (startLoading, stopLoading, btnState) =>
                              login(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*======================== Widgets ===========================*/

  Widget _fieldLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
          fontFamily: "Poppins",
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
  }) =>
      Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDDE1E7)),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? _obscurePassword : false,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: "Poppins",
            color: Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontFamily: "Poppins",
            ),
            prefixIcon: Icon(prefixIcon, color: Colors.grey.shade400, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
          ),
        ),
      );
}
