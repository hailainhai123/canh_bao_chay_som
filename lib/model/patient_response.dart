// To parse this JSON data, do
//
//     final patientResponse = patientResponseFromJson(jsonString);

import 'dart:convert';

import 'package:health_care/model/patient.dart';

PatientResponse patientResponseFromJson(String str) =>
    PatientResponse.fromJson(json.decode(str));

String patientResponseToJson(PatientResponse data) =>
    json.encode(data.toJson());

class PatientResponse {
  PatientResponse({
    this.errorCode,
    this.message,
    this.patients,
    this.result,
  });

  String errorCode;
  String message;
  List<Patient> patients;
  String result;

  factory PatientResponse.fromJson(Map<String, dynamic> json) =>
      PatientResponse(
        errorCode: json["errorCode"],
        message: json["message"],
        patients: List<Patient>.from(json["id"].map((x) => Patient.fromJson(x))),
        result: json["result"],
      );

  Map<String, dynamic> toJson() => {
        "errorCode": errorCode,
        "message": message,
        "id": List<dynamic>.from(patients.map((x) => x.toJson())),
        "result": result,
      };
}
