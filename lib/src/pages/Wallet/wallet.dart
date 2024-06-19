import 'dart:convert';
import 'package:flutter/material.dart';
import '../../components/elevationbutton.dart'; // Import the CustomElevatedButton widget
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
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

class WalletPage extends StatefulWidget {
  final String? username; // Make the username parameter nullable

  const WalletPage({
    Key? key,
    this.username, // Mark the username parameter as nullable
  }) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late Razorpay _razorpay;
  String activeTab = 'wallet';
  double? walletBalance;
  List<Map<String, dynamic>> transactionDetails =
      []; // Define transactionDetails as an empty list
  double? _lastPaymentAmount; // Store the last payment amount

  TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    fetchWallet(); // Fetch wallet balance when the page is initialized
    fetchTransactionDetails();
  }

  // Method to set wallet balance
  void setWalletBalance(double balance) {
    setState(() {
      walletBalance = balance.toDouble(); // Convert integer to double
    });
  }

  // Function to fetch wallet balance
  void fetchWallet() async {
    String? username = widget.username;

    try {
      var response = await http.get(Uri.parse(
          // 'http://192.168.1.33:8052/GetWalletBalance?username=$username'));
          'http://122.166.210.142:8052/GetWalletBalance?username=$username'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setWalletBalance(data['balance'].toDouble()); // Cast to double
      } else {
        throw Exception('Failed to load wallet balance');
      }
    } catch (error) {
      print('Error fetching wallet balance: $error');
    }
  }

  // Function to set transaction details
  void setTransactionDetails(List<Map<String, dynamic>> value) {
    setState(() {
      transactionDetails = value;
    });
  }

  // Function to fetch transaction details
  void fetchTransactionDetails() async {
    String? username = widget.username;

    try {
      var response = await http.get(Uri.parse(
          // 'http://192.168.1.33:8052/getTransactionDetails?username=$username'));
          'http://122.166.210.142:8052/getTransactionDetails?username=$username'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['value'] is List) {
          List<dynamic> transactionData = data['value'];
          List<Map<String, dynamic>> transactions =
              transactionData.cast<Map<String, dynamic>>();
          setTransactionDetails(transactions);
        } else {
          throw Exception('Transaction details format is incorrect');
        }
      } else {
        throw Exception('Failed to load transaction details');
      }
    } catch (error) {
      print('Error fetching transaction details: $error');
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  void handlePayment(double amount) async {
    String? username = widget.username;
    const String currency = 'INR';
    try {
      var response = await http.post(
        Uri.parse('http://122.166.210.142:8052/createOrder'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount, // amount in paise
          'currency': currency,
        }),
      );
      var data = json.decode(response.body);
      print(data);
      Map<String, dynamic> options = {
        'key': 'rzp_test_dcep4q6wzcVYmr',
        'amount': data['amount'],
        'currency': data['currency'],
        'name': 'Outdid Tech',
        'description': 'Wallet Recharge',
        'order_id': data['id'],
        'prefill': {'name': username},
        'theme': {'color': '#3399cc'},
      };
      _lastPaymentAmount = amount; // Store the amount

      _razorpay.open(options);
    } catch (error) {
      print('Error during payment: $error');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    String? username = widget.username;
    try {
      Map<String, dynamic> result = {
        'user': username,
        'RechargeAmt': _lastPaymentAmount, // Use the stored amount
        'transactionId': response.orderId,
        'responseCode': 'SUCCESS',
        'date_time': DateTime.now().toString(),
      };

      var output = await http.post(
        Uri.parse('http://122.166.210.142:8052/savePayments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(result),
      );

      var responseData = json.decode(output.body);
      print(responseData);
      if (responseData == 1) {
        print('Payment successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WalletPage(
              username: username,
            ),
          ),
        );
      } else {
        print('Payment details not saved!');
      }
    } catch (error) {
      print('Error saving payment details: $error');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Error: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  // UI method to build the amount container widget
  Widget _buildAmountContainer(double amount) {
    return GestureDetector(
      onTap: () {
        handlePayment(amount);
      },
      child: Container(
        padding: const EdgeInsets.all(12.2),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 217, 212),
          borderRadius: BorderRadius.circular(10.0),
          // border: Border.all(
          //   color: Colors.red.withOpacity(0.5),
          // ),
        ),
        child: Text(
          'Rs. ${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 27, 44, 1.0),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
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
                      'My Wallet',
                      style: TextStyle(color: Colors.white,fontSize: 20),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
            child: SingleChildScrollView(
            child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(23, 27, 44, 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.white)
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30.0, top: 10, bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                walletBalance != null
                                    ? 'Rs. ${walletBalance?.toStringAsFixed(2)}'
                                    : 'Fetching...', // Display the wallet balance dynamically
                                style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Balance',
                                style: TextStyle(fontSize: 21, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      const Padding(
                        padding: EdgeInsets.only(
                            right: 15.0), // Add padding to the right of the icon
                        child: Icon(Icons.wallet_outlined, size: 63, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                child: Row(
                  children: [
                    const Text(
                      'Recharge ',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    const SizedBox(width: 10.0),
                    Image.asset(
                      'assets/Image/RechargeIcon.png', // replace with the actual path to your image
                      height: 30.0, // adjust the height as needed
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 38.0, right: 30.0, top: 10.0, bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAmountContainer(500),
                    _buildAmountContainer(1000),
                    _buildAmountContainer(2000),
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: TextField(
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                          keyboardType:
                          TextInputType.number, // Set keyboard type to number
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),

                            hintText: 'Enter Amount',
                            hintStyle: const TextStyle(color: Colors.white),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                          controller: _amountController, // Assign the controller
                        ),
                      ),
                    ),
                    const SizedBox(width: 30.0),
                    Padding(
                      padding: const EdgeInsets.only(right: 22.0),
                      child: TextButton(
                        onPressed: () {
                          // Handle submit button pressed
                          // Extract amount from the text field and pass it to handlePayment function
                          double amount =
                              double.tryParse(_amountController.text) ?? 0.0;
                          if (amount > 0) {
                            handlePayment(amount);
                            _amountController
                                .clear(); // Clear the text field after submission
                          } else {
                            // Handle invalid input or amount
                            // Display a message or take appropriate action
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                          const Color.fromARGB(255, 219, 249, 223),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 80),
                child: transactionDetails.isEmpty
                    ? Container(
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(23, 27, 44, 1.0),
                      borderRadius: BorderRadius.circular(10.0), border: Border.all(color: Colors.white)
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: const Center(
                    child: Text(
                      'history not found.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
                    : Container(
                  // Display transaction history if available
                  decoration: BoxDecoration(
                      color: const Color.fromRGBO(23, 27, 44, 1.0),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.white)
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: Scrollbar(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Column(
                          children: [
                            for (int index = 0;
                            index < transactionDetails.length;
                            index++)
                              Column(
                                children: [
                                  GestureDetector(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
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
                                                  transactionDetails[index]
                                                  ['status'],
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  DateFormat(
                                                      'MM/dd/yyyy, hh:mm:ss a')
                                                      .format(
                                                    DateTime.parse(
                                                        transactionDetails[
                                                        index]['time'])
                                                        .toLocal(),
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white60,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${transactionDetails[index]['status'] == 'Credited' ? '+ Rs. ' : '- Rs. '}${transactionDetails[index]['amount']}',
                                            style: TextStyle(
                                              fontSize: 19,
                                              color: transactionDetails[index]
                                              ['status'] ==
                                                  'Credited'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (index != transactionDetails.length - 1)
                                    CustomGradientDivider(),
                                ],
                              ),
                          ],
                        ),
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
