import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import '../providers/sqlService.dart';
import 'package:sms/sms.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class QuestionPage extends StatefulWidget{
  @override 
  State createState(){
    return _questionPageState();
  }
}

class _questionPageState extends State{
  List questions;
  Iterable<CallLogEntry> _callLog;
  SmsQuery query = new SmsQuery();
  final sqlService = SqlService();
  void initState(){
    super.initState();
    getCallLogs();
    _initPlatformState();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        child: Text('This is question page')
      )
    );
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

  void getCallLogs() async{
    var now = DateTime.now();
    int from = now.millisecondsSinceEpoch;
    int to = now.subtract(Duration(days: 100)).millisecondsSinceEpoch;
    Iterable<CallLogEntry> callLog = await CallLog.get();
    callLog.take(5).forEach((log)=>{
      print(log.timestamp)
    });
  }
  void getSms() async{
    List<SmsMessage> messages = await query.getAllSms;
    messages.forEach((sms){
      print(sms.sender);
    });
    
  }
}