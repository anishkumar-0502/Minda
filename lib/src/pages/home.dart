// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../components/elevationbutton.dart'; // Correct import
import './charging/charging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../pages/home.dart';



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

class HomePage extends StatefulWidget {
  final String? userinfo;
  final String? username;

  const HomePage({Key? key, this.userinfo, this.username}) : super(key: key); // Add const keyword here

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  String activeTab = 'home'; // Initial active tab
  List<String> recentSessionDetails = []; // To store the session details
  String searchChargerID = '';

  @override
  void initState() {
    super.initState();
    fetchRecentSessionDetails(); // Fetch data when the widget initializes
  }

  void fetchRecentSessionDetails() async {
    String? username = widget.userinfo;

    try {
      final response = await http.get(Uri.parse(
          'http://122.166.210.142:8052/getRecentSessionDetails?username=$username'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recentSessionDetails = List<String>.from(
              data['value']); // Assuming the response is a list of strings
        });
      } else {
        throw Exception('Failed to load recent session details');
      }
    } catch (error) {
      print('Error fetching Recent Charger: $error');
    }
  }

  Future<void> handleSearchRequest(String searchChargerID) async {
    String? username = widget.userinfo;

    try {
      final response = await http.post(
        Uri.parse('http://122.166.210.142:8052/SearchCharger'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            {'searchChargerID': searchChargerID, 'Username': username}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          this.searchChargerID = searchChargerID;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                chargingpage(searchChargerID: searchChargerID, username: username),
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorData['message']),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void handleSearchRecent(String searchChargerID) async {
    await handleSearchRequest(searchChargerID);
  }

  void setActiveTab(String newTab) {
    // Define the callback
    setState(() {
      activeTab = newTab;
    });
  }

void navigateToQRViewExample() async {
  final scannedCode = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (context) => QRViewExample(handleSearchRequestCallback: handleSearchRequest)),
  );

  if (scannedCode != null) {
    setState(() {
      searchChargerID = scannedCode;
    });
    handleSearchRequest(scannedCode);
  
        // Close the QR scanner after handling the scan result
    Navigator.of(context).pop();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0), // Adjusted alpha to 1
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 23, left: 12.0, right: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/Image/EV_Logo2.png',
                  height: 23,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.asset(
                    'assets/Image/SM_logo.png',
                    height: 27,
                  ),
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
                    child: Image.asset(
                      'assets/Image/homecar.png',
                      width: 1500,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 20.0, right: 20.0), // Adjust margin as needed
                            child: TextField(
                              onSubmitted: handleSearchRecent,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter Device ID',
                                hintStyle: const TextStyle(color: Colors.white),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(color: Colors.blue),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () => handleSearchRecent(searchChargerID),
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    child: const Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchChargerID = value;
                                });
                              },
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            navigateToQRViewExample();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 20.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey, // Border color
                                width: 1.3, // Border width
                              ),
                              borderRadius: BorderRadius.circular(10.0), // Border radius
                            ),
                            padding: const EdgeInsets.all(10.0),
                            child: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Aligns the row's children at the center horizontally
                      children: [
                        Center(
                          child: Text(
                            'Previously Used ',
                            style: TextStyle(
                              fontSize: 23,
                              color: Colors.white,
                            ),
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
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 100.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(23, 27, 44, 1.0), // Transparent background color
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.white), // White border
                      ),
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 18.0),
                      child: recentSessionDetails.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(14.0),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 15),
                                    Text(
                                      'Yet to charge ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white, // White text color
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.only(top: 17.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    for (int index = 0; index < recentSessionDetails.length; index++)
                                      InkWell(
                                        onTap: () {
                                          handleSearchRecent(recentSessionDetails[index]);
                                        },
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(5.5),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    recentSessionDetails[index],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white, // White text color
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (index != recentSessionDetails.length - 1) CustomGradientDivider(),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
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
      floatingActionButton: FloatingButton(
        activeTab: activeTab, onDispose: () {  },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
  
}

class QRViewExample extends StatefulWidget {
  final Function(String) handleSearchRequestCallback; // Add function parameter

  const QRViewExample({Key? key, required this.handleSearchRequestCallback})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        (MediaQuery.of(context).size.width < 500 || MediaQuery.of(context).size.height < 500)
            ? 300.0
            : 300.0;

    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: (QRViewController controller) {
            _onQRViewCreated(controller, context);
          },
          overlay: QrScannerOverlayShape(
            borderColor: Colors.red,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: scanArea,
          ),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        Positioned(
          top: 45,
          left: 10,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 35),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Positioned(
          top: 45,
          right: 10,
          child: FutureBuilder(
            future: controller?.getFlashStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                bool isFlashOn = snapshot.data == true;
                return IconButton(
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 35,
                  ),
                  onPressed: () async {
                    await controller?.toggleFlash();
                    setState(() {});
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      // Check if a valid QR code is scanned
      if (result != null && result!.code!.isNotEmpty) {
        // Pause the camera to stop scanning further
        controller.pauseCamera();

        // Handle the scanned QR code
        await widget.handleSearchRequestCallback(result!.code!);

      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
