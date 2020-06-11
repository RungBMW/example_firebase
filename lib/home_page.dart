import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Firebase', style: TextStyle(fontSize: 20),),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('Mobile Legend').snapshots(),
        builder: (context, snapshots){
          if(!snapshots.hasData)
            return Text('Loading data ... Please Wait ...');
            return Column(
              children: <Widget>[
                SizedBox(height: 40,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Text(snapshots.data.documents[0]['name'], style: TextStyle(fontSize: 20),),
                    SizedBox(width: 10,),
                    Text(snapshots.data.documents[0]['price'].toString(), style: TextStyle(fontSize: 20),),
                  ],
                ),
                SizedBox(height: 5,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20,),
                    Text(snapshots.data.documents[1]['name'], style: TextStyle(fontSize: 20),),
                    SizedBox(width: 10,),
                    Text(snapshots.data.documents[1]['price'].toString(), style: TextStyle(fontSize: 20),),
                  ],
                ),
              ],
            );
        },
      ),
    );
  }
}