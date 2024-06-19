import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/elevationbutton.dart';
import '../Wallet/wallet.dart';
import '../History/history.dart';
import './help/help.dart';
import './settings/settings.dart';
import '../Auth/login.dart';
import '../../utilities/User_Model/user.dart'; // Import the UserData model
import 'package:provider/provider.dart';

class profilepage extends StatefulWidget {
  final String? username; // Make the username parameter nullable
  const profilepage({super.key, this.username});

  @override
  State<profilepage> createState() => _profilepageState();
}

class _profilepageState extends State<profilepage> {
  String activeTab = 'profile'; // Initial active tab

  void setActiveTab(String newTab) {
    // Define the callback
    setState(() {
      activeTab = newTab;
    });
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user'); // Remove the user data from shared preferences

    // Clear user data from the provider
    Provider.of<UserData>(context, listen: false).clearUser();

    // Navigate to the login page and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(title: 'LoginPage'),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    String? username = widget.username;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0), // Set background color to white
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40.0,bottom: 23, left: 12.0, right: 12.0),
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white, // Border color
                  width: 2.0, // Border width
                ),
                borderRadius: BorderRadius.circular(10.0), // Border radius
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate back to previous page
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 30, // Increased icon size
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // Added space between icon and text
                  Text(
                    'Profile',
                    style: TextStyle(color: Colors.white,fontSize: 20),
                  )
                ],
              ),
            ),
          ),
          Expanded(child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20.0),
                  const Icon(
                    Icons.account_circle_rounded,
                    size: 120,
                    color: Colors.white,
                  ),
                  Text(
                    username ??
                        '', // Use username parameter, or an empty string if null
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25,color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WalletPage(
                                    username: username,
                                  )),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            width: 120,
                            decoration: BoxDecoration(
                                color: const Color.fromRGBO(23, 27, 44, 1.0),
                                borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                                border: Border.all(color: Colors.white)
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.wallet_outlined,
                                  size: 43,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Wallet',
                                  style: TextStyle(fontSize: 20, color: Colors.white,),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => historypage(
                                    username: username,
                                  )),
                            );
                          },
                          child: Container(
                            width: 120,
                            padding: const EdgeInsets.all(
                                15), // Add padding to each container
                            decoration: BoxDecoration(
                                color: const Color.fromRGBO(23, 27, 44, 1.0),
                                borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                                border: Border.all(color: Colors.white)
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 43,
                                  color: Colors.white,
                                ),
                                Text(
                                  'History',
                                  style: TextStyle(fontSize: 20, color: Colors.white,),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, left: 18, right: 18),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProfileSettingPage(username: username)),
                        );
                      },
                      child: Container(
                        padding:
                        const EdgeInsets.all(16), // Padding inside the container
                        decoration: BoxDecoration(
                            color:  const Color.fromRGBO(23, 27, 44, 1.0),// Background color
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            border: Border.all(color: Colors.white)
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.settings,
                              size: 30,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Settings',
                                style: TextStyle(fontSize: 20,color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, left: 18, right: 18),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpPage()),
                        );
                      },
                      child: Container(
                        padding:
                        const EdgeInsets.all(16), // Padding inside the container
                        decoration: BoxDecoration(
                            color:  const Color.fromRGBO(23, 27, 44, 1.0), // Background color
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            border: Border.all(color: Colors.white)
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info,
                              size: 30,
                              color: Colors.white,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Help',
                                style: TextStyle(fontSize: 20,color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, left: 18, right: 18,bottom: 130),
                    child: GestureDetector(
                      onTap: () {
                        _logout(context); // Call _logout method on tap
                      },
                      child: Container(
                        padding:
                        const EdgeInsets.all(16), // Padding inside the container
                        decoration: BoxDecoration(
                            color:  const Color.fromRGBO(23, 27, 44, 1.0), // Background color
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                            border: Border.all(color: Colors.white)
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 30,
                              color: Colors.red,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text(
                                'Logout',
                                style: TextStyle(fontSize: 20, color: Colors.red),
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
          ),)

        ],
      ),
      floatingActionButton: FloatingButton(
        activeTab: activeTab, onDispose: () {  },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
