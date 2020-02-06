import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securelist/providers/appState.dart';
import 'package:securelist/providers/bgLocationService.dart';
import '../providers/dbService.dart';
import '../providers/bgLocationService.dart';
import '../providers/sqlService.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
class ListPage extends StatefulWidget{
  @override 
  State<StatefulWidget> createState(){
    return _listPageState();
  }
}


class _listPageState extends State<ListPage>{
  //_listPageState();
  List _places = [];
  void initState(){
    super.initState();
    _initPlatformState();

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
      body: Container(child: Text(_places.toString())),
    );
  }

  void _showDialog(context){
    print('clicked');
    showModalBottomSheet(
      context: context, 
      builder: (BuildContext context){
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: "Title"
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Description"
                )
              ),
              ButtonBar(
                children: [
                  FlatButton(
                    onPressed: (){},
                    child: Text('Cancel')
                  ),
                  RaisedButton(
                    onPressed: (){},
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
  // Widget _buildLayout(BuildContext context){
  //   return Container(
  //     child: Consumer<DbService>(builder:(context, dbService, child){
  //       return Container(
  //         child: _buildList(dbService)
  //       );
  //     })
  //   );
  // }
  // Widget _buildList(dbService){
  //   dbService.getCallLog();
  //   //dbService.getBrowserHistory();
  //   //_bgLocationService.configAndStart();
  //   return  Container(
  //       child: Text(_places.toString())
  //     );
  // }
}