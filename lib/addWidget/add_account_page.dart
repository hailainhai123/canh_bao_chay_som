import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/helper/loader.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/model/user.dart';

import '../helper/constants.dart' as Constants;

class AddAccountScreen extends StatefulWidget {
  final List<String> dropDownItems;

  const AddAccountScreen({Key key, this.dropDownItems}) : super(key: key);

  @override
  _AddAccountScreenState createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;

  final scrollController = ScrollController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final makhoaController = TextEditingController();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  String currentSelectedValue;
  String permission;

  @override
  void initState() {
    initMqtt();
    initController();
    super.initState();
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
          'Thêm tài khoản',
        ),
        centerTitle: true,
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
                  'Username *',
                  Icon(Icons.email),
                  TextInputType.text,
                  usernameController,
                ),
                buildTextField(
                  'Mật khẩu *',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  passwordController,
                ),
                buildTextField(
                  'Tên',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  nameController,
                ),
                buildTextField(
                  'Địa chỉ',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  addressController,
                ),
                buildTextField(
                  'Số điện thoại',
                  Icon(Icons.perm_identity),
                  TextInputType.text,
                  phoneController,
                ),
                buildDepartment('Khoa'),
                buildPermissionContainer('Quyền'),
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
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
          ),
          Expanded(
            child: RaisedButton(
              onPressed: () {
                tryRegisterUser();
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

  void tryRegisterUser() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Dialogs.showAlertDialog(context, 'Vui lòng nhập đủ thông tin bắt buộc!');
      return;
    }

    User user = User(
      Constants.mac,
      usernameController.text,
      passwordController.text,
      utf8.encode(nameController.text).toString(),
      phoneController.text,
      utf8.encode(addressController.text).toString(),
      currentSelectedValue,
      permission,
      '',
    );
    publishMessage('registeruser', jsonEncode(user));
  }

  Widget buildDepartment(String label) {
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
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Text(
            label,
            style: TextStyle(fontSize: 16),
          )),
          Expanded(
            child: dropdownDepartment(),
          ),
        ],
      ),
    );
  }

  Widget buildPermissionContainer(String label) {
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
        vertical: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Text(
            label,
            style: TextStyle(fontSize: 16),
          )),
          Expanded(
            child: dropDownPermission(),
          ),
        ],
      ),
    );
  }

  Widget dropdownDepartment() {
    return Container(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text("Chọn khoa"),
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

  Widget dropDownPermission() {
    var permissionValue = ['1', '2'];
    return Container(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text("Chọn quyền"),
          value: permission,
          isDense: true,
          onChanged: (newValue) {
            setState(() {
              permission = newValue;
            });
            print(permission);
          },
          items: permissionValue.map((String value) {
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

  void handle(String message) {
    Map responseMap = jsonDecode(message);
    if (responseMap['result'] == 'true' && responseMap['errorCode'] == '0') {
      Navigator.of(context).pop();
    }
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
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

  @override
  void dispose() {
    scrollController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    makhoaController.dispose();
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
