
class Todo {
  int id; 
  String title;
  String description;
  int status;
  bool isDeleted;

  Todo({this.id, this.title, this.description, this.status, this.isDeleted});

  Todo.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.title = json['title'];
    this.description = json['description'];
    this.status = json['status'];
    this.isDeleted = json['isDeleted'] == 1;
  }

}