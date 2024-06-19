import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordControllers = TextEditingController();
  // final List<TextEditingController> _passwordControllers =
  //     List.generate(4, (_) => TextEditingController());

  void _handleRegister() async {
    final String username = _usernameController.text;
    final String phone = _phoneController.text;
    final String password = _passwordControllers.text;

    // final String password = _passwordControllers.map((c) => c.text).join('');

    // Validation can be more robust depending on requirements
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(username)) {
      _showAlert('Username must contain only letters.');
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      _showAlert('Phone number must be a 10-digit number.');
      return;
    }

    if (!RegExp(r'^\d{4}$').hasMatch(password)) {
      _showAlert('Password must be a 4-digit number.');
      return;
    }

    try {
      var response = await http.post(
        // Uri.parse('http://192.168.1.11:8052/RegisterNewUser'),
        Uri.parse('http://122.166.210.142:8052/RegisterNewUser'),

        body: {
          'registerUsername': username,
          'registerPhone': phone,
          'registerPassword': password,
        },
      );

      if (response.statusCode == 200) {
        // Handle successful registration
        Navigator.pop(
            context); // Assuming you want to pop back after registration
      } else {
        _showAlert('Registration failed');
      }
    } catch (e) {
      _showAlert('An error occurred: $e');
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0),  // Set background color to white

        body: Column(
          children: [
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
            Expanded(child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Image.asset('assets/Image/homecar.png',width: 1500,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0, right: 23.0,top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: 'Enter your username',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: Colors.white,),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0, right: 23.0, top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white60
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: 'Enter your phoneno',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: Colors.white,),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0, right: 23.0, top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white60
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          TextField(
                            controller: _passwordControllers,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Enter your pasword',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(color: Colors.white,),
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: List.generate(_passwordControllers.length,
                          //           (index) {
                          //         return SizedBox(
                          //           width: 50,
                          //           child: TextField(
                          //             controller: _passwordControllers[index],
                          //             keyboardType: TextInputType.number,
                          //             textAlign: TextAlign.center,
                          //             obscureText: true,
                          //             decoration: const InputDecoration(
                          //               contentPadding: EdgeInsets.symmetric(
                          //                 vertical: 10.0,
                          //               ),
                          //             ),
                          //             onChanged: (value) {
                          //               if (value.isNotEmpty &&
                          //                   index <
                          //                       _passwordControllers.length - 1) {
                          //                 FocusScope.of(context).nextFocus();
                          //               }
                          //             },
                          //           ),
                          //         );
                          //       }),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 23.0),
                          child: Container(
                            margin: const EdgeInsets.only(right: 20.0),
                            child: ElevatedButton(
                              onPressed: _handleRegister,
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
                                'Sign up',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0,bottom: 50),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LoginPage(
                              title: 'LoginPage',
                            ),
                          ));
                        },
                        child: RichText(
                          text: const TextSpan(
                            text:
                            'Already an User ? ', // Added a space after "New User?"
                            style: TextStyle(
                              color: Colors.white60,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: ' Sign in',
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
          ],
        ),
      ),
    );
  }
}
