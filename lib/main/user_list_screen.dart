import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health_care/dialogWidget/edit_user_dialog.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/model/department.dart';
import 'package:health_care/model/user.dart';
import 'package:health_care/response/device_response.dart';

import '../helper/constants.dart' as Constants;

class UserListScreen extends StatefulWidget {
  final Map response;

  const UserListScreen({Key key, this.response}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  static const GET_DEPARTMENT = 'loginkhoa';
  static const GET_USER = 'getuser';
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  DeviceResponse response;
  List<User> users = List();
  MQTTClientWrapper mqttClientWrapper;
  SharedPrefsHelper sharedPrefsHelper;
  List<Department> departments = List();
  var dropDownItems = [''];
  int selectedIndex;
  String pubTopic;

  bool isLoading = true;

  @override
  void initState() {
    initMqtt();
    sharedPrefsHelper = SharedPrefsHelper();
    super.initState();
  }

  Future<Null> getSharedPrefs() async {
    setState(() async {
      getUsers();
    });
  }

  void getUsers() async {
    String email = await sharedPrefsHelper.getStringValuesSF('email');
    String password = await sharedPrefsHelper.getStringValuesSF('password');
    showLoadingDialog();
    pubTopic = GET_USER;
    publishMessage(
      pubTopic,
      jsonEncode(
        User(
          Constants.mac,
          email,
          password,
          '',
          '',
          '',
          '',
          '',
          '',
        ),
      ),
    );
  }

  Future<void> initMqtt() async {
    mqttClientWrapper = MQTTClientWrapper(
        () => print('Success'), (message) => handleUser(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);
    getSharedPrefs();
  }

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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Danh sách tài khoản'),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      child: Column(
        children: [
          buildTableTitle(),
          horizontalLine(),
          buildListView(),
          horizontalLine(),
        ],
      ),
    );
  }

  Widget buildTableTitle() {
    return Container(
      color: Colors.yellow,
      height: 40,
      child: Row(
        children: [
          buildTextLabel('STT', 1),
          verticalLine(),
          buildTextLabel('Username', 4),
          verticalLine(),
          buildTextLabel('Tên', 4),
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

  Widget buildListView() {
    return Container(
      child: Expanded(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: users.length,
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
        Department d = Department('', '','', Constants.mac);
        pubTopic = GET_DEPARTMENT;
        publishMessage(pubTopic, jsonEncode(d));
        showLoadingDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Column(
          children: [
            Container(
              height: 40,
              child: Row(
                children: [
                  buildTextData('${index + 1}', 1),
                  verticalLine(),
                  buildTextData(users[index].user, 4),
                  verticalLine(),
                  buildTextData(users[index].tenDecode, 4),
                ],
              ),
            ),
            horizontalLine(),
          ],
        ),
      ),
    );
  }

  void removeUser(int index) async {
    setState(() {
      users.removeAt(index);
      print('_UserListScreenState.removeUser ${users.length}');
    });
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

  void handleUser(String message) async {
    Map responseMap = jsonDecode(message);
    var response = DeviceResponse.fromJson(responseMap);
    switch (pubTopic) {
      case GET_DEPARTMENT:
        departments = response.id.map((e) => Department.fromJson(e)).toList();
        dropDownItems.clear();
        departments.forEach((element) {
          dropDownItems.add(element.madiadiem);
        });
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
                      EditUserDialog(
                        user: users[selectedIndex],
                        dropDownItems: dropDownItems,
                        deleteCallback: (param) => {
                          getUsers(),
                          // removeUser(selectedIndex),
                        },
                        updateCallback: (user) {
                          getUsers();
                          // users.removeAt(selectedIndex);
                          // users.insert(selectedIndex, user);
                          // setState(() {});
                        },
                      ),
                      Positioned(
                        right: 0.0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            getUsers();
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
        print('_EditUserDialogState.handle ${departments.length}');
        break;
      case GET_USER:
        users = response.id.map((e) => User.fromJson(e)).toList();
        setState(() {});
        hideLoadingDialog();
        break;
    }
  }

  void showLoadingDialog() {
    setState(() {
      isLoading = true;
    });
    // Dialogs.showLoadingDialog(context, _keyLoader);
  }

  void hideLoadingDialog() {
    setState(() {
      isLoading = false;
    });
    // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
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
}
