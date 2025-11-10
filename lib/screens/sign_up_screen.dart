import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:image_picker/image_picker.dart';
import 'package:instaclone/screens/web_screen.dart';

import '../Data/auth_methods.dart';
import '../models/user_model.dart';
import '../responsive/responsive_layerscreen.dart';
import '../utils/color.dart';
import '../utils/utils.dart';
import '../widgets/text_field_input.dart';
import 'login_screen.dart';
import 'mobile_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30,),
                Flexible(
                  fit: FlexFit.loose,
                    flex: 2, child: Container()),
                SvgPicture.asset(
                  'assets/ic_instagram.svg',
                  color: primaryColor,
                  height: 64,
                ),
                const SizedBox(height: 64),
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                              'https://thumbs.dreamstime.com/z/default-avatar-profile-vector-user-profile-default-avatar-profile-vector-user-profile-profile-179376714.jpg',
                            ),
                          ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () {
                          selectImage();
                        },
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  textInputType: TextInputType.text,
                  controller: userNameController,
                  hintText: 'Username',
                ),
                const SizedBox(height: 24),
          
                TextFieldInput(
                  textInputType: TextInputType.emailAddress,
                  controller: emailController,
                  hintText: 'Email',
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  textInputType: TextInputType.text,
                  controller: passwordController,
                  hintText: 'Password',
                  isPassword: true,
                ),
                const SizedBox(height: 10),
                TextFieldInput(
                  textInputType: TextInputType.text,
                  controller: bioController,
                  hintText: 'Bio',
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try{
                    UserModel user = UserModel(
                      email: emailController.text,
                      password: passwordController.text,
                      bio: bioController.text,
                      userName: userNameController.text,
                    );
                    final result = await AuthMethods().signUp(user: user, file: _image, );
                    if (result.isSuccess != true) {
                      showSnackBar(result.message, context);
                    } else {
                      pushReplacement(
                        context,
                        const ResponsiveLayoutScreen(
                          mobileScreenLayout: MobileScreen(),
                          webScreenLayout: WebScreen(),
                        ),
                      );
                      }

                    } catch (e){
                      showSnackBar('SignUp failed: $e', context);
                    } finally{
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      color: blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: primaryColor),
                          )
                        : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(flex: 2, child: Container()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
          
                    GestureDetector(
                      onTap: () {
                        push(context, const LoginScreen());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text("Sign In"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void selectImage() async {
    Uint8List? image = await pickImage(ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }
}
