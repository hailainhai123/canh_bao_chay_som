import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/chart/animated_line_chart.dart';
import 'package:health_care/chart/line_chart.dart';
import 'package:health_care/login/login_page.dart';
import 'package:health_care/model/patient.dart';
import 'package:health_care/model/patient_response.dart';
import 'package:health_care/model/user.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';
import '../navigator.dart';
import 'fake_chart_series.dart';

class PatientPage extends StatefulWidget {
  final PatientResponse patientResponse;

  PatientPage({Key key, this.patientResponse}) : super(key: key);

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> with FakeChartSeries {
  MQTTClientWrapper mqttClientWrapper;
  User registerUser;
  Patient tempPatient;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  Timer timer;
  int minute = 40;

  @override
  void initState() {
    tempPatient = widget.patientResponse.patients[0];
    tempPatient.nhietdo = 38.5;
    _idController.text = tempPatient.mabenhnhan;
    _nameController.text = tempPatient.ten;
    _informationController.text = tempPatient.mathietbi;
    _phoneNumberController.text = tempPatient.sdt;

    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => register(message));
    mqttClientWrapper.prepareMqttClient(Constants.mac);
    super.initState();
  }

  Widget _appBar() {
    return AppBar(
      title: Text("Thông tin bệnh nhân"),
      automaticallyImplyLeading: false,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: new Text('Bạn muốn đăng xuất ?'),
                    // content: new Text('Bạn muốn thoát ứng dụng?'),
                    actions: <Widget>[
                      new FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: new Text('Hủy'),
                      ),
                      new FlatButton(
                        onPressed: () {
                          setState(() {
                            navigatorPushAndRemoveUntil(context, LoginPage());
                          });
                        },
                        child: new Text('Đồng ý'),
                      ),
                    ],
                  );
                });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, double> line1 = createLine2();
    Map<DateTime, double> line2 = createLine2_2();

    LineChart chart;

    // timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
    //   print('_PatientPageState.buildTimer');
    //   minute += 10;
    //   line1[DateTime.now().subtract(Duration(minutes: 50))] = 15.0;
    //   line1[DateTime.now().subtract(Duration(minutes: 60))] = 15.0;
    //   line1[DateTime.now().subtract(Duration(minutes: 70))] = 15.0;
    //   line1[DateTime.now().subtract(Duration(minutes: 80))] = 15.0;
    //   line1[DateTime.now().subtract(Duration(minutes: 90))] = 15.0;
    //   setState(() {});
    // });

    chart = LineChart.fromDateTimeMaps(
        [line1, line2], [Colors.green, Colors.blue], ['C', 'C'],
        tapTextFontWeight: FontWeight.w400);

    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(),
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildPatientInfo(),
                tempContainer(tempPatient.nhietdo),
                buildChart(chart),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPatientInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${tempPatient.tenDecode}',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Column(
              children: [
                buildLabel(),
                buildData(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabel() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          buildTextLabel('Khoa', 1),
          verticalLine(),
          buildTextLabel('Phòng', 1),
          verticalLine(),
          buildTextLabel('Giường', 1),
        ],
      ),
    );
  }

  Widget buildData() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
        border: Border.all(color: Colors.grey),
      ),
      height: 40,
      child: Row(
        children: [
          buildTextData('${tempPatient.makhoa}', 1),
          verticalLine(),
          buildTextData(tempPatient.phong, 1),
          verticalLine(),
          buildTextData(tempPatient.giuong, 1),
        ],
      ),
    );
  }

  Widget buildTextLabel(String data, int flexValue) {
    return Expanded(
      child: Text(
        data,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget buildTextData(String data, int flexValue) {
    return Expanded(
      child: Text(
        data,
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget verticalLine() {
    return Container(
      height: double.infinity,
      width: 1,
      color: Colors.grey,
    );
  }

  Widget horizontalLine() {
    return Container(
      height: 1,
      width: double.infinity,
      color: Colors.grey,
    );
  }

  Widget buildTempLayout(double temp) {
    return Container(
      width: 120,
      height: 70,
      decoration: BoxDecoration(
        color: temp > 37.5 ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/thermometer.png',
            color: Colors.white,
            width: 25,
            height: 25,
          ),
          SizedBox(width: 5),
          Text(
            '$temp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget tempContainer(double temp) {
    double value = temp / 42;
    print('_PatientPageState.tempContainer $value');
    Color tempColor = getTempColor(temp);
    return Container(
      child: CircularPercentIndicator(
        radius: 180.0,
        lineWidth: 15.0,
        percent: value,
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nhiệt độ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset(
                //   'assets/images/thermometer.png',
                //   color: tempColor,
                //   width: 25,
                //   height: 25,
                // ),
                SizedBox(width: 5),
                Text(
                  '$temp\u2103',
                  style: TextStyle(
                    color: tempColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        progressColor: tempColor,
      ),
    );
  }

  Color getTempColor(double temp) {
    if (temp < 37.5) {
      return Colors.green;
    } else if (temp >= 37.5 && temp < 38.5) {
      return Colors.yellow;
    }
    return Colors.red;
  }

  Widget buildChart(LineChart chart) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 300,
      child: Expanded(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
              ),
              Text(
                'Lịch sử nhiệt độ',
                style: TextStyle(fontSize: 18),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedLineChart(
                    chart,
                    key: UniqueKey(),
                  ), //Unique key to force animations
                ),
              ),
              // SizedBox(width: 200, height: 50, child: Text('')),
            ]),
      ),
    );
  }

  register(String message) {
    Map responseMap = jsonDecode(message);

    if (responseMap['result'] == 'true') {
      print('Login success');
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage(
                    registerUser: registerUser,
                  )));
    } else {
      final snackBar = SnackBar(
        content: Text('Yay! A SnackBar!'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      );
      // Scaffold.of(context).showSnackBar(snackbar);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class LinearSales {
  final int year;
  final int sales;

  LinearSales(this.year, this.sales);
}
