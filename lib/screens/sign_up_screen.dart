import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/resources/auth_methos.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/screens/login_screen.dart';
import 'package:instagram/screens/web_screen.dart';
import 'package:instagram/utils/utils.dart';
import '../responsive/responsive_layout_screen.dart';
import '../utils/colors.dart';
import '../widgets/text_field_input.dart';
import 'mobile_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Container(), flex: 2,),
              SvgPicture.asset(
                'assets/ic_instagram.svg', color: primaryColor, height: 64,),
              const SizedBox(height: 64,),
              Stack(
                children: [
                  _image != null? CircleAvatar(
              radius: 64,
                backgroundImage:MemoryImage(_image!))
                  :const CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(
                        'https://thumbs.dreamstime.com/z/default-avatar-profile-vector-user-profile-default-avatar-profile-vector-user-profile-profile-179376714.jpg'),
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: () {
                         selectImage();
                      }, icon: const Icon(Icons.add_a_photo),),),


                ],
              ),
              const SizedBox(height: 24,),
              TextFieldInput(textInputType: TextInputType.text,
                  controller: userNameController,
                  hintText: 'Username'),
              const SizedBox(height: 24,),

              TextFieldInput(textInputType: TextInputType.emailAddress,
                  controller: emailController,
                  hintText: 'Email'),
              const SizedBox(height: 24,),
              TextFieldInput(textInputType: TextInputType.text,
                controller: passwordController,
                hintText: 'Password',
                isPassword: true,),
              const SizedBox(height: 10,),
              TextFieldInput(textInputType: TextInputType.text,
                  controller: bioController,
                  hintText: 'Bio'),
              const SizedBox(height: 24,),
              GestureDetector(
                onTap: ()async{
                  setState(() {
                    _isLoading = true;
                  });
                  UserModel user = UserModel(email: emailController.text,
                    password: passwordController.text,
                    bio: bioController.text,
                    userName: userNameController.text,);
                  final res = await AuthMethods().signUpUser(user,_image!);
                  if(res != 'Success'){
                    showSnackBar('Something is wrong try again', context);
                  }else{
                    setState(() {
                      _isLoading= false;
                    });
                    pushReplacement(context, const ResponsiveLayoutScreen(mobileScreenLayout: MobileScreen(), webScreenLayout: WebScreen()));

                  }
                },
                child: Container(
                  child: _isLoading? const Center(child: CircularProgressIndicator(color: primaryColor,),):const Text('Sign Up'),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    color: blueColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4))
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12,),
              Flexible(child: Container(), flex: 2,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text("Don't have an account?"),

                  GestureDetector(
                    onTap: (){
                      push(context, const LoginScreen());

                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text("Sign Up"),),
                  ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }

  void selectImage()async {
  Uint8List image =  await pickImage(ImageSource.gallery);
  setState(() {
    _image = image;
  });
  }
}
