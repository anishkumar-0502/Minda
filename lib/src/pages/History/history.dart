import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../components/elevationbutton.dart';
import 'sessiondetails.dart';
import 'package:http/http.dart' as http;

class CustomGradientDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height:1.2, // Adjust this to change the overall height of the divider
      child: CustomPaint(
        painter: GradientPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class GradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
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

class historypage extends StatefulWidget {
  final String? username; // Make the username parameter nullable
  const historypage({super.key, this.username});

  @override
  State<historypage> createState() => _historypageState();
}

class _historypageState extends State<historypage> {
  String activeTab = 'history'; // Initial active tab
  List<Map<String, dynamic>> SessionDetails = [];

  @override
  void initState() {
    super.initState();
    fetchChargingSessionDetails();
  }

  // Function to set session details
  void setSessionDetails(List<Map<String, dynamic>> value) {
    setState(() {
      SessionDetails = value;
    });
  }

  // Function to fetch charging session details
  void fetchChargingSessionDetails() async {
    String? username = widget.username;

    try {
      var response = await http.get(Uri.parse(
          // 'http://192.168.1.33:8052/getChargingSessionDetails?username=$username'));
          'http://122.166.210.142:8052/getChargingSessionDetails?username=$username'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['value'] is List) {
          List<dynamic> chargingSessionData = data['value'];
          List<Map<String, dynamic>> sessionDetails =
              chargingSessionData.cast<Map<String, dynamic>>();
          setSessionDetails(sessionDetails);
        } else {
          throw Exception('Session details format is incorrect');
        }
      } else {
        throw Exception('Failed to load session details');
      }
    } catch (error) {
      print('Error fetching session details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                    'History',
                    style: TextStyle(color: Colors.white,fontSize: 20),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child:  SingleChildScrollView(
            child: Scrollbar(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, left: 25),
                    child: Container(
                      child: const Row(
                        children: [
                          Text(
                            'Session History',
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.white

                            ),
                          ),
                          SizedBox(width: 10.0),
                          Icon(
                            Icons.history,
                            color: Colors.white,
                            size: 33,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SessionDetails.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromRGBO(23, 27, 44, 1.0),
                          borderRadius: BorderRadius.circular(10.0), border: Border.all(color: Colors.white)

                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: const Center(
                        child: Text(
                          ' session history not found.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, bottom: 90),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromRGBO(23, 27, 44, 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.white)
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Column(
                              children: [
                                for (int index = 0;
                                index < SessionDetails.length;
                                index++)
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              sessiondetailspage(
                                                  sessionData:
                                                  SessionDetails[index]),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(3.5),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      SessionDetails[index]
                                                      ['ChargerID']
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontSize: 19,
                                                        color: Colors.white,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      SessionDetails[index][
                                                      'StartTimestamp'] !=
                                                          null
                                                          ? DateFormat(
                                                          'MM/dd/yyyy, hh:mm:ss a')
                                                          .format(
                                                        DateTime.parse(
                                                            SessionDetails[
                                                            index]
                                                            [
                                                            'StartTimestamp'])
                                                            .toLocal(),
                                                      )
                                                          : "-",
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white60,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '- Rs. ${SessionDetails[index]['price']}',
                                                    style: const TextStyle(
                                                      fontSize: 19,
                                                      color: Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    '${SessionDetails[index]['Unitconsumed']} Kwh',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white60,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        if (index != SessionDetails.length - 1)
                                          CustomGradientDivider(),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}
