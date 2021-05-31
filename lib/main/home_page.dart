import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_care/dialogWidget/edit_patient_dialog.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/model/department.dart';
import 'package:health_care/model/getbn.dart';
import 'package:health_care/model/patient.dart';
import 'package:health_care/model/thietbi.dart';
import 'package:health_care/response/device_response.dart';

import '../helper/constants.dart' as Constants;
import '../helper/mqttClientWrapper.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const GET_DEPARTMENT = 'loginkhoa';
  static const GET_BN_SOT = 'getkhoabenhnhansot';
  static const LOGIN_DEVICE = 'loginthietbi';

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  DeviceResponse response;
  String pubTopic;
  int selectedIndex;
  List<Department> departments = List();
  var dropDownItems = [''];
  String khoa;

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  List<Patient> patients = List();
  List<ThietBi> tbs = List();

  bool isLoading = false;

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Bạn muốn thoát ứng dụng ?'),
            // content: new Text('Bạn muốn thoát ứng dụng?'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('Hủy'),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                // Navigator.of(context).pop(true),
                child: new Text('Đồng ý'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void initState() {
    super.initState();
    initMqtt();
    initPatientTest();
    initSharedPrefs();
    print('_HomePageState.initState');
  }

  void initSharedPrefs() async {
    sharedPrefsHelper = SharedPrefsHelper();
    getPatients();
  }

  void getPatients() async {
    pubTopic = GET_BN_SOT;
    showLoadingDialog();
    khoa = await sharedPrefsHelper.getStringValuesSF('khoa');
    GetBN getBN = GetBN(Constants.mac, khoa);
    publishMessage(pubTopic, jsonEncode(getBN));
  }

  void initPatientTest() {
    Patient patient = Patient(
      'id',
      'quạt',
      '0963003197',
      'Hà Nội',
      'IVNR1000001',
      'trần nhà',
      '5',
      'Sốt Virus',
      37.5,
      '',
      '',
      '',
    );

    for (int i = 0; i < 10; i++) {
      patient.nhietdo = 0.0;
      patients.add(patient);
    }
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newheight = height - padding.top - padding.bottom;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Trang chủ'),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                child: Column(
                  children: <Widget>[
                    buildTableTitle(),
                    horizontalLine(),
                    buildListView(),
                    horizontalLine(),
                    // _applianceGrid(homes, newheight),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildTableTitle() {
    return Container(
      color: Colors.yellow,
      height: 40,
      child: Row(
        children: [
          buildTextLabel('TT', 2),
          verticalLine(),
          buildTextLabel('Vị trí', 4),
          verticalLine(),
          // buildTextLabel('G', 2),
          // verticalLine(),
          buildTextLabel('Tên', 15),
          verticalLine(),
          buildTempColumn(),
        ],
      ),
    );
  }

  Widget buildTempColumn() {
    return Expanded(
      flex: 4,
      child: Image.asset(
        'assets/images/thermometer.png',
        width: 20,
        height: 20,
        color: Colors.red,
      ),
    );
  }

  Widget buildListView() {
    return Container(
      child: Expanded(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: patients.length,
          itemBuilder: (context, index) {
            return itemView(index);
          },
        ),
      ),
    );
  }

  Widget itemView(int index) {
    return InkWell(
      onTap: () async {
        selectedIndex = index;
        Department d = Department('', khoa,'', Constants.mac);
        pubTopic = LOGIN_DEVICE;
        publishMessage(pubTopic, jsonEncode(d));
        showLoadingDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          children: [
            Container(
              color: patients[index].nhietdo > 38.5
                  ? Colors.yellow
                  : Colors.transparent,
              height: 40,
              child: Row(
                children: [
                  buildTextData('${index + 1}', 2),
                  verticalLine(),
                  buildTextData(patients[index].phong, 4),
                  // verticalLine(),
                  // buildTextData(patients[index].giuong, 2),
                  verticalLine(),
                  buildTextData(patients[index].tenDecode, 15),
                  verticalLine(),
                  tempData(patients[index].nhietdo.toString(), 4),
                ],
              ),
            ),
            horizontalLine(),
          ],
        ),
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

  Widget tempData(String data, int flexValue) {
    return Expanded(
      child: Text(
        '$data\u2103',
        style: TextStyle(
            fontSize: 18,
            color: double.parse(data) > 37.4 ? Colors.red : Colors.black),
        textAlign: TextAlign.center,
      ),
      flex: flexValue,
    );
  }

  Widget verticalLine() {
    return Container(height: double.infinity, width: 1, color: Colors.grey);
  }

  Widget horizontalLine() {
    return Container(height: 1, width: double.infinity, color: Colors.grey);
  }

  Future<void> handle(String message) async {
    Map responseMap = jsonDecode(message);
    response = DeviceResponse.fromJson(responseMap);

    switch (pubTopic) {
      case GET_DEPARTMENT:
        departments = response.id.map((e) => Department.fromJson(e)).toList();
        dropDownItems.clear();
        departments.forEach((element) {
          dropDownItems.add(element.madiadiem);
        });
        hideLoadingDialog();
        print('_DeviceListScreenState.handleDevice ${dropDownItems.length}');
        break;
      case GET_BN_SOT:
        patients = response.id.map((e) => Patient.fromJson(e)).toList();
        setState(() {});
        hideLoadingDialog();
        break;
      case LOGIN_DEVICE:
        tbs = response.id.map((e) => ThietBi.fromJson(e)).toList();
        dropDownItems.clear();
        tbs.forEach((element) {
          dropDownItems.add(element.matb);
        });
        setState(() {});
        hideLoadingDialog();
        await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                //this right here
                child: Container(
                  child: Stack(
                    children: [
                      EditPatientDialog(
                        patient: patients[selectedIndex],
                        dropDownItems: dropDownItems,
                        deleteCallback: (param) => {
                          getPatients(),
                          // removePatient(selectedIndex),
                        },
                        updateCallback: (param) => {
                          getPatients(),
                          // patients.removeAt(selectedIndex),
                          // patients.insert(selectedIndex, param),
                        },
                      ),
                      Positioned(
                        right: 0.0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            getPatients();
                          },
                          child: Align(
                            alignment: Alignment.topRight,
                            child: CircleAvatar(
                              radius: 14.0,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.close, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
        print('_DeviceListScreenState.handleDevice ${dropDownItems.length}');
        break;
    }
  }

  void removePatient(int index) async {
    setState(() {
      patients.removeAt(index);
    });
  }

  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () {
        // Some code to undo the change.
      },
    ),
  );

  Future<void> publishMessage(String topic, String message) async {
    if (mqttClientWrapper.connectionState ==
        MqttCurrentConnectionState.CONNECTED) {
      mqttClientWrapper.publishMessage(topic, message);
    } else {
      await initMqtt();
      mqttClientWrapper.publishMessage(topic, message);
    }
  }

  void showLoadingDialog() {
    setState(() {
      isLoading = false;
    });
    // Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    setState(() {
      isLoading = false;
    });
    // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  }
}

class SnackBarPage extends StatelessWidget {
  final String data;
  final String buttonLabel;

  SnackBarPage(this.data, this.buttonLabel);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: () {
          final snackBar = SnackBar(
            content: Text(data),
            action: SnackBarAction(
              label: buttonLabel,
              onPressed: () {
                // Some code to undo the change.
              },
            ),
          );

          // Find the Scaffold in the widget tree and use
          // it to show a SnackBar.
          Scaffold.of(context).showSnackBar(snackBar);
        },
        child: Text('Show SnackBar'),
      ),
    );
  }
}
