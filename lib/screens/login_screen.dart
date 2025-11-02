import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instaclone/screens/sign_up_screen.dart';
import 'package:instaclone/screens/web_screen.dart';

import '../Data/auth_methods.dart';
import '../responsive/responsive_layerscreen.dart';
import '../utils/color.dart';
import '../utils/utils.dart';
import '../widgets/text_field_input.dart';
import 'mobile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: Container(),
              ),
              SvgPicture.asset(
                'assets/ic_instagram.svg',
                color: primaryColor,
                height: 64,
              ),
              const SizedBox(
                height: 64,
              ),
              TextFieldInput(
                  textInputType: TextInputType.emailAddress,
                  controller: emailController,
                  hintText: 'Email'),
              const SizedBox(
                height: 24,
              ),
              TextFieldInput(
                textInputType: TextInputType.text,
                controller: passwordController,
                hintText: 'Password',
                isPassword: true,
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  String res = await AuthMethods()
                      .loginUser(emailController.text, passwordController.text);
                  if (res == "Success") {
                    showSnackBar(res, context);
                    pushReplacement(context, const ResponsiveLayoutScreen(mobileScreenLayout: MobileScreen(), webScreenLayout: WebScreen()));

                  }
                  setState(() {
                    _isLoading = false;
                  });
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    color: blueColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                  ),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Flexible(
                flex: 2,
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text("Don't have an account?"),
                  ),
                  GestureDetector(
                    onTap: () {
                      push(context, const SignUpScreen());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text("Sign Up"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
