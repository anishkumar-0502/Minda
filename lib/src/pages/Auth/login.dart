import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../utilities/User_Model/user.dart';
import '../Home.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordControllers = TextEditingController();
  // final List<TextEditingController> _passwordControllers =
  //     List.generate(4, (_) => TextEditingController());

  String? storedUser;

  @override
  void initState() {
    super.initState();
    // Retrieve user data from shared preferences when the app starts
    _retrieveUserData();
  }

  Future<void> _retrieveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      storedUser = prefs.getString('user');
    });
  }

  Future<void> _login() async {
    String username = _usernameController.text;
    String password = _passwordControllers.text;

    try {
      var response = await http.post(
        Uri.parse('http://122.166.210.142:8052/CheckLoginCredentials'),

        body: {
          'loginUsername': username,
          'loginPassword': password,
        },
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('user', username);
        Provider.of<UserData>(context, listen: false).updateUserData(username);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => HomePage(
                    userinfo: username,
                  )),
        );
      } else {
        _showDialog('Error', 'Login failed');
      }
    } catch (e) {
      _showDialog('Error', 'An error occurred: $e');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return storedUser != null
        ? const HomePage() // Navigate to HomePage if user is already logged in
        : SafeArea(
            child: Scaffold(
              backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0), // Set background color to white
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0,bottom: 23, left: 12.0, right: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/Image/EV_Logo2.png',
                          height: 23,),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.asset(
                            'assets/Image/SM_logo.png',
                            height: 27,),
                        ),

                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            // margin: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Image.asset('assets/Image/homecar.png',width: 1500,),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0, right: 20.0,top: 15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Username',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white60
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: TextField(
                                        controller: _usernameController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter your username',
                                          hintStyle: TextStyle(color: Colors.white60),
                                          border: OutlineInputBorder(),
                                        ),
                                        style: TextStyle(color: Colors.white,),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Password',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white60,
                                      ),
                                    ),
                                    const SizedBox(height: 10.0),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: TextField(
                                        controller: _passwordControllers,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Enter your password',
                                          hintStyle: TextStyle(color: Colors.white60),

                                        ),
                                        style: TextStyle(color: Colors.white,),
                                      ),
                                    ),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: List.generate(
                                    //     _passwordControllers.length,
                                    //     (index) {
                                    //       return SizedBox(
                                    //         width: 50,
                                    //         child: TextField(
                                    //           controller:
                                    //               _passwordControllers[index],
                                    //           keyboardType: TextInputType.number,
                                    //           textAlign: TextAlign.center,
                                    //           obscureText: true,
                                    //           decoration: const InputDecoration(
                                    //             contentPadding:
                                    //                 EdgeInsets.symmetric(
                                    //               vertical: 10.0,
                                    //             ),
                                    //           ),
                                    //           onChanged: (value) {
                                    //             if (value.isNotEmpty &&
                                    //                 index <
                                    //                     _passwordControllers
                                    //                             .length -
                                    //                         1) {
                                    //               FocusScope.of(context)
                                    //                   .nextFocus();
                                    //             }
                                    //           },
                                    //         ),
                                    //       );
                                    //     },
                                    //   ),
                                    // ),
                                  ],
                                ),
                                const SizedBox(height: 40.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 23.0),
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 20.0),
                                        child: ElevatedButton(
                                          onPressed: _login,
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<Color>(
                                                    Colors.blue),
                                            foregroundColor:
                                                MaterialStateProperty.all<Color>(
                                                    Colors.white),
                                            padding: MaterialStateProperty.all<
                                                EdgeInsetsGeometry>(
                                              const EdgeInsets.symmetric(
                                                  vertical: 12.0, horizontal: 52.0),
                                            ),
                                          ),
                                          child: const Text(
                                            'Sign in',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 27.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterPage(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      text: const TextSpan(
                                        text: 'New User? ',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: ' Sign Up',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                                              ),

                                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
