import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/classes/avaliation_class.dart';
import 'package:fretes_go_freteiro/classes/banishment_class.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fretes_go_freteiro/utils/date_utils.dart';
import 'package:fretes_go_freteiro/utils/shared_prefs_utils.dart';


class FirestoreServices {

  UserModel userModel;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final String agendamentosPath = 'agendamentos_aguardando';
  static final String truckerCancelmentsNotifyPath = 'notificacoes_cancelamento';
  static final String truckerPath = 'truckers';
  static final String avaliationPath = 'users';
  static final String punishmentPath = 'freteiros_em_punicao';
  static final String banishmentPath = 'freteiros_banidos';


  Future<void> createNewUser(String name, String email, String uid) {
    // Call the user's CollectionReference to add a new user
    CollectionReference users = FirebaseFirestore.instance.collection(truckerPath);

    return users
        .doc(uid)
        .set({
      'name': name,
      'email': email,
      'all_info_done' : 99,
      'rate' : 0.0,
      'aval' : 0,
      'banido' : false,
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
        .collection(truckerPath)
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

  void getUserInfoCheckWhatIsMissing(UserModel userModel, @required VoidCallback goToPage1(), @required VoidCallback goToPage2(), @required VoidCallback goToPage3(), @required VoidCallback goToPage4()) {

    int exists;
    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        exists = documentSnapshot['all_info_done']??99;
        if(exists==1){
          //user só preencheu a primeira página
          goToPage2();
        } else if(exists == 2){
          goToPage3();
        } else if(exists == 3){
        goToPage4();
      } else {
          //user n fez nada, ir para a página inicial
          goToPage1();
        }
      }
    });
  }

  //retorna o latlong do usuario
  void getUserLatLong(String uid, @required VoidCallback gotIt(), @required VoidCallback onFailureToGetLatLong()) {

    String latlong;
    FirebaseFirestore.instance
        .collection(truckerPath)
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
  Future<void> saveUserInfo(String uid, double latitude, double longitude, String _apelido, String _phone,
      String _address, String uri, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {


    CollectionReference users = FirebaseFirestore.instance.collection(truckerPath);

    double latlong = latitude+longitude;
    if(latitude==null){
      //esta updatando
      return users
          .doc(uid)
          .set({
        'apelido': _apelido,
        'phone': _phone,
        'address': _address,
        'image' : uri,
      })
          .then((value) {
        onSucess();
      })
          .catchError((error) => onFailure());


    } else {


      return users
          .doc(uid)
          .set({
        'apelido': _apelido,
        'phone': _phone,
        'address': _address,
        'latitude': latitude,
        'longitude': longitude,
        'latlong': latlong,
        'image' : uri,
        'all_info_done' : 1,
        'aval' : 0.0,
      })
          .then((value) {
        onSucess();
      })
          .catchError((error) => onFailure());


    }

  }

  //metodo que salva a segunda página cnh
  Future<void> saveUserCNHinfo(String uid, String uri, int pageDone, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {


    CollectionReference users = FirebaseFirestore.instance.collection(truckerPath);

    if(pageDone>=2){

      if(uri == null){
        //esta updante mas n mandou uma nova imagem
        onSucess();
      } else {

        //salva a nova cnh enviada
        //esta updatando
        return users
            .doc(uid)
            .update({
          'cnh' : uri,
        })
            .then((value) {
          onSucess();
        })
            .catchError((error) => onFailure());


      }

    } else {

      //salvamento pela primeira vez
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


  }

  //metodo que salva a ultima parte das infos do freteiro, a parte do carro
  Future<void> saveUserCarInfo(String uid, String placa, File imageCar, String uri, String carro, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {


    CollectionReference users = FirebaseFirestore.instance.collection(truckerPath);




    if(imageCar==null){
      //updatando
      return users
          .doc(uid)
          .update({
        'vehicle' : carro,
        'placa' : placa,
        'all_info_done' : 3,
      })
          .then((value) {
            onSucess();
      })
          .catchError((error) => onFailure());


    } else {

      return users
          .doc(uid)
          .update({
        'vehicle' : carro,
        'vehicle_image' : uri,
        'placa' : placa,
        'all_info_done' : 3,
      })
          .then((value) {

            onSucess();

      })
          .catchError((error) => onFailure());


    }

  }

  Future<void> loadUserInfos(UserModel userModel, @required VoidCallback onSucess(), @required VoidCallback onFail()){

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userModel.updateVehicle(documentSnapshot['vehicle']);
        userModel.updateVehicleImage(documentSnapshot['vehicle_image']);
        userModel.updatePlaca(documentSnapshot['placa']);
        userModel.updateApelido(documentSnapshot['apelido']);
        userModel.updatePhone(documentSnapshot['phone']);
        userModel.updateAddress(documentSnapshot['address']);
        //latitude e longitude nao pegamos pq n tem na classe usermodel
        userModel.updateLatLoong(documentSnapshot['latlong']);
        userModel.updateImage(documentSnapshot['image']);
        userModel.updateRate(documentSnapshot['rate']);
        userModel.updateAllInfoDone(documentSnapshot['all_info_done']);
        //SharedPrefsUtils().updateAllInfoDone(documentSnapshot['all_info_done']);
        
       onSucess();
      } else {
        onFail();
      }
    });

  }

  Future<void> placeUserInSearch(bool isNew, UserModel userModel, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {

    CollectionReference placeForSearch = FirebaseFirestore.instance.collection(userModel.Vehicle);

    await SharedPrefsUtils().loadPageOneInfo(userModel);

    if(isNew == true){
      placeForSearch
          .doc(userModel.Uid)
          .set({
        'aval' : 0.0,
        'image' : userModel.Image,
        'latlong' : userModel.LatLong,
        'name' : userModel.Apelido,
      }).then((value) => onSucess())
          .catchError((onError) => onFailure());

    } else {

      //fazendo update
      placeForSearch
          .doc(userModel.Uid)
          .update({
        'image' : userModel.Image,
        'latlong' : userModel.LatLong,
        'name' : userModel.Apelido,
      }).then((value) => onSucess())
          .catchError((onError)=> onFailure());

    }
  }

  Future<void> confirmJobAceptance(String moveId, @required VoidCallback onSucess(), @required VoidCallback onFail()){

    CollectionReference users = FirebaseFirestore.instance.collection(agendamentosPath);

    return users
        .doc(moveId)
        .update({
      'situacao' : "accepted",
    }).then((value) {
      onSucess();
    }).catchError((error) => onFail());

  }

  Future<void> confirmJobDeny(String moveId, @required VoidCallback onSucess(), @required VoidCallback onFail()){

    CollectionReference users = FirebaseFirestore.instance.collection(agendamentosPath);

    return users
        .doc(moveId)
        .update({
      'situacao' : "deny",
      'id_freteiro' : null,
      'nome_freteiro' : null,

    }).then((value) {
      onSucess();
    }).catchError((error) => onFail());
  }

  Future<void> truckerQuitBecauseOfOutageOfPayment(String moveId, @required VoidCallback onSucess(), @required VoidCallback onFail()){

    CollectionReference users = FirebaseFirestore.instance.collection(agendamentosPath);

    return users
        .doc(moveId)
        .update({
      'situacao' : "quit",
      'id_freteiro' : null,
      'nome_freteiro' : null,

    }).then((value) {
      onSucess();
    }).catchError((error) => onFail());
  }

  Future<void> quitJobAfterPayment(String moveId, @required VoidCallback onSucess(), @required VoidCallback onFail()){

    CollectionReference users = FirebaseFirestore.instance.collection(agendamentosPath);

    return users
        .doc(moveId)
        .update({
      'situacao' : "trucker_quit_after_payment",
      'id_freteiro' : null,
      'nome_freteiro' : null,

    }).then((value) {
      onSucess();
    }).catchError((error) => onFail());

  }

  Future<void> createPunishmentEntry(String truckerId, String motivo){

    CollectionReference path = FirebaseFirestore.instance.collection(punishmentPath);

    path.doc(truckerId).set({
      'trucker' : truckerId,
      'motivo' : motivo,
      'data' : DateUtils().giveMeTheDateToday(),
      'hora' : DateUtils().giveMeTheTimeNow(),

    });

  }


  //funções de banimento
  Future<void> createBanishmentEntry(String truckerId, String motivo, int tempoBanimento){

    CollectionReference path = FirebaseFirestore.instance.collection(banishmentPath);

    path.doc(truckerId).set({
      'trucker' : truckerId,
      'motivo' : motivo,
      'data' : DateUtils().giveMeTheDateToday(),
      'hora' : DateUtils().giveMeTheTimeNow(),
      'tempo_banimento' : tempoBanimento

    }).then((value) { banish(truckerId); });

  }

  Future<void> banish(String truckerId){

    CollectionReference path = FirebaseFirestore.instance.collection(truckerPath);

    path.doc(truckerId).update({

      'banido' : true,

    });
  }

  Future<void> unbanish(String truckerId){

    CollectionReference path = FirebaseFirestore.instance.collection(truckerPath);

    path.doc(truckerId).update({

      'banido' : false,

    });
  }

  Future<void> checkIfUserIsBanished(String truckerId, [VoidCallback isBanished(), VoidCallback notBanished(), VoidCallback onFail()]){

    bool banido=false;
    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(truckerId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        banido = documentSnapshot['banido'];

        if(banido==true){
          isBanished();
        } else {
          notBanished();
        }

      } else {
        onFail();
      }
    });

  }

  Future<void> getBanishmentInfo(String truckerId, BanishmentClass banishmentClass, VoidCallback onSucess(), VoidCallback onFail()){

    FirebaseFirestore.instance
        .collection(banishmentPath)
        .doc(truckerId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        banishmentClass.motivo = documentSnapshot['motivo'];
        banishmentClass.data = documentSnapshot['data'];
        banishmentClass.hora = documentSnapshot['hora'];
        banishmentClass.tempo_banimento = documentSnapshot['tempo_banimento'];

        onSucess();

      } else {
        onFail();
      }
    });

  }

  Future<void> removeBanishmentInfo(String truckerId){

    FirebaseFirestore.instance
        .collection(banishmentPath)
        .doc(truckerId)
        .delete().then((value) {unbanish(truckerId); });

  }


  Future<void> updateAlertView(id){

    CollectionReference alert = FirebaseFirestore.instance.collection(agendamentosPath);
    return alert
        .doc(id)
        .update({
      'alert_saw' : true,
    });

  }

  Future<void> alertSetUserAlert(String id){
    CollectionReference alert = FirebaseFirestore.instance.collection(agendamentosPath);
    return alert
        .doc(id)
        .update({
      'alert_saw' : false,
      'alert' : 'user',
    });
  }

  Future<void> checkIfUserHasCancelmentsNotify(String id, UserModel userModel, @required VoidCallback onSucess()){

    FirebaseFirestore.instance
        .collection(truckerCancelmentsNotifyPath)
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userModel.updateMoveIdCancelment(documentSnapshot['moveId']);
        onSucess();
      }
    });
  }

  Future<void> deleteCancelmentsNotify(String id){

    FirebaseFirestore.instance
        .collection(truckerCancelmentsNotifyPath)
        .doc(id)
        .delete();

  }

  Future<MoveClass> loadMoveClass(UserModel userModel, MoveClass moveClass, @required VoidCallback onFail()){

    FirebaseFirestore.instance
        .collection(agendamentosPath)
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        moveClass.ajudantes = documentSnapshot['ajudantes'];
        moveClass.carro = documentSnapshot['carro'];
        moveClass.enderecoOrigem = documentSnapshot['endereco_origem'];
        moveClass.enderecoDestino = documentSnapshot['endereco_destino'];
        moveClass.escada = documentSnapshot['escada'];
        moveClass.userId = documentSnapshot['id_contratante'];
        //moveClass.freteiroId = documentSnapshot['id_freteiro'];  >>n precisa, é o user
        moveClass.lancesEscada = documentSnapshot['lances_escada'];
        moveClass.idPedido = documentSnapshot['moveId'];
        moveClass.ps = documentSnapshot['ps'];
        moveClass.dateSelected = documentSnapshot['selectedDate'];
        moveClass.timeSelected = documentSnapshot['selectedTime'];
        //moveClass.situacao = documentSnapshot['situacao'];
        moveClass.preco = documentSnapshot['valor'];

        return moveClass;
      } else {
        onFail();
      }
    });


  }

  Future<void> loadMoveSituation(MoveClass moveClass, VoidCallback onSucess(), VoidCallback onFail()){

    FirebaseFirestore.instance
        .collection(agendamentosPath)
        .doc(moveClass.idPedido)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        moveClass.situacao = documentSnapshot['situacao'];

        onSucess();
      } else {
        onFail();
      }
    });

  }

  Future<void> updateMoveSituation(String newSituation, String moveId, [@required VoidCallback onSucess(), @required VoidCallback onFail()]){

    CollectionReference update = FirebaseFirestore.instance.collection(agendamentosPath);
    return update
        .doc(moveId)
        .update({
      'situacao' : newSituation,

    }).then((value) {
      onSucess();
    }).catchError((e) => onFail());

  }

  Future<void> updateMoveSituationTruckerQuit(String newSituation, String truckerId, MoveClass moveClass, [@required VoidCallback onSucess(), @required VoidCallback onFail()]){

    //colocando o not depos do id do freteiro vai impedir de aparecer como um job para ele, mesmo que o user nao tenha finalizado ainda.
    String newId = truckerId+'not';  //no moveClass não tem as infos do motorista

    CollectionReference update = FirebaseFirestore.instance.collection(agendamentosPath);
    return update
        .doc(moveClass.idPedido)
        .update({
      'situacao' : 'trucker_finished',
      'id_freteiro' : newId,
    }).then((value) {
      createHistoricOfMoves(moveClass);
      onSucess();
    }).catchError((e) => onFail());

  }

  Future<void> FinishAmove(MoveClass moveClass, [@required VoidCallback onSuccess, @required VoidCallback onFailure]){
    CollectionReference move = FirebaseFirestore.instance.collection(agendamentosPath);
    move.doc(moveClass.idPedido)
        .delete()
        .then((value) => createHistoricOfMoves(moveClass)).catchError((onError)=> onFailure());
  }

  Future<void> createHistoricOfMoves(MoveClass moveClass){

    CollectionReference history = FirebaseFirestore.instance.collection(agendamentosPath);

    history.doc(moveClass.idPedido).set({
      'user' : moveClass.idPedido,
      'freteiro' : moveClass.freteiroId,
      'preco' : moveClass.preco,
      'origem' : moveClass.enderecoOrigem,
      'destino' : moveClass.enderecoDestino,

    });

  }

  Future<void> loadMoveClassForTests(String moveId, MoveClass moveClass, @required VoidCallback onFail(), @required VoidCallback onSucess()){

    FirebaseFirestore.instance
        .collection(agendamentosPath)
        .doc(moveId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        moveClass.ajudantes = documentSnapshot['ajudantes'];
        moveClass.carro = documentSnapshot['carro'];
        moveClass.enderecoOrigem = documentSnapshot['endereco_origem'];
        moveClass.enderecoDestino = documentSnapshot['endereco_destino'];
        moveClass.escada = documentSnapshot['escada'];
        moveClass.userId = documentSnapshot['id_contratante'];
        //moveClass.freteiroId = documentSnapshot['id_freteiro'];  >>n precisa, é o user
        moveClass.lancesEscada = documentSnapshot['lances_escada'];
        moveClass.idPedido = documentSnapshot['moveId'];
        moveClass.ps = documentSnapshot['ps'];
        moveClass.dateSelected = documentSnapshot['selectedDate'];
        moveClass.timeSelected = documentSnapshot['selectedTime'];
        //moveClass.situacao = documentSnapshot['situacao'];
        moveClass.preco = documentSnapshot['valor'];

        onSucess();
      } else {
        onFail();
      }
    });


  }

  Future<void> saveLastUserLocation(String moveId, double latitude, double longitude){

    CollectionReference userLocation = FirebaseFirestore.instance.collection(agendamentosPath);
    return userLocation
        .doc(moveId)
        .update({
      'lastTrucker_lat' : latitude,
      'lastTrucker_long' : longitude,
    });

  }

  Future<void> saveBankInfo(@required UserModel userModel, @required VoidCallback onSucess(), @required VoidCallback onFailure()){

    CollectionReference userLocation = FirebaseFirestore.instance.collection(truckerPath);
    return userLocation
        .doc(userModel.Uid)
        .update({
      'conta_nome' : userModel.NameAcountOwner,
      'conta_agencia' : userModel.Agency,
      'conta_conta' : userModel.Acount,
      'conta_digito' : userModel.Digit,
      'conta_tipo' : userModel.AcountType,
      'conta_banco' : userModel.Bank,
      'conta_cpf' : userModel.CpfAcountOwner,
    })
        .then((value) {

      onSucess();

    })
        .catchError((error) => onFailure());

  }

  Future<void> loadAvaliationClass(AvaliationClass avaliationClass, @required VoidCallback onSucess()){

    //AvaliationClass avaliationClassHere = avaliationClass;

    FirebaseFirestore.instance
        .collection(avaliationPath)
        .doc(avaliationClass.userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        avaliationClass.userName = documentSnapshot['name'];
        avaliationClass.avaliations = documentSnapshot['aval'];
        avaliationClass.userRate = documentSnapshot['rate'].toDouble();

        onSucess();

      } else {

        return avaliationClass;
      }
    });



  }

  Future<void> saveUserAvaliation(AvaliationClass avaliationClass){

    CollectionReference userLocation = FirebaseFirestore.instance.collection(avaliationPath);
    return userLocation
        .doc(avaliationClass.userId)
        .update({
      'rate' : avaliationClass.newRate,
      'aval' : avaliationClass.avaliations+1,
    });

  }

}

