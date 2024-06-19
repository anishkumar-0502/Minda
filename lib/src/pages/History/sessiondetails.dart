import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../components/elevationbutton.dart';
import 'package:intl/intl.dart';

class CustomGradientDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height:1.2, // Adjust this to change the overall height of the divider
      child: CustomPaint(
        painter: GradientPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class GradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        colors: [
          Color.fromRGBO(0, 0, 0, 0.75), // Darker black shade
          Color.fromRGBO(0, 128, 0, 0.75), // Darker green for blending
          Colors.green, // Green color in the middle
        ],
        end: Alignment.center,

      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, size.height * 0.0)
      ..quadraticBezierTo(size.width / 3, 0, size.width, size.height * 0.99)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class sessiondetailspage extends StatefulWidget {
  final String? username; // Make the username parameter nullable
  final Map<String, dynamic> sessionData;
  const sessiondetailspage({Key? key, this.username, required this.sessionData})
      : super(key: key);

  @override
  State<sessiondetailspage> createState() => _sessiondetailspageState();
}

class _sessiondetailspageState extends State<sessiondetailspage> {
  String activeTab = 'history'; // Initial active tab

  void setActiveTab(String newTab) {
    // Define the callback
    setState(() {
      activeTab = newTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? username = widget.username;
    Map<String, dynamic> sessionData = widget.sessionData;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0), // Set background color to white
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
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
                  const SizedBox(width: 16), // Added space between icon and text
                  const Text(
                    'Session Details',
                    style: TextStyle(color: Colors.white,fontSize: 20),
                  )
                ],
              ),
            ),
          ),
          Expanded(child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.only(top: 15.0), // Adjust the value as needed
                    child: Image.asset(
                      'assets/Image/sessionDetails.jpg',
                      width: 1000,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        bottom: 100,
                        top: 20), // Add margin at the bottom of the container
                    width: 320,
                    padding: const EdgeInsets.all(13.0),
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(23, 27, 44, 1.0),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.white)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                            'Charger ID', sessionData['ChargerID'].toString()),
                        CustomGradientDivider(),
                        _buildDetailRow('Charger Session ID',
                            sessionData['ChargingSessionID'].toString()),
                        CustomGradientDivider(),
                        _buildDetailRow(
                          'Start Time',
                          sessionData['StartTimestamp'] != null
                              ? DateFormat('MM/dd/yyyy, hh:mm:ss a').format(
                            DateTime.parse(sessionData['StartTimestamp'])
                                .toLocal(),
                          )
                              : "-",
                        ),
                        CustomGradientDivider(),
                        _buildDetailRow(
                          'Stop Time',
                          sessionData['StopTimestamp'] != null
                              ? DateFormat('MM/dd/yyyy, hh:mm:ss a').format(
                            DateTime.parse(sessionData['StopTimestamp'])
                                .toLocal(),
                          )
                              : "-",
                        ),
                        CustomGradientDivider(),
                        _buildDetailRow('Unit Consumed',
                            sessionData['Unitconsumed'].toString()),
                        CustomGradientDivider(),
                        _buildDetailRow('Price', 'Rs. ${sessionData['price']}'),
                      ],
                    ),
                  )
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

  Widget _buildDetailRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8), // Add vertical spacing between rows
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.white
          ),
        ),
        const SizedBox(
            height: 4), // Add vertical spacing between title and value
        Text(
          value,
          style: const TextStyle(fontSize: 17,color: Colors.white60),
        ),
      ],
    );
  }
}
