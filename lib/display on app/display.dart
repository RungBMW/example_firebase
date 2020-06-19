import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example_firebase/display%20on%20app/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'user.dart';



class Display extends StatefulWidget {

  final String title ="Display Demo";
  @override
  _DisplayState createState() => _DisplayState();
}

class _DisplayState extends State<Display> {

  bool showTextField = false;
  TextEditingController controller = TextEditingController();
  String collectionName ="Users";
  bool isEditing = false;
  User curUser;
  String imagelink;
  File imageFile;
  DocumentSnapshot data;

  // Get User
  getUsers(){
    return Firestore.instance.collection(collectionName).snapshots();
  }

  // Add User
  addUser(){
   User user = User(name: controller.text, url: imagelink);
   try {
     Firestore.instance.runTransaction((Transaction transaction) async {
       await Firestore.instance.collection(collectionName).document().setData(user.toJson());
     });
   }catch (e) {
     print(e.toString());
   }
  }

  // Add
  add(){
    if(isEditing){
      // update
      update(curUser, controller.text,);
      setState(() {
        isEditing = false;
      });
    }else {
      addUser();
    }
    controller.text = '';
  }

  // Update
  update(User user, String newName){
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.update(user.reference, {'name': newName,});
    });
  }

  // Delete
  delete(User user){
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.delete(user.reference);
    });
  }

  // Build Body
  Widget buildBody(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: getUsers(),
      // ignore: missing_return
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text('Error ${snapshot.error}');
        }
        if(snapshot.hasData){
          print("Document ${snapshot.data.documents.length}");
          return buildList(context, snapshot.data.documents);
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget _dicideImageView(BuildContext context, DocumentSnapshot data){
    if(imageFile == null){
      return Text('No Image Select');
    }else{
      return Image.file(imageFile, width: 100,height: 100,);
    }
  }

  // Build List
  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot){
    return ListView(
      children: snapshot.map((data) => buildListItem(context, data)).toList(),
    );
  }

  // Build ListItem
  Widget buildListItem(BuildContext context, DocumentSnapshot data){

    final record = User.fromSnapshot(data);
    return Padding(
      key: ValueKey(record.name,),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: ListTile(
          leading: GestureDetector(
            child: Hero(
              tag: 'image-one-tag',
              child: CircleAvatar (
                backgroundImage: NetworkImage(record.url),
                radius: 22,
              ),
            ),
            onTap: () => _showImage(context,data),
          ),
          title: Text(record.name),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){
              // delete
              delete(record);
            },
          ),
          onTap: () {
            // update
            setUpdateUI(record);
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Information Yourself'),
                content: Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    children: <Widget>[
                      FlatButton(
                          child: Text('Selected Image'),
                          onPressed: () async {
                            imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
                            print("Image File"+ imageFile.path);
                            //  _showPhotos(context,imageFile);
                          }
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: "Name", hintText: "Enter name",
                        ),
                      ),
                      SizedBox(height: 10,),
                      button(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Set UpdateUI
  setUpdateUI(User user){
    controller.text = user.name;
    setState(() {
      showTextField = true;
      isEditing = true;
      curUser = user;
    });
  }

  // Button for Add
  button(){
    return SizedBox(
      width: double.infinity,
      child: OutlineButton(
        child: Text( isEditing ? "UPDATE" : "ADD"),
        onPressed: (){
          add();
          setState(() {
            showTextField = false;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Show Image Display on Screen
  void _showImage(BuildContext context, DocumentSnapshot data) {
    final record = User.fromSnapshot(data);
    Navigator.of(context).push(MaterialPageRoute (builder: (context) => Scaffold(
      body: Center(
        child: Hero(
            tag: 'image-one-tag',
            child:  Image.network(record.url)
        ),
      ),
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Display on app"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              setState(() {
                showTextField =! showTextField;
                showDialog<String>(
                    context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Information Yourself'),
                    content: Padding(
                      padding: EdgeInsets.all(0),
                      child: Column(
                        children: <Widget>[
                          // Show Image
                          _dicideImageView(context,data),

                          FlatButton(
                              child: Text('Selected Image'),
                              onPressed: () async {
                                imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
                                print("Image File" +imageFile.path);

                                // Add Image into Storage
                                FirebaseStorage fs = FirebaseStorage.instance;
                                StorageReference rootSref = fs.ref();
                                Random random = Random.secure();
                                String choice = random.nextInt(1000).toString();
                                StorageReference pictureSref = rootSref.child("pictures").child("image_"+choice);

                                // Image in Storage into Database
                                pictureSref.putFile(imageFile).onComplete.then((storageTask) async {
                                  String link = await storageTask.ref.getDownloadURL();
                                  print("Uploaded");
                                  setState(() {
                                    imagelink = link;
                                  });
                                });
                              }
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: "Name", hintText: "Enter name",
                            ),
                          ),
                          SizedBox(height: 10,),
                          button(),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            showTextField? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,) : Container(),
            SizedBox(height: 10,),
            Text("USERS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),),
            SizedBox(height: 10,),
            Column(),
            Flexible(
              child: buildBody(context),
            ),
          ],
        ),
      ),
    );
  }
}
