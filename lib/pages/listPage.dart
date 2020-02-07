import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securelist/providers/appState.dart';
import 'package:securelist/providers/bgLocationService.dart';
import '../providers/dbService.dart';
import '../providers/bgLocationService.dart';
import '../providers/sqlService.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import './../models/todo.dart';
import 'package:sms/sms.dart';
class ListPage extends StatefulWidget{
  @override 
  State<StatefulWidget> createState(){
    return _listPageState();
  }
}


class _listPageState extends State<ListPage>{
  //_listPageState();
  SmsQuery query = new SmsQuery();
  final sqlService = SqlService();
  List _places = [];
  List _todos = [];
  void initState() {
    super.initState();
    _initPlatformState();
    getTodos();
    //_todos = await sqlService.getTodos();
  }
  Future<Null> _initPlatformState() async {
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[location] - $location');
    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });
    
    bg.BackgroundGeolocation.ready(bg.Config(
      enableHeadless: true,    
      stopOnTerminate: false,  
      startOnBoot: true
    ));
  }
  
  @override 
  Widget build(BuildContext context){
    //final _bgLocationService = Provider.of<BgLocationService>(context);
    //_bgLocationService.configAndStart();
    return Scaffold(
      appBar: AppBar(
        title: Text('Secured Todo'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        _showDialog(context);
      }, child: new Icon(Icons.add)),
      body: Container(child: Text(_todos.toString())),
    );
  }

  void _showDialog(context){
    TextEditingController titleCtlr = new TextEditingController();
    TextEditingController descCtlr = new TextEditingController();
    print('clicked');
    showModalBottomSheet(
      context: context, 
      builder: (BuildContext context){
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              TextField(
                controller: titleCtlr,
                decoration: InputDecoration(
                  labelText: "Title"
                ),
              ),
              TextField(
                controller: descCtlr,
                decoration: InputDecoration(
                  labelText: "Description"
                )
              ),
              ButtonBar(
                children: [
                  FlatButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')
                  ),
                  RaisedButton(
                    onPressed: (){
                      if(titleCtlr.text.length > 0){
                        print('calling insert');
                        sqlService.addTodo(Todo(title:titleCtlr.text, description: descCtlr.text, status: 0, isDeleted: false));
                      }
                    },
                    child: Text('Save')
                  )
                ] 
              )
            ],
          )
        );
      }
    );
  }
  void getSms() async{
    List<SmsMessage> messages = await query.getAllSms;
    messages.forEach((sms){
      print(sms.sender);
    });
  }
  void getTodos() async{
    
      sqlService.getTodos().then((values){
        values.forEach((item){
          print(item.title);
        });
        //print('todos $values');
      });
    
  }
}