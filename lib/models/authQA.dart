
class AuthQA {
  int id; 
  int type;
  String question;
  String answer;
  bool isDeleted;

  AuthQA({this.id, this.type, this.question, this.answer, this.isDeleted});

  AuthQA.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.type = json['type'];
    this.question = json['question'];
    this.answer = json['answer'];
    this.isDeleted = json['isDeleted'] == 1;
  }
}