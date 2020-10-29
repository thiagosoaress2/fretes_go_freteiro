import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

/*
class FirestoreServices {

 UserModel userModel;

 final CollectionReference _usersCollectionReference = Firestore.instance.collection("users");

 Future<Null> saveUserData(Map<String, dynamic> userData, FirebaseUser firebaseUser) async {
   await Firestore.instance.collection("users").document(firebaseUser.uid).setData(userData);
 }

 Future loadCurrentUserData(FirebaseUser firebaseUser, FirebaseAuth _auth, UserModel userModel) async {

   if(firebaseUser == null){  //verifica se tem acesso a informação do user
     firebaseUser = await _auth.currentUser(); //se for nulo, vai tentaar pegar
     if (firebaseUser != null){ //verifica novamente
       if(userModel.Uid == ""){
         DocumentSnapshot docUser = await Firestore.instance.collection("users").document(firebaseUser.uid).get();
         //userData = docUser.data;
         userModel.updateUid(firebaseUser.uid);
         userModel.updateEmail(firebaseUser.email);
         userModel.updateFullName(docUser.data['name'].toString());

         print("printing userclass info "+userModel.Uid);

       }
     }
   } else {
     if(userModel.Uid == ""){
       DocumentSnapshot docUser = await Firestore.instance.collection("users").document(firebaseUser.uid).get().then((docUser) {

         userModel.updateUid(firebaseUser.uid);
         userModel.updateEmail(firebaseUser.email);
         userModel.updateFullName(docUser.data['name'].toString());

         print("printing userclass info "+userModel.Uid);
         print("nome do user é "+userModel.FullName);
       });
     }
   }

 }


}


*/

class FirestoreServices {

  UserModel userModel;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createNewUser(String name, String email, String uid) {
    // Call the user's CollectionReference to add a new user
    CollectionReference users = FirebaseFirestore.instance.collection('truckers');

    return users
        .doc(uid)
        .set({
      'name': name,
      'email': email
    })
        .then((value) {
      userModel.updateFullName(name);
      print('user added');
    })
        .catchError((error) => print("Failed to add user: $error"));
  }

  void getUserInfoFromCloudFirestore(UserModel userModel, @required VoidCallback userExists(), @required VoidCallback userNotReg()) {

    String exists;
    FirebaseFirestore.instance
        .collection('truckers')
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userModel.updateFullName(documentSnapshot['name']);
        userExists();
      } else {
        userNotReg();
      }
    });
  }

  Future<void> saveUserInfo(UserModel userModel, double latitude, double longitude, String _name, String _phone,
      String _address, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {


    CollectionReference users = FirebaseFirestore.instance.collection('truckers');

    double latlong = latitude + longitude;

    return users
        .doc(userModel.Uid)
        .set({
      'name': _name,
      'phone': _phone,
      'address': _address,
      'latitude': latitude,
      'longitude': longitude,
      'latlong': latlong,
    })
        .then((value) {
        onSucess();
    })
        .catchError((error) => onFailure());

  }
  
  Future<String> uploadFile(File _image, String path, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {

    String uriFinal;
    StorageReference storageReference = FirebaseStorage.instance.ref().child(path);
    //.child('freteiros_cnh/${Path.basename(_image.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {

        uriFinal = fileURL;
        onSucess();
        return uriFinal;


    }).catchError((error) => onFailure());
  }

  Future<String> updateImageInFireStore(UserModel userModel, String uri, @required VoidCallback onSucess(), @required VoidCallback onFailure()){

    CollectionReference users = FirebaseFirestore.instance.collection(
        'truckers');

    try{
      users
          .doc(userModel.Uid)
          .update({
        'image' : uri,
      }).then((value) => onSucess());  
    } catch (e) {
      onFailure();
    }
    

  }

}

