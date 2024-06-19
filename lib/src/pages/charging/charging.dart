// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:ui';
import 'package:ev/src/pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../components/elevationbutton.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async'; // Import async library for Future.delayed


String formatTimestamp(DateTime originalTimestamp) {
  return DateFormat('MM/dd/yyyy, hh:mm:ss a').format(originalTimestamp.toLocal());
}

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

class chargingpage extends StatefulWidget {
  final String? username; // Make the username parameter nullable
  final String searchChargerID;

  const chargingpage({super.key,this.username, required this.searchChargerID});

  @override
  State<chargingpage> createState() => _ChargingPageState();
}

class _ChargingPageState extends State<chargingpage> {
  String activeTab = 'home';
  late WebSocketChannel channel;

  String chargerStatus = '';
  String timestamp = '';
  bool isTimeoutRunning = false;
  bool isStarted = false;
  bool checkFault = false;
  bool isErrorVisible = false;
  bool isThresholdVisible = false;
  bool isBatteryScreenVisible = false;
  bool showAlertLoading = false;
  List<Map<String, dynamic>> history = [];
  String voltage = '';
  String current = '';
  String power = '';
  String energy = '';
  String frequency = '';
  String temperature = '';
  bool isStartButtonEnabled = true; // Initial state
  bool isStopButtonEnabled = false;
  bool charging = false;
  String chargerID = '';
  String username ='';
  String errorCode = '';
  void seterrorCode(String errorCode) {
    setState(() {
      errorCode = errorCode;
    });
  }
  bool showSuccessAlert = false;
  bool showErrorAlert = false;

  bool showAlert = false;
  Map<String, dynamic> chargingSession = {};
  Map<String, dynamic> updatedUser = {};

    void setApiData(Map<String, dynamic> chargerSession, Map<String, dynamic> userValue) {
    setState(() {
      chargingSession = chargerSession;
      updatedUser = userValue;
      showAlert = true;
    });
  }
  void handleCloseAlert() async {
    // Simulate the equivalent of killChargerID() and checkFault logic
    bool checkFault = false; // Example value, set it based on your logic
    if (!checkFault) {
      Navigator.of(context).pop();
    }
    setState(() {
      showAlert = false;
    });
  }

  void showSuccess() {
    setState(() {
      showSuccessAlert = true;
    });
  }

  void closeSuccess() {
    setState(() {
      showSuccessAlert = false;
    });
  }

  void showError() {
    setState(() {
      showErrorAlert = true;
    });
  }

  void closeError() {
    setState(() {
      showErrorAlert = false;
    });
  }
  void handleLoadingStart() {
    setState(() {
      showAlertLoading = true;
    });
  }

  void handleLoadingStop() {
    setState(() {
      showAlertLoading = false;
    });
  }
  void setIsStarted(bool value) {
    setState(() {
      isStarted = value;
    });
  }

  void setCheckFault(bool value) {
    setState(() {
      checkFault = value;
    });
  }

  void startTimeout() {
    setState(() {
      isTimeoutRunning = true;
    });
  }

  void stopTimeout() {
    setState(() {
      isTimeoutRunning = false;
    });
  }
  bool isLoading = false; // Track loading state


void handleAlertLoadingStart(BuildContext context) {
  showDialog(
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(0, 23, 27, 44),
            borderRadius: BorderRadius.circular(10),
          ),
          width: 200,
          height: 200,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 20),
              Text(
                'Loading...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }, context: context,
  );
}

Future<void> updateSessionPriceToUser() async {
  try {
    handleAlertLoadingStart(context); // Show loading dialog

    var url = Uri.parse('http://122.166.210.142:8052/getUpdatedCharingDetails');
    var body = {
      'chargerID': chargerID,
      'user': username,
    };
    var headers = {
      'Content-Type': 'application/json',
    };

    var response = await http.post(url, headers: headers, body: jsonEncode(body));
    print("response: $response");

    // Simulate a 2-second delay (replace with actual loading logic)
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pop(context); // Close loading dialog

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var chargingSession = data['value']['chargingSession'];
      var updatedUser = data['value']['user'];

      print('Charging Session: $chargingSession');
      print('Updated User: $updatedUser');

      void handleCloseButton() {
        if (chargerStatus == "Faulted"  || chargerStatus == 'Unavailable') {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userinfo: username),
            ),
          );
          endChargingSession(chargerID);
        }
      }

void showCustomAlertDialog( Map<String, dynamic> chargingSession, Map<String, dynamic> updatedUser) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent dialog from closing when tapped outside
    builder: (context) {
      return AlertDialog(
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 45.0,
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Charging Done',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 122, 186, 124),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.shade900.withOpacity(0.5),
                  blurRadius: 10.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Charger ID'),
                    Text(chargingSession['ChargerID'].toString()),
                  ],
                ),
                const Divider(color: Colors.white),
                Row(
      children: [
        const SizedBox(width: 16), // Adjust the width as needed
        const Text('Start Time'),
        const Spacer(),
        Expanded(
          child: Text(
            chargingSession['StartTimestamp'] != null
                ? formatTimestamp(DateTime.parse(chargingSession['StartTimestamp']))
                : 'N/A',
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 16), // Adjust the width as needed
      ],
    ),
                const Divider(color: Colors.white),
                Row(
      children: [
        const SizedBox(width: 16), // Adjust the width as needed
        const Text('Stop Time'),
        const Spacer(),
        Expanded(
          child: Text(
            chargingSession['StopTimestamp'] != null
                ? formatTimestamp(DateTime.parse(chargingSession['StopTimestamp']))
                : 'N/A',
            textAlign: TextAlign.end,
          ),
        ),
        const SizedBox(width: 16), // Adjust the width as needed
      ],
    ),
                const Divider(color: Colors.white),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Unit Consumed'),
                    Text(chargingSession['Unitconsumed'].toString()),
                  ],
                ),
                const Divider(color: Colors.white),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Charging Price'),
                    Text(chargingSession['price'].toString()),
                  ],
                ),
                const Divider(color: Colors.white),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Available Balance'),
                    Text(updatedUser['walletBalance'].toString()),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  handleCloseButton();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(197, 242, 85, 74),
                ),
                child: const Text('Close'),
              ),
            ),
          ),
        ],
      );
    },
  );
}

      // Show success dialog
      showCustomAlertDialog(chargingSession, updatedUser);
    } else {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Updation unsuccessful!'),
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
    Navigator.pop(context); // Close loading dialog on error

    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to update charging details: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Handle or log error
    print('Error updating charging details: $error');
  }
}


  void handleAlertLoadingStop() {
    setState(() {
      showAlertLoading = false;
    });
  }

  void setVoltage(String value) {
    setState(() {
      voltage = value;
    });
  }

  void setCurrent(String value) {
    setState(() {
      current = value;
    });
  }

  void setPower(String value) {
    setState(() {
      power = value;
    });
  }

  void setEnergy(String value) {
    setState(() {
      energy = value;
    });
  }

  void setFrequency(String value) {
    setState(() {
      frequency = value;
    });
  }

  void setTemperature(String value) {
    setState(() {
      temperature = value;
    });
  }

  void setHistory(Map<String, dynamic> entry) {
    setState(() {
      history.add(entry);
    });
    print("entry $entry");
  }

  void setChargerStatus(String value) {
    setState(() {
      chargerStatus = value;
    });
  }

  void setTimestamp(String currentTime) {
    setState(() {
      timestamp = currentTime;
    });
  }

  void appendStatusTime(String status, String currentTime) {
    setState(() {
      chargerStatus = status;
      timestamp = currentTime;
    });
  }




  String getCurrentTime() {
    DateTime currentDate = DateTime.now();
    String currentTime = currentDate.toIso8601String();
    return formatTimestamp(currentTime as DateTime);
  }

  Map<String, dynamic> convertToFormattedJson(List<dynamic> measurandArray) {
    Map<String, dynamic> formattedJson = {};
    measurandArray.forEach((measurandObj) {
      String key = measurandObj['measurand'];
      dynamic value = measurandObj['value'];
      formattedJson[key] = value;
    });
    return formattedJson;
  }

  Future<void> fetchLastStatus(String chargerID) async {
    try {
      print("chargerID $chargerID");
      final response = await http.post(
        // Uri.parse('http://192.168.1.33:8052/FetchLaststatus'),
        Uri.parse('http://122.166.210.142:8052/FetchLaststatus'),

        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': chargerID}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['message']['status'];
        final formattedTimestamp =
            formatTimestamp(DateTime.parse(data['message']['timestamp']));

        if (status == 'Available' || status == 'Unavailable') {
          startTimeout();
        } else if (status == 'Charging') {
          setIsStarted(true);
          setState(() {
                  charging = true;
          });
          toggleBatteryScreen();

        }

        appendStatusTime(status, formattedTimestamp);
      } else {
        print('Failed to fetch status. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error while fetching status: $error');
    }
  }




  Future<void> endChargingSession(String chargerID) async {
    print("ChargerIDEND: $chargerID");
    try {
      final Uri uri = Uri.parse(
          'http://122.166.210.142:8052/endChargingSession?ChargerID=$chargerID');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Charging session ended: $data');
      } else {
        print(
            'Failed to end charging session. Status code: ${response.statusCode}');

      }
      dispose();
    } catch (error) {
      print('Error ending charging session: $error');
    }
  }


void RcdMsg(Map<String, dynamic> parsedMessage) {
  final String chargerID = widget.searchChargerID;
  print("RcMsg");
  if (parsedMessage['DeviceID'] != chargerID) return;

  final List<dynamic> message = parsedMessage['message'];

  // Ensure the message has at least 4 elements to avoid index out of range errors
  if (message.length < 4 || message[3] == null) return;

  String ChargerStatus = '';
  String CurrentTime = ''; // Initialize CurrentTime
  String vendorErrorCode = ''; // Default to empty string if null

  if (parsedMessage['DeviceID'] == chargerID) {
    print('Received message: $parsedMessage');
    switch (message[2]) {
      case 'StatusNotification':
        vendorErrorCode = message[3]['vendorErrorCode'] ?? ''; // Default to empty string if null
        ChargerStatus = message[3]['status'] ?? ''; // Default to empty string if null
        CurrentTime = formatTimestamp(DateTime.parse(message[3]['timestamp'] ?? DateTime.now().toString()));
        errorCode = message[3]['errorCode'] ?? ''; // Default to 'NoError' if null

        if (ChargerStatus == 'Preparing') {
          setState(() {
            charging = false;
          });
          stopTimeout();
          setIsStarted(false);
        } else if (ChargerStatus == 'Available' || ChargerStatus == 'Unavailable') {
          setState(() {
            charging = false;
          });
          startTimeout();
          setIsStarted(false);
        } else if (ChargerStatus == 'Charging') {
          setState(() {
            charging = true;
          });
          toggleBatteryScreen();
          setIsStarted(true);
          handleAlertLoadingStop();
        } else if (ChargerStatus == 'Finishing') {
          setIsStarted(false);
          setState(() {
            charging = false;
          });
          toggleBatteryScreen();
        } else if (ChargerStatus == 'Faulted') {
          setIsStarted(false);
          setState(() {
            charging = false;
            toggleBatteryScreen();
            toggleErrorVisibility();
          });
          setCheckFault(true);
        }else if (ChargerStatus == 'Unavailable') {
          setIsStarted(false);
          setState(() {
            charging = false;
          toggleBatteryScreen();
            toggleErrorVisibility();

          });
          // setCheckFault(true);
        }

        if (errorCode != 'NoError') {
          Map<String, dynamic> entry = {
            'serialNumber': history.length + 1,
            'currentTime': CurrentTime,
            'chargerStatus': ChargerStatus,
            'errorCode': errorCode != 'InternalError' ? errorCode : vendorErrorCode,
          };

          setState(() {
            history.add(entry);
            checkFault = true;
          });
        } else {
          setState(() {
            checkFault = false;
          });
        }seterrorCode(errorCode);
        break;

      case 'Heartbeat':
        CurrentTime = formatTimestamp(DateTime.now());
        setState(() {
          timestamp = CurrentTime;
        });
        print("chargerStatus: $chargerStatus $errorCode");
        break;

      case 'MeterValues':
        // Extract meterValue and sampledValue from the message
        final meterValues = message[3]['meterValue'] ?? [];
        final sampledValue = meterValues.isNotEmpty ? meterValues[0]['sampledValue'] : [];

        // Convert sampledValue to a formatted JSON map
        Map<String, dynamic> formattedJson = convertToFormattedJson(sampledValue);
        CurrentTime = formatTimestamp(DateTime.now());

        // Update state or use state management to store and update values
        setState(() {
          setChargerStatus('Charging');
          setTimestamp(CurrentTime);
          setVoltage(formattedJson['Voltage'] ?? '');
          setCurrent(formattedJson['Current.Import'] ?? '');
          setPower(formattedJson['Power.Active.Import'] ?? '');
          setEnergy(formattedJson['Energy.Active.Import.Register'] ?? '');
          setFrequency(formattedJson['Frequency'] ?? '');
          setTemperature(formattedJson['Temperature'] ?? '');
        });

        // Print the updated values (optional)
        print('{ "V": ${formattedJson['Voltage']},"A": ${formattedJson['Current.Import']},"W": ${formattedJson['Power.Active.Import']},"Wh": ${formattedJson['Energy.Active.Import.Register']},"Hz": ${formattedJson['Frequency']},"Kelvin": ${formattedJson['Temperature']}}');
        break;

      case 'Authorize':
        print("errorCode: $errorCode");
        ChargerStatus = (errorCode == 'NoError' ||   errorCode.isEmpty) ? 'Authorize' : 'Faulted';
        CurrentTime = formatTimestamp(DateTime.now());
        break;

      case 'FirmwareStatusNotification':
        ChargerStatus = message[3]['status']?.toUpperCase() ?? ''; // Default to empty string if null
        CurrentTime = formatTimestamp(DateTime.now());
        break;

      case 'StopTransaction':
        setIsStarted(false);
        setState(() {
          charging = false;
        });
        // Handle additional stop transaction logic here
        CurrentTime = formatTimestamp(DateTime.now());
        print("stoptransation");
        updateSessionPriceToUser(); // Call update function
        break;

      case 'Accepted':
        ChargerStatus = 'ChargerAccepted';
        CurrentTime = formatTimestamp(DateTime.now());
        break;

      default:
        // Handle unknown message types if necessary
        break;
    }
  }

  if (ChargerStatus.isNotEmpty) {
    appendStatusTime(ChargerStatus, CurrentTime);
  }
}


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.searchChargerID.isNotEmpty) {
        fetchLastStatus(widget.searchChargerID);
      }
    });
    initializeWebSocket();
    // Initialize chargerID and username from the widget
    chargerID = widget.searchChargerID;
    username = widget.username ?? ''; // Provide a default value if username is null
    print('Initialized chargerID: $chargerID');
    print('Initialized username: $username');

  }
  
  void initializeWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://122.166.210.142:7050'),
    );

    channel.stream.listen(
      (message) {
        final parsedMessage = jsonDecode(message);
        if (mounted) {
          // Check if the widget is still mounted
          RcdMsg(parsedMessage);
        }
      },
      onDone: () async {
        if (mounted) {
          // Check if the widget is still mounted
          setState(() {
            charging = false;
          });
          setIsStarted(false);
          await endChargingSession(widget.searchChargerID);
          print('WebSocket connection closed');
        }
      },
      onError: (error) {
        if (mounted) {
          // Check if the widget is still mounted
          print('WebSocket error: $error');
        }
      },
      cancelOnError: true,
    );
  }

  
  void dispose() {
    channel.sink.close(); // Close the WebSocket sink
    super.dispose();
  }


void toggleErrorVisibility() {
  print("isErrorVisible: $isErrorVisible");
  setState(() {
    if (isErrorVisible) {
      isErrorVisible = !isErrorVisible;
      isErrorVisible = false;
    } else {
      isThresholdVisible = false;
      isErrorVisible = !isErrorVisible;
      isErrorVisible = true;
    }
  });
}

void toggleBatteryScreen() {
  print("Charging $charging");

  if (charging) {
    setState(() {
      isBatteryScreenVisible = !isBatteryScreenVisible;
      isStartButtonEnabled = !isStartButtonEnabled;
      isStopButtonEnabled = !isStopButtonEnabled;
    });
  } else {
    setState(() {
      isBatteryScreenVisible = false;  // Hide battery screen
      isStartButtonEnabled = false;    // Disable start button
      isStopButtonEnabled = false;     // Disable stop button
    });
  }
}


  void toggleThresholdVisibility() {
    setState(() {
      // If we're toggling threshold visibility, hide error if it's visible
      if (!isThresholdVisible) {
        isErrorVisible = false;
      }
      isThresholdVisible = !isThresholdVisible;
    });
  }

 


  // start button
  Future<void> handleStartTransaction() async {

  String username = widget.username ?? ''; // Provide a default value if username is null
  String chargerID = widget.searchChargerID ?? ''; // Provide a default value if username is null

  try {
    final response = await http.post(
      Uri.parse('http://122.166.210.142:8052/start'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': chargerID,
        'user': username,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('ChargerStartInitiated');
      print(data['message']);
    } else {
      print('Failed to start charging: ${response.reasonPhrase}');
    }
  } catch (error) {
    print('Error: $error');
  }
}


  void startButtonPressed() {
    handleStartTransaction();
  }


  // start button
  Future<void> handleStopTransaction() async {
  String chargerID = widget.searchChargerID ?? ''; // Provide a default value if username is null

    try {
      final response = await http.post(
        Uri.parse('http://122.166.210.142:8052/stop'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'id': chargerID,
        }),

      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('ChargerStopInitiated');
        print(data['message']);
      } else {
        print('Failed to stop charging: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }


  void stopButtonPressed() {
    handleStopTransaction();
  }

void navigateToHomePage(BuildContext context, String username) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(userinfo: username),
    ),
  );endChargingSession(chargerID);

}


  @override
  Widget build(BuildContext context) {
    // String? username = widget.username;
    String? ChargerID = widget.searchChargerID;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0), // Set background color to white
      body: Column( 
      
        crossAxisAlignment: CrossAxisAlignment.start,
        children:<Widget> [
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
                      // Handle icon tap
                      print('Icon tapped');
                      // Call the function to navigate to the home page
                      navigateToHomePage(context, username);
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
                    'Charging Dashboard',
                    style: TextStyle(color: Colors.white,fontSize: 20),
                  )
                ],
              ),
            
            ),
          ),
          Expanded(
            child:SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/Image/homecar.png',
                    height: 300,
                  ),

                  const SizedBox(height: 25.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 13.0),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'CHARGER STATUS',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.white),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ChargerID ?? '', // Use username parameter, or an empty string if null
                            style: const TextStyle(fontSize: 18,color: Colors.white),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            chargerStatus,
                            style: TextStyle(
                              color: chargerStatus == 'Faulted' ? Colors.red : Colors.green,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            timestamp,
                            style: const TextStyle(fontSize: 14,color: Colors.white60),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (isBatteryScreenVisible) // Conditional rendering based on isBatteryScreenVisible
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          BatteryChargeScreen(),
                          ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                      children: [
                        ElevatedButton(
                           onPressed: chargerStatus == 'Preparing' ? startButtonPressed : null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              chargerStatus == 'Preparing' ?
                              (isStartButtonEnabled ? Colors.lightGreen : Colors.lightGreen.withOpacity(0.5)) :
                              Colors.grey, // Change color when not preparing
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            elevation: MaterialStateProperty.all(5),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.play_arrow, color: Colors.white),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Start',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20), // Add spacing between buttons
                        ElevatedButton(
                          onPressed: isStopButtonEnabled ? stopButtonPressed : null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              isStopButtonEnabled ? Colors.redAccent : Colors.redAccent.withOpacity(0.5),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            elevation: MaterialStateProperty.all(5), // Add elevation for shadow
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.stop, color: Colors.white, size: 15),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Stop',
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isBatteryScreenVisible) // Conditional rendering based on isBatteryScreenVisible
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green[300]!,
                                          Colors.green[700]!
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(4, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(
                                        8), // Optional padding
                                      child:  Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly space the text elements
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                voltage.isNotEmpty ? voltage : '0',
                                                style: const TextStyle(
                                                  color:Colors.white,
                                                  fontSize: 25,
                                                ),
                                              ),
                                              const Text('Voltage',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,

                                              ),)
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                current.isNotEmpty ? current : '0',
                                                style: const TextStyle(
                                                  color:Colors.white,
                                                  fontSize: 25,
                                                ),
                                              ),
                                              const Text('Current',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,

                                                ),)
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                power.isNotEmpty ? power : '0',
                                                style: const TextStyle(
                                                  color:Colors.white,
                                                  fontSize: 25,
                                                ),
                                              ),
                                              const Text('Power',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,

                                                ),)
                                            ],
                                          ),
                                        ],
                                      ),

                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green[300]!,
                                          Colors.green[700]!
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 10,
                                          offset: Offset(4, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(
                                        8), // Optional padding
                                    child:  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly space the text elements
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              energy.isNotEmpty ? energy : '0',
                                              style: const TextStyle(
                                                color:Colors.white,
                                                fontSize: 25,
                                              ),
                                            ),
                                            const Text('Energy',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,

                                              ),)
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              frequency.isNotEmpty ? frequency : '0',
                                              style: const TextStyle(
                                                color:Colors.white,
                                                fontSize: 25,
                                              ),
                                            ),
                                            const Text('Frequency',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,

                                              ),)
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              temperature.isNotEmpty ? temperature : '0',
                                              style: const TextStyle(
                                                color:Colors.white,
                                                fontSize: 25,
                                              ),
                                            ),
                                            const Text('Temp',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,

                                              ),)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
              
                  Padding(
                    padding:
                    const EdgeInsets.only( left: 17, bottom: 100),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start, // Aligns contents to the start
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                              onPressed: toggleErrorVisibility,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color.fromARGB(255, 251, 164, 153)),
                                foregroundColor:
                                const Color.fromARGB(255, 251, 164, 153),
                              ),
                              child: const Text('Show Error'),
                            ),
                            OutlinedButton(
                              onPressed: toggleThresholdVisibility,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color:
                                  Color(0xFFC8F0CD), // Use the specified color
                                ),
                                foregroundColor: const Color(
                                    0xFFC8F0CD), // Use the specified color
                              ),
                              child: const Text(
                                'Show Threshold',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 168, 225,
                                      177), // Use the specified color
                                ),
                              ),
                            ),
                          ],
                        ),

                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 23, bottom: 80),
                        child: Column(
                          children: [
                            const SizedBox(height: 25),
                            if (isErrorVisible)
                              history.isEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(23, 27, 44, 1.0),
                                        borderRadius: BorderRadius.circular(10.0),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.0,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(20.0),
                                      child: const Center(
                                        child: Text(
                                          'History not found.',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    )
                                  :Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(23, 27, 44, 1.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.white),
                                ),
                                padding: const EdgeInsets.all(20.0),
                                    child: Scrollbar(
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: history.length,
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          Map<String, dynamic> transaction = history[index];
                                          return Column(
                                            children: [
                                              GestureDetector(
                                                child: Container(
                                                  margin: const EdgeInsets.only(bottom: 10.0),
                                                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              transaction['chargerStatus'],
                                                              style: const TextStyle(
                                                                fontSize: 22,
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            // const SizedBox(height: 5),
                                                            Text(
                                                              transaction['currentTime'],
                                                              style: const TextStyle(
                                                                fontSize: 15,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(
                                                        transaction['errorCode'],
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.red,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              if (index != history.length - 1) // Add divider if it's not the last item
                                                CustomGradientDivider(),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                              ),

                            if (isThresholdVisible)
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(right: 15),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'THRESHOLD LEVEL',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.white),
                                      ),
                                      Divider(),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Voltage Level:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Input under voltage - 175V and below.',
                                              style: TextStyle(
                                                  fontSize: 17, color: Colors.white),
                                            ),
                                          ),
                                          Text(
                                            'Input over voltage - 270V and below.',
                                            style: TextStyle(fontSize: 17, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Current:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Over Current- 33A',
                                              style: TextStyle(fontSize: 17, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Frequency:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Under Frequency - 47HZ',
                                              style: TextStyle(fontSize: 17, color: Colors.white),
                                            ),
                                          ),
                                          Text(
                                            'Over Frequency - 53HZ',
                                            style: TextStyle(fontSize: 17, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Temperature:',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Low Temperature - 0 °C. ',
                                              style: TextStyle(fontSize: 17, color: Colors.white),
                                            ),
                                          ),
                                          Text(
                                            'High Temperature - 58 °C.',
                                            style: TextStyle(fontSize: 17, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),),
        ],
      ),
      floatingActionButton: FloatingButton(
        activeTab: activeTab,
        onDispose: dispose,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}

class BatteryChargeScreen extends StatefulWidget {
  @override
  _BatteryChargeScreenState createState() => _BatteryChargeScreenState();
}

class _BatteryChargeScreenState extends State<BatteryChargeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _animation = Tween<double>(begin: 0, end: 100).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: BatteryPainter(_animation.value),
        child: Container(
          width: 200,
          height: 70,
        ),
      ),
    );
  }
}


class BatteryPainter extends CustomPainter {
  final double chargeLevel;

  BatteryPainter(this.chargeLevel);

  @override
  void paint(Canvas canvas, Size size) {
    const double cornerRadius = 3.0;
    const double tipWidth = 20.0;
    final double batteryWidth = size.width - tipWidth - 2 * cornerRadius;

    // Draw dotted charge level
    final double chargeWidth = batteryWidth * (chargeLevel / 100);
    final Paint dotPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    const double dotRadius = 10.0;
    const double dotSpacing = 29.0;
    double center = size.width / 2;
    double currentX = center;
    double maxDistance = chargeWidth / 2;


    while (currentX > center - maxDistance) {
      canvas.drawCircle(Offset(currentX, size.height / 2), dotRadius, dotPaint);
      currentX -= dotSpacing;
    }

    currentX = center + dotSpacing;

    while (currentX < center + maxDistance) {
      canvas.drawCircle(Offset(currentX, size.height / 2), dotRadius, dotPaint);
      currentX += dotSpacing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool showAlertLoading;
  final Widget child;

  LoadingOverlay({required this.showAlertLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child, // The main co ntent
        if (showAlertLoading)
          const Opacity(
            opacity: 0.5,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (showAlertLoading)
          Center(
            child: Container(
              width: 200,
              height: 100,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 20),
                  Text('Loading...', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
