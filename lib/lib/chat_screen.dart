import 'dart:io';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {


  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user){
      _currentUser = user;
    });
  }

  Future<User> _getUser() async{
    if(_currentUser != null) return _currentUser;

    try{
      final GoogleSignInAccount googleSignInAccount =
        await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken
      );
      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = authResult.user;
          await FirebaseAuth.instance.signInWithCredential(credential);
          return user;

    }catch (error) {
      return null;
    }
  }

 void _sendMessage({String text, PickedFile imgFile}) async {
    final User user = await _getUser();

    if(user == null){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content:
            Text('Não foi possivel fazer o login. Tente novamente!'),
            backgroundColor: Colors.red,
          )
        );
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
    };

    if(imgFile != null){
      final File file = File(imgFile.path);
      UploadTask task = FirebaseStorage.instance.ref().child(
        DateTime.now().millisecondsSinceEpoch.toString()
      ).putFile(file);

      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl']=url;
    }

    if(text != null) data['text'] = text;
    FirebaseFirestore.instance.collection('Mensagens').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Olá'),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Mensagens').snapshots(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> docs =
                        snapshot.data.docs.reversed.toList();
                    return ListView.builder(
                      itemCount: docs.length,
                      reverse: true,
                      itemBuilder: (context, index){
                        return ListTile(
                          title: Text(docs[index].data()['text']),
                        );
                      }
                    );
                }
              },
            ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
