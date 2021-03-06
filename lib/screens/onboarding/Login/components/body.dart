import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import './background.dart';
import '../../../../constant.dart';
import '../../../../utilities/api_helper.dart';
import '../../../../utilities/http_exception.dart';
import '../../Signup/signup_screen.dart';
import '../../../../widgets/alreadyHaveAccount.dart';
import '../../../../widgets/textFieldContainer.dart';
import '../../../../widgets/roundedButton.dart';
import '../../../../widgets/rounded_input_field.dart';
import '../../../../utilities/auth_helper.dart' as authHelper;
import '../../forgot_password.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordHidden = true;
  bool _forgotpass = false;
  var _email;
  var _password;

  _signIn() async {
    final isValid = _formKey.currentState.validate();
    if (!isValid) return;
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await authHelper.logIn(_email.trim(), _password.trim());
      print('uID: ${ApiHelper().getUID()}');
      Flushbar(
        message: "Logged In Successfully!",
        duration: Duration(seconds: 3),
      )..show(context);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/profile', (Route<dynamic> route) => false);
    } on HttpException catch (error) {
      Flushbar(
        message: '${error.toString()}',
        duration: Duration(seconds: 3),
      )..show(context);
    } catch (error) {
      print(error);
      Flushbar(
        message: "Error Logging In",
        duration: Duration(seconds: 3),
      )..show(context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: _forgotpass
            ? ForgotPassword(() {
                setState(() {
                  _forgotpass = !_forgotpass;
                });
              })
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "LOGIN",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SvgPicture.asset(
                      "assets/icons/login.svg",
                      height: size.height * 0.35,
                    ),
                    SizedBox(height: size.height * 0.03),
                    RoundedInputField(
                      onSaved: (value) {
                        _email = value;
                      },
                      hintText: "Your Email",
                    ),
                    TextFieldContainer(
                      child: TextFormField(
                        obscureText: _isPasswordHidden,
                        cursorColor: kPrimaryColor,
                        decoration: InputDecoration(
                          hintText: "Password",
                          icon: Icon(
                            Icons.lock,
                            color: kPrimaryColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_isPasswordHidden
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: kPrimaryColor,
                            onPressed: () {
                              setState(() {
                                _isPasswordHidden = !_isPasswordHidden;
                              });
                            },
                          ),
                          border: InputBorder.none,
                        ),
                        onSaved: (value) {
                          _password = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Password can\'t be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    (_isLoading)
                        ? SpinKitThreeBounce(
                            color: Theme.of(context).primaryColor,
                          )
                        : RoundedButton(
                            text: "LOGIN",
                            press: () {
                              _signIn();
                            },
                          ),
                    SizedBox(height: size.height * 0.03),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _forgotpass = !_forgotpass;
                          });
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: kPrimaryColor),
                        )),
                    SizedBox(height: size.height * 0.03),
                    AlreadyHaveAnAccountCheck(
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SignUpScreen();
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
