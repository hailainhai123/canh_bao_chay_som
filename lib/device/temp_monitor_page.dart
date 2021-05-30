import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/model/device.dart';

class TempPage extends StatefulWidget {
  final Device device;
  final String iduser;

  TempPage(this.device, this.iduser);

  @override
  State<StatefulWidget> createState() {
    return _TempPageState();
  }
}

class _TempPageState extends State<TempPage> {
  MQTTClientWrapper mqttClientWrapper;

  bool showAvg = false;

  @override
  void initState() {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    mqttClientWrapper.prepareMqttClient('S${widget.device.matb}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Theo dõi thiết bị"),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        tempContainer(),
      ],
    ));
  }

  Widget tempContainer() {
    return Container();
  }

  handle(String message) {}
}
