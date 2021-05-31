import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/helper/loader.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/main/home_screen.dart';
import 'package:health_care/model/department.dart';
import 'package:health_care/model/patient.dart';
import 'package:health_care/model/thietbi.dart';
import 'package:health_care/navigator.dart';
import 'package:health_care/response/device_response.dart';

import '../helper/constants.dart' as Constants;

class AddPatientScreen extends StatefulWidget {
  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  static const GET_DEPARTMENT = 'loginkhoa';
  static const LOGIN_DEVICE = 'loginthietbi';
  static const ADD_PATIENT = 'registerbenhnhan';

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final scrollController = ScrollController();
  final idPatientController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final idDeviceController = TextEditingController();
  final roomController = TextEditingController();
  final bedController = TextEditingController();
  final patientController = TextEditingController();

  SharedPrefsHelper sharedPrefsHelper;
  MQTTClientWrapper mqttClientWrapper;
  String currentSelectedValue;
  List<Department> departments = List();
  List<ThietBi> tbs = List();
  List<String> dropDownItems = [''];
  String pubTopic;
  String khoa;

  @override
  void initState() {
    initMqtt();
    initController();
    super.initState();
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
    sharedPrefsHelper = SharedPrefsHelper();
    khoa = await sharedPrefsHelper.getStringValuesSF('khoa');
    print('_AddPatientScreenState.initMqtt $currentSelectedValue');

    Department d = Department('','', khoa, Constants.mac);
    pubTopic = LOGIN_DEVICE;
    publishMessage(pubTopic, jsonEncode(d));
    showLoadingDialog();
  }

  void handle(String message) {
    Map responseMap = jsonDecode(message);
    DeviceResponse response = DeviceResponse.fromJson(responseMap);

    if (response.errorCode != '0' && response.result == 'true') {
      return;
    }

    switch (pubTopic) {
      case GET_DEPARTMENT:
        departments = response.id.map((e) => Department.fromJson(e)).toList();
        dropDownItems.clear();
        departments.forEach((element) {
          dropDownItems.add(element.diachidiadiem);
        });
        hideLoadingDialog();
        print('_DeviceListScreenState.handleDevice ${dropDownItems.length}');
        break;
      case ADD_PATIENT:
        Dialogs.showAlertDialog(
            context, 'Thêm thành công!');
        // navigatorPush(
        //     context,
        //     HomeScreen(
        //       index: 1,
        //     ));
        break;
      case LOGIN_DEVICE:
        tbs = response.id.map((e) => ThietBi.fromJson(e)).toList();
        dropDownItems.clear();
        tbs.forEach((element) {
          dropDownItems.add(element.matb);
        });
        setState(() {});
        hideLoadingDialog();
        print('_DeviceListScreenState.handleDevice ${dropDownItems.length}');
        break;
    }
  }

  void initController() async {
    // nameController.text = widget.patient.ten;
    // phoneController.text = widget.patient.sdt;
    // addressController.text = widget.patient.nha;
    // idDeviceController.text = widget.patient.matb;
    // roomController.text = widget.patient.phong;
    // bedController.text = widget.patient.giuong;
    // patientController.text = widget.patient.benhan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thêm bệnh nhân',
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: scrollController,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTextField(
                  'Mã bệnh nhân *',
                  Icon(Icons.email),
                  TextInputType.text,
                  idPatientController,
                ),
                buildTextField(
                  'Tên *',
                  Icon(Icons.email),
                  TextInputType.text,
                  nameController,
                ),
                buildDepartment(),
                buildTextField(
                  'Phòng *',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  roomController,
                ),
                buildTextField(
                  'Giường',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  bedController,
                ),
                buildTextField(
                  'SĐT',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  phoneController,
                ),
                buildTextField(
                  'Địa chỉ',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  addressController,
                ),
                buildTextField(
                  'Bệnh án',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  patientController,
                ),
                buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, Icon prefixIcon,
      TextInputType keyboardType, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 44,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autocorrect: false,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: labelText,
          // labelStyle: ,
          // hintStyle: ,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 20,
          ),
          // suffixIcon: Icon(Icons.account_balance_outlined),
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }

  Widget buildDepartment() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          5,
        ),
        border: Border.all(
          color: Colors.green,
        ),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: 32,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Text(
            'Thiết bị *',
            style: TextStyle(fontSize: 16),
          )),
          Expanded(
            child: dropdownDepartment(),
          ),
        ],
      ),
    );
  }

  Widget dropdownDepartment() {
    return Container(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text("Chọn thiết bị"),
          value: currentSelectedValue,
          isDense: true,
          onChanged: (newValue) {
            setState(() {
              currentSelectedValue = newValue;
            });
            print(currentSelectedValue);
          },
          items: dropDownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget buildButton() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 32,
      ),
      child: Row(
        children: [
          // Expanded(
          //   child: FlatButton(
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     child: Text('Hủy'),
          //   ),
          // ),
          Expanded(
            child: RaisedButton(
              onPressed: () {
                if (idPatientController.text.isEmpty ||
                    nameController.text.isEmpty ||
                    currentSelectedValue.isEmpty ||
                    roomController.text.isEmpty) {
                  Dialogs.showAlertDialog(
                      context, 'Vui lòng nhập đủ thông tin bắt buộc!');
                  return;
                }
                Patient p = Patient(
                  idPatientController.text,
                  utf8.encode(nameController.text).toString(),
                  phoneController.text,
                  utf8.encode(addressController.text).toString(),
                  currentSelectedValue,
                  roomController.text,
                  bedController.text,
                  utf8.encode(patientController.text).toString(),
                  0.0,
                  khoa,
                  '',
                  Constants.mac,
                );
                pubTopic = ADD_PATIENT;
                publishMessage(pubTopic, jsonEncode(p));
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

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
    Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
  }

  @override
  void dispose() {
    scrollController.dispose();
    nameController.dispose();
    idPatientController.dispose();
    phoneController.dispose();
    addressController.dispose();
    idDeviceController.dispose();
    roomController.dispose();
    bedController.dispose();
    patientController.dispose();
    super.dispose();
  }
}
