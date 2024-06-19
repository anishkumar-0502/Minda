import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/elevationbutton.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dialogs/flutter_dialogs.dart';

class ProfileSettingPage extends StatefulWidget {
  final String? username;
  // Make the username parameter nullable
  const ProfileSettingPage({super.key, this.username});

  @override
  State<ProfileSettingPage> createState() => _settingspageState();
}

class _settingspageState extends State<ProfileSettingPage> {
  String activeTab = 'profile';
  String? UserName;
  String? userphone;
  String? userpass;
  String? UserTimeVal;
  String? UserUnitVal;
  String? UserPriceVal;

  void setActiveTab(String newTab) {
    setState(() {
      activeTab = newTab;
    });
  }

  bool lightTime = false;
  bool lightUnit = false;
  bool lightPrice = false;

  void onSwitchChangedTime(bool newValue) {
    setState(() {
      lightTime = newValue;
    });
  }

  void onSwitchChangedUnit(bool newValue) {
    setState(() {
      lightUnit = newValue;
    });
  }

  void onSwitchChangedPrice(bool newValue) {
    setState(() {
      lightPrice = newValue;
    });
  }

  final List<TextEditingController> _controllers =
      List.generate(12, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(12, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    fetchUserDetails();

    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() => _onTextChanged(i));
    }
  }

  void _onTextChanged(int index) {
    if (_controllers[index].text.isNotEmpty && index < 11) {
      _focusNodes[index + 1].requestFocus();
    } else if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void fetchUserDetails() async {
    String? username = widget.username;
    print('Fetching user details for user: $username ');

    try {
      var response = await http.get(Uri.parse(
          'http://122.166.210.142:8052/getUserDetails?username=$username'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        setUserName(data['value']['username'].toString());
        setUserPhone(data['value']['phone'].toString());
        setUserPass(data['value']['password'].toString());
        setUserTimeVal(data['value']['autostop_time'].toString());
        setUserUnitVal(data['value']['autostop_unit'].toString());
        setUserPriceVal(data['value']['autostop_price'].toString());

        setState(() {
          lightTime = data['value']['autostop_time_isChecked'] == true;
          lightUnit = data['value']['autostop_unit_isChecked'] == true;
          lightPrice = data['value']['autostop_price_isChecked'] == true;

          setUserTime_isChecked(lightTime);
          setUserUnit_isChecked(lightUnit);
          setUserPrice_isChecked(lightPrice);

          _controllers[9].text =
              data['value']['autostop_time_isChecked'].toString();
          _controllers[10].text =
              data['value']['autostop_unit_isChecked'].toString();
          _controllers[11].text =
              data['value']['autostop_price_isChecked'].toString();
        });
      } else {
        throw Exception('Error fetching user details');
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }

  void setUserName(String value) {
    setState(() {
      UserName = value;
      _controllers[0].text = value;
    });
  }

  void setUserPhone(String value) {
    setState(() {
      userphone = value;
      _controllers[1].text = value;
    });
  }

  void setUserPass(String value) {
    setState(() {
      userpass = value;
      _controllers[2].text = value;
    });
  }

  // void setUserPass(String value) {
  //   setState(() {
  //     userpass = value;
  //
  //     // Ensure value is split into 4 parts
  //     int partLength = (value.length / 4.0)
  //         .ceil(); // Using float division for accurate ceil value
  //     List<String> parts = List<String>.filled(4, '');
  //
  //     for (int i = 0; i < 4; i++) {
  //       int start = i * partLength;
  //       int end = start + partLength;
  //       if (start < value.length) {
  //         parts[i] =
  //             value.substring(start, end > value.length ? value.length : end);
  //       }
  //     }
  //
  //     // Assign each part to the corresponding controller
  //     for (int i = 0; i < 4; i++) {
  //       _controllers[2 + i].text = parts[i];
  //     }
  //   });
  // }
  //
  // void updatePasswordField() {
  //   String combinedValue = _controllers[2].text +
  //       _controllers[3].text +
  //       _controllers[4].text +
  //       _controllers[5].text;
  //   setUserPass(combinedValue);
  // }

  void setUserTimeVal(String value) {
    setState(() {
      UserTimeVal = value;
      _controllers[6].text = value;
    });
  }

  void setUserUnitVal(String value) {
    setState(() {
      UserUnitVal = value;
      _controllers[7].text = value;
    });
  }

  void setUserPriceVal(String value) {
    setState(() {
      UserPriceVal = value;
      _controllers[8].text = value;
    });
  }

  void setUserTime_isChecked(bool value) {
    setState(() {
      lightTime = value;
      _controllers[9].text = value.toString();
    });
  }

  void setUserUnit_isChecked(bool value) {
    setState(() {
      lightUnit = value;
      _controllers[10].text = value.toString();
    });
  }

  void setUserPrice_isChecked(bool value) {
    setState(() {
      lightPrice = value;
      _controllers[11].text = value.toString();
    });
  }

  void handleUpdate() async {
    Map<String, dynamic> updatedData = {
      'updateUsername': UserName,
      'updatePhone': userphone,
      'updatePass': userpass,
      'updateUserTimeVal': UserTimeVal,
      'updateUserUnitVal': UserUnitVal,
      'updateUserPriceVal': UserPriceVal,
      'updateUserTime_isChecked': lightTime,
      'updateUserUnit_isChecked': lightUnit,
      'updateUserPrice_isChecked': lightPrice,
    };

    List<String> errors = [];

    String formattedUsername =
        updatedData['updateUsername'].replaceAll(RegExp(r'\s+'), '_');
    if (formattedUsername != updatedData['updateUsername']) {
      errors.add('Username should not contain spaces, e.g., kesav_d');
    }

    RegExp passwordPattern = RegExp(r'^\d{4}$');
    if (!passwordPattern.hasMatch(updatedData['updatePass'])) {
      errors.add('Password must be a 4-digit number');
    }

    RegExp phonePattern = RegExp(r'^\d{10}$');
    if (!phonePattern.hasMatch(updatedData['updatePhone'])) {
      errors.add('Phone number must be a 10-digit number');
    }

    if (errors.isNotEmpty) {
      String errorMessage = errors.join('\n');
      print('Error:\n$errorMessage');
      showPlatformDialog(
        context: context,
        builder: (_) => BasicDialogAlert(
          title: const Text("Error"),
          content: Text(errorMessage),
          actions: <Widget>[
            BasicDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              title: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('http://122.166.210.142:8052/updateUserDetails'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        showPlatformDialog(
          context: context,
          builder: (_) => BasicDialogAlert(
            title: const Text("Success"),
            content: const Text("User details updated successfully."),
            actions: <Widget>[
              BasicDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                title: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        showPlatformDialog(
          context: context,
          builder: (_) => BasicDialogAlert(
            title: const Text("Error"),
            content:
                const Text("Error in updating, kindly check the credentials"),
            actions: <Widget>[
              BasicDialogAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                title: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error:\n$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0),
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
                  const SizedBox(width: 16), // Added space between icon and text
                  const Text(
                    'Settings',
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
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextField(
                            controller: _controllers[0],
                            focusNode: _focusNodes[0],
                            decoration: const InputDecoration(
                              filled: true,
                              // Set background color to light grey
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                // Set border color to white
                              ),
                            ),
                            onChanged: (value) {
                              setUserName(value);
                            },
                            enabled: false,
                            style: const TextStyle(
                              color: Colors.white60, // Set text color to white
                              fontSize: 23,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PhoneNumber',
                            style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white,),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextField(
                              controller: _controllers[1],
                              onChanged: (value) {
                                setUserPhone(value);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(color: Colors.white,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white,),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextField(
                              controller: _controllers[2],
                              onChanged: (value) {
                                setUserPass(value);
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(color: Colors.white,),
                            ),
                          ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: TextField(
                          //         controller: _controllers[2],
                          //         textAlign: TextAlign.center,
                          //         onChanged: (value) {
                          //           updatePasswordField();
                          //           if (value.isNotEmpty) {
                          //             FocusScope.of(context).nextFocus();
                          //           }
                          //         },
                          //         style: TextStyle(color: Colors.white,),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 25.0),
                          //     Expanded(
                          //       child: TextField(
                          //         controller: _controllers[3],
                          //         textAlign: TextAlign.center,
                          //         onChanged: (value) {
                          //           updatePasswordField();
                          //           if (value.isNotEmpty) {
                          //             FocusScope.of(context).nextFocus();
                          //           }
                          //         },
                          //         style: TextStyle(color: Colors.white,),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 25.0),
                          //     Expanded(
                          //       child: TextField(
                          //         controller: _controllers[4],
                          //         textAlign: TextAlign.center,
                          //         onChanged: (value) {
                          //           updatePasswordField();
                          //           if (value.isNotEmpty) {
                          //             FocusScope.of(context).nextFocus();
                          //           }
                          //         },
                          //         style: TextStyle(color: Colors.white,),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 25.0),
                          //     Expanded(
                          //       child: TextField(
                          //         controller: _controllers[5],
                          //         textAlign: TextAlign.center,
                          //         onChanged: (value) {
                          //           updatePasswordField();
                          //           if (value.isNotEmpty) {
                          //             FocusScope.of(context).nextFocus();
                          //           }
                          //         },
                          //         style: TextStyle(color: Colors.white,),
                          //       ),
                          //     ),
                          //   ],
                          // ),

                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Auto Stop Based on:',
                          style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(11.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Switch(
                                value: lightTime,
                                onChanged: (newValue) {
                                  setState(() {
                                    lightTime = newValue;
                                    setUserTime_isChecked(lightTime);
                                  });
                                },
                                activeTrackColor: Colors.green,
                                activeColor: Colors.white,
                                inactiveTrackColor: const Color.fromARGB(255, 39,
                                    39, 39), // Set the inactive track color to grey
                                inactiveThumbColor: Colors.white,
                              ),
                              const Text(
                                'Time',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  controller: _controllers[6],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setUserTimeVal(value);
                                  },
                                  style: const TextStyle(color: Colors.white,),
                                ),
                              ),
                              const Text(
                                "min's",
                                style: TextStyle(fontSize: 17,color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(11.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Switch(
                                value: lightUnit,
                                onChanged: (newValue) {
                                  setState(() {
                                    lightUnit = newValue;
                                    setUserUnit_isChecked(lightUnit);
                                  });
                                },
                                activeTrackColor: Colors.green,
                                activeColor: Colors.white,
                                inactiveTrackColor: const Color.fromARGB(255, 39,
                                    39, 39), // Set the inactive track color to grey
                                inactiveThumbColor: Colors.white,
                              ),
                              const Text(
                                'Unit',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  controller: _controllers[7],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setUserUnitVal(value);
                                  },
                                  style: const TextStyle(color: Colors.white,),
                                ),
                              ),
                              const Text(
                                'unit',
                                style: TextStyle(fontSize: 17,color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(11.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Switch(
                                value: lightPrice,
                                onChanged: (newValue) {
                                  setState(() {
                                    lightPrice = newValue;
                                    setUserPrice_isChecked(lightPrice);
                                  });
                                },
                                activeTrackColor: Colors.green,
                                activeColor: Colors.white,
                                inactiveTrackColor: const Color.fromARGB(255, 39,
                                    39, 39), // Set the inactive track color to grey
                                inactiveThumbColor: Colors.white,
                              ),
                              const Text(
                                'Price',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  controller: _controllers[8],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setUserPriceVal(value);
                                  },
                                  style: const TextStyle(color: Colors.white,),
                                ),
                              ),
                              const Text(
                                'Rs',
                                style: TextStyle(fontSize: 17,color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 100),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                      ),
                      onPressed: () {
                        handleUpdate();
                        print('Submit button pressed!');
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(
                          color: Colors.white,
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
      floatingActionButton: FloatingButton(activeTab: activeTab, onDispose: () {  },),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
    );
  }
}
