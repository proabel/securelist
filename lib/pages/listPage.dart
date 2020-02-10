import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securelist/providers/appState.dart';
import 'package:securelist/providers/bgLocationService.dart';
import '../providers/dbService.dart';
import '../providers/bgLocationService.dart';
import '../providers/sqlService.dart';
import './../models/todo.dart';
class ListPage extends StatefulWidget{
  @override 
  State<StatefulWidget> createState(){
    return _listPageState();
  }
}


class _listPageState extends State<ListPage>{
  //_listPageState();
  
  final sqlService = SqlService();
  List _places = [];
  List _todos = [];
  void initState() {
    super.initState();
    //_initPlatformState();
    getTodos();
    
    //_todos = await sqlService.getTodos();
  }
  
  
  @override 
  Widget build(BuildContext context){
    //final _bgLocationService = Provider.of<BgLocationService>(context);
    //_bgLocationService.configAndStart();
    return Scaffold(
      appBar: AppBar(
        title: Text('Secured Todo'),
        actions: <Widget>[
          GestureDetector(
            onTap: (){
              //appState.setAuth(false);
              Navigator.pushReplacementNamed(context, '/question');
            },
            child: Icon(Icons.power_settings_new)
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        _showDialog(context);
      }, child: new Icon(Icons.add)),
      body: _buildLayout(context),
      
    );
  }

  _buildLayout(context){
    if(_todos.length > 0){
      return Container(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _todos.length,
          itemBuilder: (context, index){
            return  Card(
              child:ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                Flexible(
                  child: GestureDetector( 
                    onTap: (){
                      _showTodo(context, _todos[index]);
                    },
                    child: Text(_todos[index].title)
                  ),
                ),
                Flexible(child: _todos[index].status == 1 ? Icon(Icons.done_all, color: Colors.green) : SizedBox.shrink())
              ],),
              trailing: PopupMenuButton(
                onSelected: (value){
                  if(value == 'delete'){
                    sqlService.deleteTodo(_todos[index].id).then((value){
                      getTodos();
                      //Navigator.pushReplacementNamed(context, '/');
                    });
                  }else if(value == 'complete'){
                    _changeStatus(context, _todos[index], 'complete');
                  }else if(value == 'incomplete'){
                    _changeStatus(context, _todos[index], 'incomplete');
                  }
                },
                icon: Icon(Icons.more_vert),
                itemBuilder: (context)=>[
                  PopupMenuItem(
                    value: _todos[index].status == 0 ? 'complete' : 'incomplete',
                    child: _todos[index].status == 0 ? Text('done') : Text('undone')
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('delete'),
                  )
                ]
              )
            ));
        })
      );
    }
    else{
      return Container(
        padding: EdgeInsets.all(10),
        child: Text('Add some todos to the list'),
      );
    }
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
              SizedBox(height: 50,),
              ButtonBar(
                children: [
                  FlatButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('Cancel')
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: (){
                      if(titleCtlr.text.length > 0){
                        print('calling insert');
                        sqlService.addTodo(Todo(title:titleCtlr.text, description: descCtlr.text, status: 0, isDeleted: false)).then((value){
                          print('got returned');
                          getTodos();
                          Navigator.pop(context);
                          //Navigator.pushNamed(context, '/');
                        });
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
  void _showTodo(context, todo){
    showModalBottomSheet(
      context: context, 
      builder: (BuildContext context){
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(todo.title, style: TextStyle(fontSize: 18),),
              SizedBox(height: 10,),
              Text(todo.description, style: TextStyle(fontSize: 14),),
              SizedBox(height: 50,),
              ButtonBar(
                children: [
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('close')
                  ),
                ] 
              )
            ],
          )
        );
      }
    );
  }
  void getTodos() async{
    
      sqlService.getTodos().then((values){
        values.forEach((item){
          setState(() {
            _todos = values;
          });
          //print(item.title);
        });
        //print('todos $values');
      });
    
  }
  void _changeStatus(context,Todo todo, status){
    if(status == 'complete'){
      todo.status = 1;
      sqlService.updateTodo(todo).then((value){
        getTodos();
      });
    }else{
      todo.status = 0;
      sqlService.updateTodo(todo).then((value){
        getTodos();
      });
    }
  }
}