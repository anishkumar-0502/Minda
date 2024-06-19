import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/elevationbutton.dart'; // Corrected import path

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key); // Corrected capitalization

  @override
  State<HelpPage> createState() => _HelpPageState(); // Corrected capitalization
}

class _HelpPageState extends State<HelpPage> {
  String activeTab = 'profile';
  // Initial active tab

  void setActiveTab(String newTab) {
    // Define the callback
    setState(() {
      activeTab = newTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0),// Set background color to white
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
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 30, // Increased icon size
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Added space between icon and text
                    const Text(
                      'Help',
                      style: TextStyle(color: Colors.white,fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
            Expanded(child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0,left: 13,right: 13),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(23, 27, 44, 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.white)
                    ),
                    child: Column(
                      children: [
                        Text(
                          'NEED HELP? CONTACT US!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0,left: 13,right: 13),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white, // Border color
                        width: 2.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(10.0), // Border radius
                    ),

                    child: const Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'If you require assistance or have any questions, feel free to reach out to us via email or WhatsApp.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.email,color: Colors.green,size: 25,),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text('Email ID:',style: TextStyle(color: Colors.green,fontSize: 23,fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                            Text('evpower@gmail.com',style: TextStyle(color: Colors.white60,fontSize: 20),)
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.phone,color: Colors.green,size: 25,),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text('Whatsapp:',style: TextStyle(color: Colors.green,fontSize: 23,fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text('1234567890',style: TextStyle(color: Colors.white60,fontSize: 20),),
                            )
                          ],
                        ),
                      ],
                    ),

                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: Text(
                      "We're here to help you!",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ))

          ],
        ),

      floatingActionButton: FloatingButton(
        activeTab: activeTab, onDispose: () {  },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

