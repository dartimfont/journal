import 'package:flutter/material.dart';

class Lab {
  int id_lab;
  String lab;
  Lab({
    @required this.id_lab,
    @required this.lab,
  });

  factory Lab.fromJson(Map<String, dynamic> json) => Lab(
    id_lab: json["id_lab"],
    lab: json["lab"],
  );

  Map<String, dynamic> toJson() => {
    "id_lab": id_lab,
    "lab": lab,
  };
}