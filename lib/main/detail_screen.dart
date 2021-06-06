import 'dart:convert';

import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:health_care/helper/config.dart';
import 'package:health_care/helper/models.dart';
import 'package:health_care/helper/mqttClientWrapper.dart';
import 'package:health_care/helper/shared_prefs_helper.dart';
import 'package:health_care/login/login_page.dart';
import 'package:health_care/model/thietbi.dart';
import 'package:health_care/navigator.dart';
import 'package:health_care/response/device_response.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../helper/constants.dart' as Constants;

class DetailScreen extends StatefulWidget {
  final String madiadiem;

  const DetailScreen({Key key, this.madiadiem}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  MQTTClientWrapper mqttClientWrapper;

  final sharedPrefs = SharedPrefsHelper();
  List<ThietBi> tbs = List();
  String email;
  String pubTopic;
  bool isLoading = true;

  var dropDownProducts = [''];
  String _selectedProduct;
  String _selectedDevice;
  var itemColor;

  @override
  void initState() {
    getSharedPrefs();
    initMqtt();
    super.initState();
  }

  void getDevices() async {
    ThietBi t = ThietBi('', widget.madiadiem, '', '', '', Constants.mac, '');
    // t.mathietbi = email;
    pubTopic = Constants.GET_DEVICE;
    publishMessage(pubTopic, jsonEncode(t));
    showLoadingDialog();

    // tbs = createSampleDevices();
    // isLoading = false;
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

  void getSharedPrefs() async {
    email = await sharedPrefs.getStringValuesSF('email');
  }

  Future<void> matchImages() async {
    tbs.forEach((element) {
      element.nguongcb = sharedPrefs.getStringValuesSF('${element.matb}');
    });
  }

  @override
  Widget build(BuildContext context) {
    matchImages();
    return Scaffold(
      appBar: AppBar(
        title: Text('Giám sát'),
        centerTitle: true,
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                navigatorPushAndRemoveUntil(context, LoginPage());
              }),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : buildBody(),
    );
  }

  Widget buildBody() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return buildItem(tbs[index]);
              },
              itemCount: tbs.length,
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(ThietBi tb) {
    return GestureDetector(
      onTap: () {
        _selectedDevice = tb.matb;
        // navigatorPush(context, RollingDoor());
        // getProducts();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(tb.tu ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: tb.color ?? Colors.black,
                )),
            SizedBox(height: 15),
            // Text(
            //   tb.nhietdo != null ? '${tb.nhietdo}\u2103' : '0\u2103',
            // ),
            sleek(tb.nhietdo ?? "0"),
            // Image.asset(
            //   'assets/icons/ic_scale.png',
            //   width: 40,
            //   height: 40,
            //   fit: BoxFit.cover,
            // ),
            SizedBox(height: 10),
            // Text(tb.can ?? '...'),
          ],
        ),
      ),
    );
  }

  void showLoadingDialog() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(seconds: 3), hideLoadingDialog);
  }

  void hideLoadingDialog() {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> initMqtt() async {
    mqttClientWrapper =
        MQTTClientWrapper(() => print('Success'), (message) => handle(message));
    await mqttClientWrapper.prepareMqttClient(Constants.mac);

    getDevices();

    mqttClientWrapper.subscribe(widget.madiadiem, (_message) {
      print('_DetailScreenState.initMqtt $_message');
      var result = _message.replaceAll("\"", "").split('&');

      // var scaleResponse = scaleResponseFromJson(_message);
      tbs.forEach((element) {
        print('_DetailScreenState.initMqtt ${element.matb}');
        print('_DetailScreenState.initMqtt ${result[0]}');
        if (element.matb == result[0]) {
          element.nhietdo = result[1];
          if (double.tryParse(element.nhietdo) >
              double.tryParse(element.nguongcb)) {
            element.color = Colors.red;
          } else {
            element.color = Colors.black;
          }
          // changeItemColor(element);
          setState(() {});
        } else {
          print('_DetailScreenState.initMqtt false');
        }
      });
    });
  }

  void changeItemColor(ThietBi element) {
    Future.delayed(Duration(milliseconds: 500), () {
      element.color = Colors.white;
      setState(() {});
    });
  }

  void handle(String message) {
    try {
      Map responseMap = jsonDecode(message);
      var response = DeviceResponse.fromJson(responseMap);

      switch (pubTopic) {
        case Constants.GET_DEVICE:
          tbs = response.id.map((e) => ThietBi.fromJson(e)).toList();
          setState(() {});
          hideLoadingDialog();
          break;
      }
      pubTopic = '';
    } catch (e) {
      print('_DetailScreenState.handle $e');
    }
  }

  Widget clayContainer(String nhietdo) {
    double nd = double.tryParse(nhietdo);
    return ClayContainer(
      height: 50,
      width: 50,
      color: primaryColor,
      borderRadius: 10,
      child: Padding(
        padding: EdgeInsets.all(4),
        child: SleekCircularSlider(
          appearance: CircularSliderAppearance(
            customColors: CustomSliderColors(
              progressBarColors: gradientColors,
              hideShadow: true,
              shadowColor: Colors.transparent,
            ),
            infoProperties: InfoProperties(
                mainLabelStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                modifier: (double value) {
                  final roundedValue = nd.ceil().toInt().toString();
                  return '$roundedValue \u2103';
                }),
          ),
          // onChange: (double value) {
          //   print(value);
          // }
        ),
      ),
    );
  }

  Widget sleek(String nhietdo) {
    double nd = double.tryParse(nhietdo);
    if (nd >= 200) nd = 200;
    return Container(
      width: 95,
      height: 95,
      child: SleekCircularSlider(
        appearance: CircularSliderAppearance(
          customColors: CustomSliderColors(
            progressBarColors: gradientColors,
            hideShadow: true,
            shadowColor: Colors.transparent,
          ),
          customWidths: CustomSliderWidths(progressBarWidth: 10),
          infoProperties: InfoProperties(
              mainLabelStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              modifier: (double value) {
                final roundedValue = nd.ceil().toInt().toString();
                return '$roundedValue \u2103';
              }),
        ),
        min: 0,
        max: 200,
        initialValue: nd,
      ),
    );
  }

// void _showChooseProduct() {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: new Text("Chọn sản phẩm"),
//         content: Container(
//           height: 200,
//           width: 200,
//           child: Column(
//             children: <Widget>[
//               Text("Chọn sản phẩm để cân"),
//               StatefulBuilder(
//                 builder: (context, dropDownState) {
//                   return DropdownButton<String>(
//                     value: _selectedProduct,
//                     underline: Container(),
//                     items: dropDownProducts.map((String value) {
//                       return new DropdownMenuItem<String>(
//                         value: value,
//                         child: new Text(
//                           value,
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                       );
//                     }).toList(),
//                     onChanged: (String value) {
//                       dropDownState(() {
//                         _selectedProduct = value;
//                         var s = ScaleRequest(email, _selectedProduct);
//                         // publishMessage(_selectedDevice, jsonEncode(s));
//                       });
//                     },
//                   );
//                 },
//               ),
//               // StatefulBuilder(
//               //   builder: (context, radioState) {
//               //     return Column(
//               //       children: [
//               //         ListTile(
//               //           title: Text('Xuất Kho '),
//               //           leading: Radio(
//               //             value: ListXuatNhap.xuatKho,
//               //             groupValue: _site,
//               //             onChanged: (ListXuatNhap value) {
//               //               radioState(() {
//               //                 _site = value;
//               //               });
//               //             },
//               //           ),
//               //         ),
//               //         // ListTile(
//               //         //   title: Text('Nhập Kho '),
//               //         //   leading: Radio(
//               //         //     value: ListXuatNhap.nhapKho,
//               //         //     groupValue: _site,
//               //         //     onChanged: (ListXuatNhap value) {
//               //         //       radioState(() {
//               //         //         _site = value;
//               //         //       });
//               //         //     },
//               //         //   ),
//               //         // ),
//               //       ],
//               //     );
//               //   },
//               // ),
//
//               // StatefulBuilder(
//               //   builder: (context, dropDownState) {
//               //     return new DropdownButton(
//               //       items: new List.generate(20, (int index) {
//               //         return new DropdownMenuItem(
//               //           child: Container(
//               //             child: new Text("Item#$index"),
//               //             width: 200.0, //200.0 to 100.0
//               //           ),
//               //         );
//               //       }),
//               //     );
//               //   },
//               // ),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           // usually buttons at the bottom of the dialog
//           FlatButton(
//             child: new Text("Đóng"),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
}

ScaleResponse scaleResponseFromJson(String str) =>
    ScaleResponse.fromJson(json.decode(str));

String scaleResponseToJson(ScaleResponse data) => json.encode(data.toJson());

class ScaleResponse {
  ScaleResponse({
    this.matb,
    this.nhietdo,
  });

  String matb;
  String nhietdo;

  factory ScaleResponse.fromJson(Map<String, dynamic> json) => ScaleResponse(
        matb: json["matb"],
        nhietdo: json["nhietdo"],
      );

  Map<String, dynamic> toJson() => {
        "matb": matb,
        "nhietdo": nhietdo,
      };
}
