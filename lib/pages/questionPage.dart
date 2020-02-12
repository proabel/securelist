import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:securelist/models/option.dart';
import '../providers/sqlService.dart';
import 'package:sms/sms.dart';
import './../models/authQA.dart';
import 'dart:math';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:geocoder/geocoder.dart';

class QuestionPage extends StatefulWidget{
  @override 
  State createState(){
    return _questionPageState();
  }
}

class _questionPageState extends State{
  List questions = [];
  bool appReady = false;
  Iterable<CallLogEntry> _callLog;
  SmsQuery query = new SmsQuery();
  final sqlService = SqlService();
  void initState(){
    super.initState();
    initiateLogs();
    _initPlatformState();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              child: Center(
                child: Icon(Icons.lock_outline, size: 100, color: Colors.black45),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child:_buildQuestion(context)
            )
          ],
        )
      )
    );
  }
  Future<Null> _initPlatformState() async {
    print('initatoing location');
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      //print('[location] - $location');
      Map loc = {};
      loc['lat'] = location.coords.latitude;
      loc['long'] = location.coords.longitude;
      loc['accuracy'] = location.coords.accuracy;
      loc['timestamp'] = location.timestamp;
      sqlService.addLocation(loc).then((res){

      });
    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
       Map loc = {};
      loc['lat'] = location.coords.latitude;
      loc['lon'] = location.coords.longitude;
      loc['accuracy'] = location.coords.accuracy;
      loc['timestamp'] = location.timestamp;
      sqlService.addLocation(loc).then((res){

      });
    });
    
    // Fired whenever the state of location-services changes.  Always fired at boot
        bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
          print('[providerchange] - $event');
        });

      bg.BackgroundGeolocation.ready(bg.Config(
          enableHeadless: true,
          desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
          distanceFilter: 10.0,
          stopOnTerminate: false,
          startOnBoot: true,
          debug: true,
          logLevel: bg.Config.LOG_LEVEL_VERBOSE
      )).then((bg.State state) {
          if (!state.enabled) {
            bg.BackgroundGeolocation.start();
          }
        
      });
  }

  void initiateLogs() async{
    //call logs

    List<AuthQA> callLogQAs = [];
    var now = DateTime.now();
    int from = now.millisecondsSinceEpoch;
    int to = now.subtract(Duration(days: 100)).millisecondsSinceEpoch;
    Iterable<CallLogEntry> callLog = await CallLog.get();
    List randomNames = [];
    for(final log in callLog){
      if(randomNames.length > 10)
        break;
      if(randomNames.indexOf(log.name) == -1 && log.name != 'null'){
        randomNames.add(log.name);
      }
    }
    //print(randomNames);
    callLog.take(1).forEach((log){
        int i = 0;
        List options = [];
        while(i < 10 && i < randomNames.length){
          if(randomNames[i] != log.name){
            options.add({'answer':randomNames[i], 'isTrue': false});
            if(options.length > 4)
              break;
          }
          i++;
        }   
        //sqlService.addQA(AuthQA(type: 1, question: 'who called you last?', options: options, isDeleted: false));
        callLogQAs.add(AuthQA(type: 1, question: 'who called you last?', options: jsonEncode(options), isDeleted: false));
        //print(AuthQA(type: 1, question: 'who called you last?', options: options, isDeleted: false).toString());
    });
    
    
    List options = [];
    List addedLog = [];
    for(final log in callLog){
      if(addedLog.indexOf(log.name) == -1){
        String time = log.timestamp.toString();
        if(from % 2 == 0){
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).add(new Duration(hours: 2)).toString(), 'isTrue': false});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).add(new Duration(hours: 1)).toString(), 'isTrue': false});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).toString(), 'isTrue': false});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).subtract(new Duration(hours: 1)).toString(), 'isTrue': false});
          
        }
        else{
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).add(new Duration(hours: 1)).toString(), 'isTrue': false});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).toString(), 'isTrue': false});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).subtract(new Duration(hours: 1)).toString(), 'isTrue': false});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).subtract(new Duration(hours: 2)).toString(), 'isTrue': false});
        }
          
        //sqlService.addQA(AuthQA(type: 1, question: 'At what time did ${log.name} called you', options: options, isDeleted: false));
        callLogQAs.add(AuthQA(type: 2, question: 'At what time did ${log.name} called you', options: jsonEncode(options), isDeleted: false));
        //print(AuthQA(type: 2, question: 'At what time did ${log.name} called you', options: options, isDeleted: false).toString());
        addedLog.add(log.name);
        if(addedLog.length > 2)
          break;
      }
      options = [];
    }

    //delete old call qAs
    await sqlService.deleteOldCallQA();

    sqlService.qaBatchInsert(callLogQAs).then((res){
      print('call log qa inserted');
      getQAs();
    });

  }
  void getQAs() async{
    await initiateSms();
    sqlService.getQAs().then((res){
      res.forEach((item){
        setState(() {
          questions.add(item);
        });
      });
    });
  }
  Future initiateSms() async{
    List<SmsMessage> messages = await query.getAllSms;
    List senders = [];
    for(final message in messages){
      if(senders.indexOf(message.sender) != 1){
        senders.add(message.sender);
        if(senders.length > 5)
          break;
      }
    }
    List options = [];
    int i = 0;
    while(i < 6){
      if(i == 0)
        options.add({'answer': senders[i], 'isTrue': true});
      else
        options.add({'answer': senders[i], 'isTrue': false});
      i++;
    }
    sqlService.addQA(AuthQA(type: 3, question: 'which sender sent you the last sms ?', options: jsonEncode(options), isDeleted: false)).then((res){
      setLocationQAs(){

      }
    });
    
  }
  Future setLocationQAs(){
    List locs = [];
    //get location data from sql
    sqlService.getLocations().then((res){
      locs = res.take(20);
      if(res.length > 20){
        //keep last 20
        int i = 20;
        List toDelete = [];
        while(i < res.length){
          toDelete.add(res.id);
          i++;
        }
        sqlService.deleteBatchLocs(toDelete).then((res){
          setLocQAs(locs);
        });
      }
    });
  }

  Future setLocQAs(locs) {
    
    List locQAs = [];
    locs.forEach((loc) async{
      List options = [];
      final coordinates = new Coordinates(1.10, 45.50);
      final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      final first = addresses.first;
      
      String geoName = first.featureName + first.addressLine;
      print('geoName $geoName');
      if(loc.timestamp % 2 == 0){
        options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(loc.timestamp).add(new Duration(hours: 2)).toString(), 'isTrue': false});
        options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(loc.timestamp).add(new Duration(hours: 1)).toString(), 'isTrue': false});
        options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(loc.timestamp).toString(), 'isTrue': false});
        options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(loc.timestamp).subtract(new Duration(hours: 1)).toString(), 'isTrue': false});
        
      }
      else{
        options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(loc.timestamp).add(new Duration(hours: 1)).toString(), 'isTrue': false});
        options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(loc.timestamp).toString(), 'isTrue': false});
        options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(loc.timestamp).subtract(new Duration(hours: 1)).toString(), 'isTrue': false});
        options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(loc.timestamp).subtract(new Duration(hours: 2)).toString(), 'isTrue': false});
      }
        
      //sqlService.addQA(AuthQA(type: 1, question: 'At what time did ${log.name} called you', options: options, isDeleted: false));
      locQAs.add(AuthQA(type: 4, question: 'At what time you were at $geoName', options: jsonEncode(options), isDeleted: false));
      //print(AuthQA(type: 2, question: 'At what time did ${log.name} called you', options: options, isDeleted: false).toString());  
        
    });
    sqlService.qaBatchInsert(locQAs).then((res){
        // app ready
    });
    //sqlService.addQA(AuthQA(type: 4, question: 'At what time you were at ?', options: jsonEncode(options), isDeleted: false)).then((res){


  }

  Widget _buildQuestion(context){
    final _random = new Random();
    AuthQA question = questions[_random.nextInt(questions.length)];
    print(question.options);
    List options = jsonDecode(question.options);
    return Container(
      child: Column(
        children: [
          Text(question.question),
          SizedBox(height:20),
          Container(
            height: 300,
            child: _buildAnswer(context, options, question.type)
          )
        ]
      ),
    );
  }

  Widget _buildAnswer(context, options, type){
    if(type == 2){
      var formatter = new DateFormat('HH:mm a');
      return ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index){
          return RaisedButton(
            //child: Text((options[index]['answer'])),
            child: Text(formatter.format(DateTime.parse(options[index]['answer']))),
          );
        }
      );
    }else{
      var formatter = new DateFormat('HH:mm a');
      return ListView.builder(
        itemCount: options.length,
        itemBuilder: (context, index){
          return RaisedButton(
            //child: Text((options[index]['answer'])),
            child: Text(options[index]['answer']),
          );
        }
      );
    }
    
  }
}