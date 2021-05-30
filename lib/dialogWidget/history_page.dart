import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/addWidget/fake_chart_series.dart';
import 'package:health_care/chart/animated_line_chart.dart';
import 'package:health_care/chart/line_chart.dart';
import 'package:health_care/common/format.dart';
import 'package:health_care/login/login_page.dart';
import 'package:health_care/model/patient.dart';
import 'package:health_care/model/user.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';

class HistoryPage extends StatefulWidget {
  final Patient patient;

  const HistoryPage({Key key, this.patient}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with FakeChartSeries {
  MQTTClientWrapper mqttClientWrapper;
  User registerUser;
  Timer timer;
  int minute = 40;
  Map<DateTime, double> line1;
  Map<DateTime, double> line2;

  @override
  void initState() {
    line1 = createLine2();
    line2 = createLine2_2();
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => register(message));
    mqttClientWrapper.prepareMqttClient(Constants.mac);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    LineChart chart;

    chart = LineChart.fromDateTimeMaps(
        [line1, line2], [Colors.green, Colors.blue], ['C', 'C'],
        tapTextFontWeight: FontWeight.w400);

    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 10),
                Text(
                  widget.patient.tenDecode,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10),
                historyTableContainer(),
                buildChart(chart),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget historyTableContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          buildLabel(),
          buildData(),
        ],
      ),
    );
  }

  Widget buildData() {
    print('_HistoryPageState.buildData ${line1.length}');
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
        border: Border.all(color: Colors.grey),
      ),
      child: Scrollbar(
        isAlwaysShown: true,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: line1.length,
          itemBuilder: (context, index) {
            var key = line1.keys.elementAt(index);
            String keyDisplay = stringFromDate(key);
            return Column(
              children: [
                Container(
                  height: 40,
                  child: Row(
                    children: [
                      buildTextData('$keyDisplay', 2),
                      verticalLine(),
                      buildTextData('${line1[key]} \u2103', 3),
                    ],
                  ),
                ),
                horizontalLine(),
              ],
            );
          },
        ),
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
          buildTextLabel('Thời gian', 2),
          verticalLine(),
          buildTextLabel('Nhiệt độ', 3),
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
        center: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/thermometer.png',
              color: tempColor,
              width: 25,
              height: 25,
            ),
            SizedBox(width: 5),
            Text(
              '$temp',
              style: TextStyle(
                color: tempColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
              SizedBox(
                height: 10,
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
