import 'package:flutter/material.dart';

class ListPage extends StatelessWidget{
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Secured Todo'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){}, child: IconButton(icon: Icon(Icons.add))),
      body: _buildListLayout(context),
    );
  }
  Widget _buildListLayout(BuildContext context){
    return Container(
      child: Text('this is the container')
    );
  }
}