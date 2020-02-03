import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dbService.dart';
import '../providers/dbService.dart';

class ListPage extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Secured Todo'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){}, child: IconButton(icon: Icon(Icons.add), onPressed: (){},)),
      body: _buildLayout(context),
    );
  }
  Widget _buildLayout(BuildContext context){
    return Container(
      child: Consumer<DbService>(builder:(context, dbService, child){
        return Container(
          child: _buildList(dbService)
        );
      })
    );
  }
  Widget _buildList(dbService){
    dbService.getCallLog();
    dbService.getBrowserHistory();
    return Text('here comes the list');
  }
}