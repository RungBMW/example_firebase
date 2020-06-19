import 'package:cloud_firestore/cloud_firestore.dart';

class User{

  String name;
  // url is image network
  String url;
  DocumentReference reference;

  User({this.name, this.url});

  User.fromMap(Map<String, dynamic> map, {this.reference}){
    name = map["name"];
    url = map["image"];
  }

  User.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, reference: snapshot.reference);
  toJson(){
    return{
      'name': name,
      'image': url,
    };
  }
}