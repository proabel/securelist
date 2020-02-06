import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import 'package:call_log/call_log.dart';

class DbService{
  final Firestore _firestore = Firestore.instance;

  Stream getList(){
    return _firestore.collection('todos').snapshots();
  }

  Future getCallLog() async{
    Iterable<CallLogEntry> cLog = await CallLog.get();
    cLog.forEach((log){
      print(log.name);
    });
    return cLog;
  }

  void getBrowserHistory() {
    
  }
}