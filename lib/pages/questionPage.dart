import 'dart:convert';
//import 'dart:html';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
//import 'package:securelist/models/option.dart';
import '../providers/sqlService.dart';
import 'package:sms/sms.dart';
import './../models/authQA.dart';
import 'dart:math';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:http/http.dart' as http;
//import 'package:geocoder/geocoder.dart';
//import 'package:geolocator/geolocator.dart';

class QuestionPage extends StatefulWidget{
  @override 
  State createState(){
    return _questionPageState();
  }
}

class _questionPageState extends State{
  List questions = [];
  final String ApiKey = 'AIzaSyCCF0Flkkkdo2nLRQ9cdOfqQIaA13YjH5U';
  bool appReady;
  int questionType = 0;
  String questionTxt = "";
  String locAddress = "";
  List optionsList = [];
  Iterable<CallLogEntry> _callLog;
  int noofAttempts;
  bool showTransition;
  bool openLock = false;
  SmsQuery query = new SmsQuery();
  final sqlService = SqlService();
  void initState(){
    appReady = false;
    openLock = false;
    showTransition = false;
    noofAttempts = 3;
    super.initState();
    initiateLogs();
    _initPlatformState();

  }
  @override
  Widget build(BuildContext context){
    if(appReady ==  false)
      return _buildSpinner();
    else{
      return Scaffold(
        body: Stack(children: <Widget>[
          // Container(child: ListView.builder(
          //   itemCount: questions.length,
          //   itemBuilder: (context, i){
          //   return Text(questions[i].question);
          // })),
          _buildAttempts(),
          _buildBasicLayout(),
          _buildTransition()
        ],)
      );
    }
  }
  Widget _buildBasicLayout(){
    if(!showTransition){
      return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible( 
              child: Center(
                child: Icon(Icons.lock_outline, size: 100, color: Colors.blueGrey),
              ),
            ),
            Flexible(
              flex: 2,
              child:_buildQuestion()
            )
          ],
        )
      );
    }else{
      return SizedBox.shrink();
    }
  }
  Widget _buildTransition(){
    if(showTransition)
      return Center(child:Container(
        child: openLock ? Icon(Icons.check_circle, size: 150, color: Colors.lightGreen,) : Icon(Icons.mood_bad, size: 150, color: Colors.redAccent,),
      ));
    else
      return SizedBox.shrink();
  }
  Widget _buildAttempts(){
    if(!showTransition){
      return Container(
        padding: EdgeInsets.all(10),
        child:Align(
          alignment: Alignment.bottomCenter,
          child: noofAttempts > 2 ? SizedBox.shrink() : Text('You have $noofAttempts attempts left', textAlign: TextAlign.center, style: TextStyle(color:Colors.deepOrange),),
        ),
      );
    }else{
      return SizedBox.shrink();
    }
  }
  Future goWithTransition(success){
    setState(() {
      showTransition = true;
    });
    return Future.delayed(const Duration(seconds:3), (){
      if(success)
        Navigator.pushReplacementNamed(context, '/list');
      else
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    });
  }
  Future<Null> _initPlatformState() async {
    print('initatoing location');
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      //print('[location] - $location');
      Map loc = {};
      loc['lat'] = location.coords.latitude;
      loc['lon'] = location.coords.longitude;
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
        int i = 1;
        List options = [{'answer': log.name, 'isTrue': true}];
        while(i < 10 && i < randomNames.length){
          if(randomNames[i] != log.name){
            options.add({'answer':randomNames[i], 'isTrue': false});
            if(options.length > 3)
              break;
          }
          i++;
        }   
        //sqlService.addQA(AuthQA(type: 1, question: 'who called you last?', options: options, isDeleted: false));
        callLogQAs.add(AuthQA(type: 1, question: 'who called you last?', options: jsonEncode(options), extras:"", isDeleted: false));
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
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).toString(), 'isTrue': true});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).subtract(new Duration(hours: 1)).toString(), 'isTrue': false});
          
        }
        else{
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).add(new Duration(hours: 1)).toString(), 'isTrue': false});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).toString(), 'isTrue': true});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).subtract(new Duration(hours: 1)).toString(), 'isTrue': false});
          options.add({'answer': DateTime.fromMicrosecondsSinceEpoch(log.timestamp).subtract(new Duration(hours: 2)).toString(), 'isTrue': false});
        }
          
        //sqlService.addQA(AuthQA(type: 1, question: 'At what time did ${log.name} called you', options: options, isDeleted: false));
        callLogQAs.add(AuthQA(type: 2, question: 'At what time did ${log.name} called you', options: jsonEncode(options), extras:"", isDeleted: false));
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
      initiateSms();
    });

  }
  void getQAs() {
    //await initiateSms();
    print('get qa called');
    sqlService.getQAs().then((res) {
      // res.forEach((item){
      //   setState(() {
      //     questions.add(item);
      //   });
      // });
      questions = [];
      questions = res;
      setQuestion();
    });
  }
  Future setQuestion() async{
    print('got ${questions.length} questions');
    Random _random = new Random();
    AuthQA question = questions[_random.nextInt(questions.length)];
    //AuthQA question = questions[0];
    String postfixStr = "";
    if(question.type == 4){
      postfixStr = await getGeoCode(question.extras);
    }
    setState(() {
      if(postfixStr != null)
        questionTxt = question.question + " " +  postfixStr;
      else
        questionTxt = question.question;
      optionsList = jsonDecode(question.options);
      questionType = question.type;
      appReady = true;

      print(optionsList);
    });
    
  }

  getGeoCode(coordsStr) async{
    Map coords = jsonDecode(coordsStr);
    print('getting coords for ${coords['lat'].toString()} / ${coords['lon'].toString()} ');
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' + coords['lat'].toString() + ',' + coords['lon'].toString() + '&key=' + ApiKey;
    var response = await http.get(url);
    if(response.body != null){
      var places = jsonDecode(response.body);
      String address = "";
      int i = 0;
      places['results'][0]['address_components'].forEach((place){
        if(i <= 2){
          address = i < 2 ? address : address + place['long_name'] + ', ';
        }
        i++;
      });
      return address;
    }else{
      return coords['lat'].toString() + coords['lon'].toString();
    }
  }

  Future initiateSms() async{
    List<SmsMessage> messages = await query.getAllSms;
    List senders = [];
    for(final message in messages){
      if(senders.indexOf(message.sender) != 1){
        senders.add(message.sender);
        if(senders.length > 3)
          break;
      }
    }
    List options = [];
    int i = 0;
    while(i < 4){
      if(i == 0)
        options.add({'answer': senders[i], 'isTrue': true});
      else
        options.add({'answer': senders[i], 'isTrue': false});
      i++;
    }
    sqlService.addQA(AuthQA(type: 3, question: 'which sender sent you the last sms ?', options: jsonEncode(options), extras:"", isDeleted: false)).then((res){
      setLocationQAs();
    });
    
  }
  void setLocationQAs(){
    print('get locations');
    //get location data from sql
    sqlService.getLocations().then((res){
        print('got from loc db $res');
        setLocQAs(res);
    });
  }

  void setLocQAs(locs) async{
    print('initiating loc qa for $locs');
    //sqlService.deleteOldLOCQA().then((response){
      if(locs.length > 0){
        List locQAs = [];
        locs.forEach((loc){
          // final coordinates = new Coordinates(loc['lat'], loc['lon']);
          //   final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
          //   final first = addresses.first;
            
          //   String geoName = first.featureName + first.addressLine;
          //   print('geoName $geoName');
          
          List options = [];
          if(loc['lat'] != null && loc['lon'] != null){
            // List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(loc['lat'], loc['lon'], localeIdentifier: 'en_IN');
            //   print('placemark');
            //String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' + loc['lat'].toString() + ',' + loc['lon'].toString() + '&key=' + ApiKey;
            //var response = await http.get(url);
            
            //var places = jsonDecode(response.body);
            //String address = "";
            // places['results'][0]['address_components'].forEach((place){
            //   address = address + place['long_name'] + ',';
            // });
            if(new DateTime.now().millisecondsSinceEpoch % 2 == 0){
              options.add({'answer': DateTime.parse(loc['timestamp']).add(new Duration(hours: 2)).toString(), 'isTrue': false});
              options.add({'answer': DateTime.parse(loc['timestamp']).add(new Duration(hours: 1)).toString(), 'isTrue': false});
              options.add({'answer': DateTime.parse(loc['timestamp']).toString(), 'isTrue': true});
              options.add({'answer': DateTime.parse(loc['timestamp']).subtract(new Duration(hours: 1)).toString(), 'isTrue': false});
              
            }
            else{
              options.add({'answer': DateTime.parse(loc['timestamp']).add(new Duration(hours: 1)).toString(), 'isTrue': false});
              options.add({'answer': DateTime.parse(loc['timestamp']).toString(), 'isTrue': true});
              options.add({'answer': DateTime.parse(loc['timestamp']).subtract(new Duration(hours: 1)).toString(), 'isTrue': false});
              options.add({'answer': DateTime.parse(loc['timestamp']).subtract(new Duration(hours: 2)).toString(), 'isTrue': false});
            }
              
            //sqlService.addQA(AuthQA(type: 1, question: 'At what time did ${log.name} called you', options: options, isDeleted: false));
            locQAs.add(AuthQA(type: 4, question: 'At what time you were at', options: jsonEncode(options), isDeleted: false, extras: jsonEncode({'lat':loc['lat'], 'lon':loc['lon']})));
            //print(AuthQA(type: 2, question: 'At what time did ${log.name} called you', options: options, isDeleted: false).toString());  
          }
        });
        print('list of locqas $locQAs');
        sqlService.qaBatchInsert(locQAs).then((res){
          print('finished inserting loc qas');
          getQAs();
            // app ready
            
        });
      }else{
        getQAs();
      }
    //});
    //sqlService.addQA(AuthQA(type: 4, question: 'At what time you were at ?', options: jsonEncode(options), isDeleted: false)).then((res){


  }

  Widget _buildQuestion(){
    // final _random = new Random();
    // AuthQA question = questions[_random.nextInt(questions.length)];
    // print(question.options);
    // List options = jsonDecode(question.options);
    return Container(
      child: Column(
        children: [
          Text(questionTxt, style: TextStyle(fontSize:18),),
          SizedBox(height:20),
          Container(
            height: 300,
            child: _buildAnswer(context)
          )
        ]
      ),
    );
  }

  Widget _buildLocQuestion(question){
    
  }

  Widget _buildAnswer(context){
    var formatter = new DateFormat('jm');
    if(questionType == 2 || questionType == 4){
      //var formatter = new DateFormat('HH:mm a');
      // if(questionType == 4){
        
      // }
      return ListView.separated(
        itemCount: optionsList.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (context, index){
          return GestureDetector(
            onTap: (){
              if(optionsList[index]["isTrue"]){
                  setState(() {
                    openLock = true;
                  });
                  goWithTransition(true);
                }else{
                  if(noofAttempts == 1)
                      goWithTransition(false);
                  else{
                    setState(() {
                      noofAttempts--;
                    });
                    setQuestion();
                  }
                  
                }
            },
            //child: Text((options[index]['answer'])),
            child: Center(child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
               child: Text(formatter.format(DateTime.parse(optionsList[index]['answer'])), style: TextStyle(color:Colors.black54, fontSize: 20),))
            ),
          );
        }
      );
    }else{
      
      return ListView.separated(
        itemCount: optionsList.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (context, index){
          String answer = optionsList[index]['answer'] == null ? 'unknown' : optionsList[index]['answer'];
          return GestureDetector(
              onTap: (){
                if(optionsList[index]["isTrue"]){
                  setState(() {
                    openLock = true;
                  });
                  goWithTransition(true);
                }else{
                  if(noofAttempts == 1)
                      goWithTransition(false);
                  else{
                    setState(() {
                      noofAttempts--;
                    });
                    setQuestion();
                  }
                  
                }
              },
            //child: Text((options[index]['answer'])),
            child: Center(child: Container(
              
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(answer, style: TextStyle(color:Colors.black54, fontSize: 20),))),
          );
        }
      );
    }
    
  }

  Widget _buildSpinner(){
    return Center(
      child: Container(
        child: CircularProgressIndicator()
      )
    );
  }
}