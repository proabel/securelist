import './option.dart';
class AuthQA {
  int id; 
  int type;
  String question;
  String options;
  bool isDeleted;

  AuthQA({this.id, this.type, this.question, this.options, this.isDeleted});

  AuthQA.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.type = json['type'];
    this.question = json['question'];
    this.options = json['options'];
    this.isDeleted = json['isDeleted'] == 1;
  }
}