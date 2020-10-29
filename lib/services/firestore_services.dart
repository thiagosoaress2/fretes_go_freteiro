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

  void getUserInfoCheckWhatIsMissing(UserModel userModel, @required VoidCallback goToPage2(), @required VoidCallback goToPage3()) {

    int exists;
    FirebaseFirestore.instance
        .collection('truckers')
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        exists = documentSnapshot['all_info_done'];
        if(exists==1){
          //user só preencheu a primeira página
          goToPage2();
        } else if(exists == 2){
          goToPage3();
        }
      }
    });
  }

  //retorna o latlong do usuario
  void getUserLatLong(String uid, @required VoidCallback gotIt(), @required VoidCallback onFailureToGetLatLong()) {

    String latlong;
    FirebaseFirestore.instance
        .collection('truckers')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        latlong = documentSnapshot['latlong'];
        if(latlong != null){
          //user só preencheu a primeira página
          gotIt();
        } else {
          onFailureToGetLatLong();
        }
        return latlong;
      } else {
        return latlong;
      }
    });
  }

  //metodo que salva a primeira parte das infos do freteiro
  Future<void> saveUserInfo(String uid, double latitude, double longitude, String _name, String _phone,
      String _address, String uri, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {


    CollectionReference users = FirebaseFirestore.instance.collection('truckers');

    double latlong = latitude + longitude;

    return users
        .doc(uid)
        .set({
      'name': _name,
      'phone': _phone,
      'address': _address,
      'latitude': latitude,
      'longitude': longitude,
      'latlong': latlong,
      'image' : uri,
      'all_info_done' : 1,
      'aval' : 0,
    })
        .then((value) {
        onSucess();
    })
        .catchError((error) => onFailure());

  }

  //metodo que salva a segunda página cnh
  Future<void> saveUserCNHinfo(String uid, String uri, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {


    CollectionReference users = FirebaseFirestore.instance.collection('truckers');

    return users
        .doc(uid)
        .update({
      'cnh' : uri,
      'all_info_done' : 2,
    })
        .then((value) {
      onSucess();
    })
        .catchError((error) => onFailure());

  }

  //metodo que salva a ultima parte das infos do freteiro, a parte do carro
  Future<void> saveUserCarInfo(String uid, String uri, String carro, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {


    CollectionReference users = FirebaseFirestore.instance.collection('truckers');

    CollectionReference placeForSearch = FirebaseFirestore.instance.collection(carro);


    return users
        .doc(uid)
        .update({
      'vehicle' : carro,
      'vehicle_image' : uri,
      'all_info_done' : 3,
    })
        .then((value) {
      onSucess();
    })
        .catchError((error) => onFailure());


  }


}

