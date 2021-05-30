import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/model/department.dart';

import '../helper/constants.dart' as Constants;

class EditDepartmentDialog extends StatefulWidget {
  final Department department;
  final Function(dynamic) editCallback;
  final Function(dynamic) deleteCallback;

  const EditDepartmentDialog({
    Key key,
    this.department,
    this.editCallback,
    this.deleteCallback,
  }) : super(key: key);

  @override
  _EditDepartmentDialogState createState() => _EditDepartmentDialogState();
}

class _EditDepartmentDialogState extends State<EditDepartmentDialog> {
  static const UPDATE_KHOA = 'updatekhoa';
  static const DELETE_KHOA = 'deletekhoa';

  final scrollController = ScrollController();
  final nameController = TextEditingController();
  final idController = TextEditingController();
  bool update = false;
  String pubTopic;
  MQTTClientWrapper mqttClientWrapper;
  Department edittedDepartment;

  @override
  void initState() {
    initController();
    initMqtt();
    super.initState();
  }

  void initController() async {
    nameController.text = widget.department.departmentNameDecode;
    idController.text = widget.department.mavitri;
  }

  @override
  Widget build(BuildContext context) {
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
                  'Tên',
                  Icon(Icons.email),
                  TextInputType.text,
                  nameController,
                ),
                buildTextField(
                  'Mã',
                  Icon(Icons.vpn_key),
                  TextInputType.visiblePassword,
                  idController,
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
        enabled: labelText == 'Mã' ? false : true,
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

  Widget deleteButton() {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 86,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
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
                'Xóa vị trí ?',
              ),
              actions: <Widget>[
                new FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: new Text(
                    'Hủy',
                  ),
                ),
                new FlatButton(
                  onPressed: () {
                    pubTopic = DELETE_KHOA;
                    var d = Department(widget.department.vitri,
                        widget.department.mavitri, Constants.mac);
                    publishMessage(pubTopic, jsonEncode(d));
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
              'Xóa vị trí',
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
                widget.editCallback('abc');
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
          ),
          Expanded(
            child: RaisedButton(
              onPressed: () {
                update = true;
                edittedDepartment = Department(
                  utf8.encode(nameController.text).toString(),
                  idController.text,
                  Constants.mac,
                );
                pubTopic = UPDATE_KHOA;
                publishMessage(pubTopic, jsonEncode(edittedDepartment));
              },
              color: Colors.blue,
              child: Text('Lưu'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initMqtt() async {
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => handleDepartment(message));
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

  void handleDepartment(String message) {
    Map responseMap = jsonDecode(message);
    print(
        '${responseMap['errorCode'] is String}, ${responseMap['result'] is String}');
    if (responseMap['errorCode'] == '0' && responseMap['result'] == 'true') {
      switch (pubTopic) {
        case UPDATE_KHOA:
          widget.editCallback(edittedDepartment);
          break;
        case DELETE_KHOA:
          widget.deleteCallback('true');
          Navigator.of(context).pop();
          break;
      }
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    nameController.dispose();
    idController.dispose();
    super.dispose();
  }
}
