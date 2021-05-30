import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/dialogWidget/history_page.dart';
import 'package:health_care/helper/loader.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/model/patient.dart';

import '../helper/constants.dart' as Constants;

class EditPatientDialog extends StatefulWidget {
  final Patient patient;
  final List<String> dropDownItems;
  final Function(dynamic) updateCallback;
  final Function(dynamic) deleteCallback;

  const EditPatientDialog({
    Key key,
    this.patient,
    this.dropDownItems,
    this.updateCallback,
    this.deleteCallback,
  }) : super(key: key);

  @override
  _EditPatientDialogState createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  static const UPDATE_PATIENT = 'updatebenhnhan';
  static const DELETE_PATIENT = 'deletebenhnhan';

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

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  String khoa;
  String currentSelectedValue;
  String pubTopic;
  Patient updatedPatient;

  @override
  void initState() {
    initMqtt();
    initController();
    initSharedPrefs();
    super.initState();
  }

  void initSharedPrefs() async {
    sharedPrefsHelper = SharedPrefsHelper();
    khoa = await sharedPrefsHelper.getStringValuesSF('khoa');
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
  }

  void initController() async {
    idPatientController.text = widget.patient.mabenhnhan;
    nameController.text = widget.patient.tenDecode;
    phoneController.text = widget.patient.sdt;
    addressController.text = widget.patient.nhaDecode;
    idDeviceController.text = widget.patient.mathietbi;
    roomController.text = widget.patient.phong;
    bedController.text = widget.patient.giuong;
    patientController.text = widget.patient.benhDecode;
    currentSelectedValue = widget.patient.mathietbi;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return tabBar();
  }

  Widget infoTab() {
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
                // buildTempLayout(
                //   widget.patient.nhietdo,
                // ),
                buildTextField(
                  'Mã bệnh nhân',
                  Icon(Icons.vpn_key_outlined),
                  TextInputType.text,
                  idPatientController,
                ),
                buildTextField(
                  'Tên',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  nameController,
                ),
                buildDepartment(),
                buildTextField(
                  'Phòng',
                  Icon(Icons.sensor_door_outlined),
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
                  Icon(Icons.phone),
                  TextInputType.visiblePassword,
                  phoneController,
                ),
                buildTextField(
                  'Địa chỉ',
                  Icon(Icons.location_on),
                  TextInputType.text,
                  addressController,
                ),
                buildTextField(
                  'Bệnh án',
                  Icon(Icons.list),
                  TextInputType.text,
                  patientController,
                ),
                deleteButton(),
                buildButton(),
              ],
            ),
          ),
        ),
      ),
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
        enabled: labelText == 'Mã bệnh nhân' ? false : true,
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

  Widget tabBar() {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            bottom: TabBar(
                unselectedLabelColor: Colors.blue,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blueAccent),
                tabs: [
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(color: Colors.blueAccent, width: 1)),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Lịch sử"),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border:
                              Border.all(color: Colors.blueAccent, width: 1)),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Thông tin"),
                      ),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: [
            HistoryPage(
              patient: widget.patient,
            ),
            infoTab(),
          ]),
        ));
  }

  Widget deleteButton() {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 86,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: Offset(1.0, 1.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: new Text(
                'Xóa bệnh nhân ?',
              ),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () {
                    widget.updateCallback('abc');
                    Navigator.of(context).pop();
                  },
                  child: new Text(
                    'Hủy',
                  ),
                ),
                new FlatButton(
                  onPressed: () {
                    EditPatient e =
                        EditPatient(widget.patient.mabenhnhan, Constants.mac);
                    pubTopic = DELETE_PATIENT;
                    publishMessage(pubTopic, jsonEncode(e));
                  },
                  child: new Text(
                    'Đồng ý',
                  ),
                ),
              ],
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Colors.red,
            ),
            Text(
              'Xóa bệnh nhân',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ],
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
          Expanded(
            child: FlatButton(
              onPressed: () {
                widget.updateCallback('abc');
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
          ),
          Expanded(
            child: RaisedButton(
              onPressed: () {
                updatedPatient = Patient(
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
                pubTopic = UPDATE_PATIENT;
                publishMessage(pubTopic, jsonEncode(updatedPatient));
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDepartment() {
    return Container(
      height: 44,
      width: double.infinity,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Mã thiết bị',
            ),
          ),
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
          items: widget.dropDownItems.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  void showLoadingDialog() {
    Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
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

  void handle(String message) {
    switch (pubTopic) {
      case DELETE_PATIENT:
        widget.deleteCallback('123');
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        break;
      case UPDATE_PATIENT:
        widget.updateCallback(updatedPatient);
        Navigator.of(context).pop();
        break;
    }
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

class EditPatient {
  final String mabenhnhan;
  final String mac;

  EditPatient(this.mabenhnhan, this.mac);

  Map<String, dynamic> toJson() => {
        'mabenhnhan': mabenhnhan,
        'mac': mac,
      };
}
