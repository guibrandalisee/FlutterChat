import 'dart:io';
import 'package:Projeto7CursoFlutter/chatmessage.dart';
import 'package:Projeto7CursoFlutter/textComposer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool aux = true;
  FirebaseUser _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;
      login(user, aux);
      return user;
    } catch (error) {
      return null;
    }
  }

  void login(FirebaseUser user, bool a) {
    if (!a) return;
    aux = false;
    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Error! Try again later!",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 1000),
      ));
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          "Logged in",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 1000),
      ));
    }
  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now(),
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);
      setState(() {
        _isLoading = true;
      });
      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = url;
      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) data["text"] = text;
    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text(_currentUser != null
              ? "Hello ${_currentUser.displayName}"
              : "Chat App"),
        ),
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    aux = true;
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(
                        "Logged out",
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.purple,
                      duration: Duration(milliseconds: 1000),
                    ));
                  },
                )
              : IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    setState(() {
                      _getUser();
                    });
                  },
                )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("messages")
                  .orderBy("time")
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents =
                        snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                      itemCount: documents.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ChatMessage(documents[index].data,
                            documents[index].data["uid"] == _currentUser?.uid);
                      },
                    );
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage)
        ],
      ),
    );
  }
}
