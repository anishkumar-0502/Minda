import 'package:flutter/material.dart';
import '../pages/home.dart'; // Adjust to your project's structure
import '../pages/Wallet/wallet.dart';
import '../pages/History/history.dart'; // Adjust import paths accordingly
import '../pages/profile/profile.dart';
import '../utilities/User_Model/user.dart'; // Import the UserData model
import 'package:provider/provider.dart';

class FloatingButton extends StatefulWidget {
  const FloatingButton({super.key, required this.activeTab, required this.onDispose});

  final String activeTab;
  final VoidCallback onDispose;

  @override
  _FloatingButtonState createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> {
  void _navigateTo(BuildContext context, Widget targetPage) {
    widget.onDispose();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: 30.0,
        bottom: 10.0,
      ), // Additional padding for the floating button
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(23, 27, 44, 1.0), // Base color
              Color.fromRGBO(23, 27, 44, 1.0), // Base color to create a 75% black gradient
              Colors.green, // Green color at the bottom
            ],
            stops: [0.50,0.75, 1.0], // Positions of the colors
          ),
          borderRadius: BorderRadius.circular(10),

        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.activeTab != 'home') {
                        _navigateTo(
                          context,
                          HomePage(
                            userinfo: userData.username,
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home,
                          color: widget.activeTab == 'home'
                              ? Colors.white
                              : Colors.white60,
                          size: 35,
                        ),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: widget.activeTab == 'home'
                                ? Colors.white
                                : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.activeTab != 'wallet') {
                        _navigateTo(
                          context,
                          WalletPage(
                            username: userData.username,
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wallet_outlined,
                          color: widget.activeTab == 'wallet'
                              ? Colors.white
                              : Colors.white60,
                          size: 35,
                        ),
                        Text(
                          'Wallet',
                          style: TextStyle(
                            color: widget.activeTab == 'wallet'
                                ? Colors.white
                                : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.activeTab != 'history') {
                        _navigateTo(
                          context,
                          historypage(
                            username: userData.username,
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          color: widget.activeTab == 'history'
                              ?  Colors.white
                              : Colors.white60,
                          size: 35,
                        ),
                        Text(
                          'History',
                          style: TextStyle(
                            color: widget.activeTab == 'history'
                                ?  Colors.white
                                : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.activeTab != 'profile') {
                        _navigateTo(
                          context,
                          profilepage(
                            username: userData.username,
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_circle,
                          color: widget.activeTab == 'profile'
                              ?  Colors.white
                              : Colors.white60,
                          size: 35,
                        ),
                        Text(
                          'Profile',
                          style: TextStyle(
                            color: widget.activeTab == 'profile'
                                ?  Colors.white
                                : Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
}
