// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:pragati_1/Chatbot.dart';
import 'package:pragati_1/login_page.dart';

// void main() {
//   runApp(
//     StudentsLogin(),
//   );
// }

Color _gold = Color(0xFFD4A064);
Color _white = Color(0xFFF2F5F8);
Color _blue = Color(0xFF1C2541);
Color _red = Color(0xFFCC4E5C);
Color _blue_1 = Color(0xFF7f30fe);

class Students_Signup extends StatelessWidget {
  const Students_Signup({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUp(),
    );
  }
}

class SignUp extends StatefulWidget {
  const SignUp({Key? key});

  @override
  State<SignUp> createState() => _SignInState();
}

class _SignInState extends State<SignUp> {
  TextEditingController userMailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  TextEditingController userConfirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3.5,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_blue, _blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                    MediaQuery.of(context).size.width,
                    105.0,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Create your account",
                      style: TextStyle(
                        color: Color(0xFFbbb0ff),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 20.0,
                    ),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 50.0,
                          horizontal: 20.0,
                        ),
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyTextField(
                                  controller: userMailController,
                                  hintText: 'Enter your Mail',
                                  obscureText: false,
                                  prefixIcon: Icons.email,
                                ),
                                SizedBox(height: 20.0),
                                MyTextField(
                                  controller: userPasswordController,
                                  hintText: 'Enter your Password',
                                  obscureText: true,
                                  prefixIcon: Icons.lock,
                                ),
                                SizedBox(height: 20.0),
                                MyTextField(
                                  controller: userConfirmPasswordController,
                                  hintText: 'Confirm your Password',
                                  obscureText: true,
                                  prefixIcon: Icons.lock,
                                ),
                                SizedBox(height: 10.0),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApp()),
                                    );
                                    if (_formKey.currentState!.validate()) {
                                      // Perform login action
                                      if (_formKey.currentState!.validate()) {
                                        // Validate user input and perform login action
                                        bool isAuthenticated = false;
                                        //await api.login(
                                        //   userMailController.text,
                                        //   userPasswordController.text,
                                        // );

                                        if (isAuthenticated) {
                                          // If the user is authenticated, proceed with identified user logic
                                          // You can navigate to the next screen or perform other actions here
                                          // For example:
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MyApp()),
                                          );
                                        } else {
                                          // If the user is not authenticated, display an error message
                                          // For example:
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Invalid credentials. Please try again.'),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  child: Center(
                                    child: Container(
                                      width: 130,
                                      child: Material(
                                        elevation: 5.0,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [_blue, _blue],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Sign Up",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentsLogin()),
                          );
                          // Navigate to sign up screen
                        },
                        child: Text(
                          " Log In !",
                          style: TextStyle(
                            color: Color(0xFF7f30fe),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  final String? hintText;
  final bool obscureText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const MyTextField({
    Key? key,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: Colors.black38,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: _blue,
          ),
          border: InputBorder.none,
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: _blue,
                )
              : null,
        ),
      ),
    );
  }
}
