import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example_firebase/display%20on%20app/user.dart';
import 'package:flutter/material.dart';
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

  getUsers(){
    //
    return Firestore.instance.collection(collectionName).snapshots();
  }

  addUser(){
   User user = User(name: controller.text);
   try {
     Firestore.instance.runTransaction((Transaction transaction) async {
       await Firestore.instance.collection(collectionName).document().setData(user.toJson());
     });
   }catch (e) {
     print(e.toString());
   }
  }

  add(){
    if(isEditing){
      // update
      update(curUser, controller.text);
      setState(() {
        isEditing = false;
      });
    }else {
      addUser();
    }
    controller.text = '';
  }

  update( User user, String newName){
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.update(user.reference, {'name': newName});
    });
  }

  delete(User user){
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.delete(user.reference);
    });
  }

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

  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot){
    return ListView(
      children: snapshot.map((data) => buildListItem(context, data)).toList(),
    );
  }

  Widget buildListItem(BuildContext context, DocumentSnapshot data){
    final record = User.fromSnapshot(data);
    return Padding(
      key: ValueKey(record.name),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: ListTile(
          title: Text(record.name),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: (){
              // delete
              delete(record);
            },
          ),
          onTap: (){
            // update
            setUpdateUI(record);
          },
        ),
      ),
    );
  }

  setUpdateUI(User user){
    controller.text = user.name;
    setState(() {
      showTextField = true;
      isEditing = true;
      curUser = user;
    });
  }

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
        },
      ),
    );
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "Name", hintText: "Enter name",
                  ),
                ),
                SizedBox(height: 10,),
                button(),
              ],
            ) : Container(),
            SizedBox(height: 20,),
            Text("USERS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),),
            SizedBox(height: 20,),
            Flexible(
              child: buildBody(context),
            ),
          ],
        ),
      ),
    );
  }
}
