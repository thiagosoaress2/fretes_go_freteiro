import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fretes_go_freteiro/classes/avaliation_class.dart';
import 'package:fretes_go_freteiro/classes/banishment_class.dart';
import 'package:fretes_go_freteiro/classes/move_class.dart';
import 'package:fretes_go_freteiro/models/cad_infos_model.dart';
import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:fretes_go_freteiro/services/sharedPrefs_services.dart';
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
  static final String bankPath = 'freteiros_bank';
  static final String historicPathUsers = 'historico_mudancas_users';
  static final String historicPathTrucker = 'historico_mudancas_truckers';
  static final String locationPath = 'location';
  static final String rememberTheLastSummer = 'historico_aval'; //quando o usuário apagar seu registro vamos guardar aqui


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
      _checkIfTheUserHasHistoric(uid);
    })
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> checkIfTheUserIsCommingBack(String uid, String email){

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {

          if (documentSnapshot.exists) {

            //do nothing

          } else {
            createNewUser(null, email, uid); //recria os campos
          }

    });
  }

  Future<void> _checkIfTheUserHasHistoric(String uid){

    bool _banido;
    int _aval;
    double _rate;

    FirebaseFirestore.instance
        .collection(rememberTheLastSummer)
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

         _banido = documentSnapshot['banido'];
          _aval = documentSnapshot['aval'];
        _rate = documentSnapshot['rate'].toDouble();

      }

    }).then((_) {
      //save previously data to user

      CollectionReference userLocation = FirebaseFirestore.instance.collection(truckerPath);
      return userLocation
          .doc(uid)
          .update({
        'rate' : _rate,
        'aval' : _aval,
        'banido' : _banido,
      });

    });

  }

  void getUserInfoFromCloudFirestore(UserModel userModel, @required VoidCallback userExists(), @required VoidCallback userNotReg()) {

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

        if(exists==1 || exists==2 || exists==3 || exists==4) {
          if (userModel.Apelido == '') {
            userModel.updateApelido(documentSnapshot['apelido'] ?? '');
            SharedPrefsUtils().updateAllInfoDone(exists);
          }
        }

        if(exists==1){
          //user só preencheu a primeira página
          goToPage2();
        } else if(exists == 2){
          goToPage3();
        } else if(exists == 3) {
          goToPage4();
        } else if(exists == 4){
          //tudo está ok, fazer nada.
      } else {
          //user n fez nada, ir para a página inicial
          goToPage1();
        }
      }
    });
  }

  void getUserApelido(UserModel userModel) {

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userModel.updateApelido(documentSnapshot['apelido'] ?? '');
      }

    });
  }

  void getUserCarTypeo(UserModel userModel) {

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userModel.updateVehicle(documentSnapshot['vehicle'] ?? '');
      }

    });
  }

  void getUserListedAndBanned(UserModel userModel) {

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(userModel.Uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userModel.updateUserListed(documentSnapshot['listed'] ?? false);
        userModel.updateUserBanned(documentSnapshot['banido'] ?? false);
        userModel.updateLatLoong(documentSnapshot['latlong'] ?? 0.0);
        userModel.updatePlaca(documentSnapshot['placa'] ?? 'nao');
      }

    }).then((_) {
      print(userModel.Banned);
      print(userModel.Listed);
      print('leu banido e lista');
    });
  }

  Future<int> getUserInfoCheckWhatIsMissingWithReturnInt(String id) {

    int exists;
    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        exists = documentSnapshot['all_info_done']??99;
        return exists; //se retornar 99 é pq n existe
        /*
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

         */
      } else {
       return 99;
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





  //METODOS DE CADASTRO APÓS O LOGIN - NOME, APELIDO, CNH E BANCO
  //metodo que salva a primeira parte das infos do freteiro
  Future<void> saveUserInfo(String uid, double latitude, double longitude, String _apelido, String _phone,
      String _address, String uri, bool isUpdating, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {


    CollectionReference users = FirebaseFirestore.instance.collection(truckerPath);

    double latlong = latitude+longitude;
    if(isUpdating==true){
      //esta updatando
      return users
          .doc(uid)
          .update({
        'apelido': _apelido,
        'phone': _phone,
        'address': _address,
        'image' : uri,
        'latlong' : latlong
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
          .set({
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

  Future<void> loadUserCarInfo(CadInfosModel cadInfosModel, String id, VoidCallback callback()){

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        if(documentSnapshot.data().containsKey('vehicle')){
          cadInfosModel.updateVehicle(documentSnapshot['vehicle']);
          cadInfosModel.updateVehicleImageUrl(documentSnapshot['vehicle_image']);
          //cadInfosModel.updateVehicleImageUrl(documentSnapshot['placa']);
          cadInfosModel.updatePlaca(documentSnapshot['placa']);
          callback();
        } else {
          //n existe
        }


      } else {
        //n existe
      }
    });

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

  Future<void> saveBankInfo(@required CadInfosModel cadInfosModel, String cpfOrCnpj, String uid, @required VoidCallback onSucess(), @required VoidCallback onFailure()){

    print(uid);
    CollectionReference userLocation = FirebaseFirestore.instance.collection(bankPath);
    return userLocation
        .doc(uid)
        .set({
      'conta_nome' : cadInfosModel.nameController.text,
      'conta_agencia' : cadInfosModel.agencyController.text,
      'conta_conta' : cadInfosModel.accountController.text,
      'conta_digito' : cadInfosModel.digitController.text,
      'conta_tipo' : cadInfosModel.acountType,
      'conta_banco' : cadInfosModel.bank,
      'conta_cpf' : cpfOrCnpj,  //atenção: Para manter o campo como cpf, ele pode ser um CNPJ. Para verificar veja se tipo_doc é cpf ou cnpj.
      'tipo_doc' : cadInfosModel.cpfOrCnpj,
    })
        .then((value) {

      onSucess();

    })
        .catchError((error) => onFailure());

  }

  Future<void> loadBankInfo(CadInfosModel cadInfosModel, String id, VoidCallback callback()){

    FirebaseFirestore.instance
        .collection(bankPath)
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        if(documentSnapshot.data().containsKey('conta_nome')){
          cadInfosModel.nameController.text = documentSnapshot['conta_nome'];
          cadInfosModel.agencyController.text = documentSnapshot['conta_agencia'];
          cadInfosModel.accountController.text = documentSnapshot['conta_conta'];
          cadInfosModel.digitController.text = documentSnapshot['conta_digito'];
          cadInfosModel.cpfController.text = documentSnapshot['conta_cpf'];
          cadInfosModel.updateAcountType(documentSnapshot['conta_tipo']);
          cadInfosModel.updateBank(documentSnapshot['conta_banco']);
          callback();
        } else {
          //n existe
        }


      } else {
        //n existe
      }
    });

  }

  Future<void> placeUserInSearch(bool isNew, String uid, @required VoidCallback onSucess(), @required VoidCallback onFailure()) async {

    CollectionReference placeForSearch = FirebaseFirestore.instance.collection('truckers');
    //await SharedPrefsUtils().loadPageOneInfo(userModel);

    placeForSearch
        .doc(uid)
        .update({
      'listed' : true,
      'banido' : false,
      'all_info_done' : 99,
    }).then((value) {

      onSucess();

    })
        .catchError((onError){
          onFailure();
    });

  }

  //AVALIACOES




//metodos  da pagina de cad infos 1
  Future<void> loadUserProfileImage(UserModel userModel, String id){

    //AvaliationClass avaliationClassHere = avaliationClass;

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        userModel.updateImage(documentSnapshot['image']);

      } else {
        //nada a fazer
      }
    });



  }


  Future<void> loadPageOneUserInfos(CadInfosModel cadInfosModel, String id, VoidCallback dataExists(), VoidCallback dataDontExists()){

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        if(documentSnapshot.data().containsKey('phone')){

          print('exists');
          cadInfosModel.updateApelido(documentSnapshot['apelido']);
          cadInfosModel.updatephone(documentSnapshot['phone']);
          cadInfosModel.updateaddress(documentSnapshot['address']);
          cadInfosModel.updateLatLong(documentSnapshot['latlong']);
          cadInfosModel.updateimage(documentSnapshot['image']);
          dataExists();


        } else {

          print('dont exists');
          dataDontExists();

        }

      }
    });

  }
  /*
  Future<void> loadPageOneUserInfos(CadInfosModel cadInfosModel, String id, VoidCallback onSucess()){

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        if(documentSnapshot.data().containsKey('apelido')){

          print('exists');
          cadInfosModel.updateApelido(documentSnapshot['apelido']);
          cadInfosModel.updatephone(documentSnapshot['phone']);
          cadInfosModel.updateaddress(documentSnapshot['address']);
          cadInfosModel.updateLatLong(documentSnapshot['latlong']);
          cadInfosModel.updateimage(documentSnapshot['image']);
          onSucess();


        } else {

          print('dont exists');

        }

      }
    });

  }


   */
  Future<bool> loadSingleItemFromTrucker(String id, String field){

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(id)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {

        if(documentSnapshot.data().containsKey('apelido')){

        }

        String str = documentSnapshot[field].toString();
        if(str=='null'){
          return false;
        } else {
          return true;
        }

      } else {
        return false;
      }
    });

  }














  //METODOS DE CADASTRO APÓS O LOGIN - NOME, APELIDO, CNH E BANCO







  //METODOS QUE LIDAM COM ACEITAR, DESISTIR OU SER PUNIDO
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

  Future<void> confirmJobAceptance2(UserModel userModel, String moveId,
      @required VoidCallback onSucess(), @required VoidCallback onFail()){

    CollectionReference users = FirebaseFirestore.instance.collection(agendamentosPath);

    return users
        .doc(moveId)
        .update({
      'situacao' : "accepted",
      'id_freteiro' : userModel.Uid,
      'nome_freteiro' : userModel.Apelido,
      'placa' : userModel.Placa

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

  Future<void> truckerQuitWithoutPunishiment_userFault(String moveId, @required VoidCallback onSucess(), @required VoidCallback onFail()){

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
      'data' : DateServices().giveMeTheDateToday(),
      'hora' : DateServices().giveMeTheTimeNow(),

    });

  }
  //METODOS QUE LIDAM COM ACEITAR, DESISTIR OU SER PUNIDO


  //ESPECIFICOS DE BANIMENTO
  //funções de banimento
  Future<void> createBanishmentEntry(String truckerId, String motivo, int tempoBanimento){

    CollectionReference path = FirebaseFirestore.instance.collection(banishmentPath);

    path.doc(truckerId).set({
      'trucker' : truckerId,
      'motivo' : motivo,
      'data' : DateServices().giveMeTheDateToday(),
      'hora' : DateServices().giveMeTheTimeNow(),
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
  //ESPECIFICOS DE BANIMENTO



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




  //FUNCOES DE MUDANÇA
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

  Future<void> loadMoveSituationBackup(String idPedido ,VoidCallback onSucess(), VoidCallback onFail()){

    FirebaseFirestore.instance
        .collection(agendamentosPath)
        .doc(idPedido)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {

        String sit = documentSnapshot['situacao_backup'];



        void _onSucess(){
          onSucess();
        }

        void _onFail(){
          onFail();
        }
        FirestoreServices().updateMoveSituation(sit, idPedido, (){_onSucess();}, (){_onFail();});

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

    CollectionReference history = FirebaseFirestore.instance.collection(historicPathUsers);

    //cria historico do user
    history.doc(moveClass.idPedido).set({
      'user' : moveClass.idPedido,
      'freteiro' : moveClass.freteiroId,
      'preco' : moveClass.preco,
      'origem' : moveClass.enderecoOrigem,
      'destino' : moveClass.enderecoDestino,
      'data' : DateServices().giveMeTheDateToday(),
      'hora' : DateServices().giveMeTheTimeNow(),

    }).then((value) => createHistoricOfMovesToTrucker(moveClass));

  }


  Future<void> createHistoricOfMovesToTrucker(MoveClass moveClass){

    print('moveclass');
    print(moveClass);

    FirebaseFirestore.instance.collection(historicPathTrucker).doc(moveClass.freteiroId).collection('historico').add({
      'user' : moveClass.userId,
      'freteiro' : moveClass.freteiroId,
      'preco' : moveClass.preco,
      'origem' : moveClass.enderecoOrigem,
      'destino' : moveClass.enderecoDestino,
      'data' : DateServices().giveMeTheDateToday(),
      'hora' : DateServices().giveMeTheTimeNow(),
    });

    /*
    CollectionReference history = FirebaseFirestore.instance.collection(historicPathTrucker);
    //cria historico do trucker
    history.doc(moveClass.freteiroId).set({
      'user' : moveClass.idPedido,
      'freteiro' : moveClass.freteiroId,
      'preco' : moveClass.preco,
      'origem' : moveClass.enderecoOrigem,
      'destino' : moveClass.enderecoDestino,
      'data' : DateUtils().giveMeTheDateToday(),
      'hora' : DateUtils().giveMeTheTimeNow(),

    });

     */

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
  //FUNCOES DE MUDANÇA



  Future<void> saveLastUserLocation(String truckerId, double latitude, double longitude){

    CollectionReference userLocation = FirebaseFirestore.instance.collection(locationPath);
    return userLocation
        .doc(truckerId)
        .set({
      'lastTrucker_lat' : latitude,
      'lastTrucker_long' : longitude,
    });

  }



  //AVALIACOES
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

  Future<void> deleteUserData(String uid, @required VoidCallback onSucess()){

    //3 passos:
    //primeiro salva as infos de nota e avaliação do cara num node backup
    //depois apaga as infos do node
    //depois apaga as infos de banco em bank_infos

    int _aval;
    double _rate;
    bool _banido;

    FirebaseFirestore.instance
        .collection(truckerPath)
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {

          if(documentSnapshot.exists){
            _aval = documentSnapshot['aval']??0;
            _rate = documentSnapshot['rate']??0.toDouble();
            _banido = documentSnapshot['banido']??false;

          } else {
            //a info ja foi apagada, deu erro e o user tá tentando novamente
          }


    }).then((_) {


      CollectionReference userLocation = FirebaseFirestore.instance.collection(truckerPath);
      return userLocation
          .doc(uid).delete()
          .then((_) {

        CollectionReference bankData = FirebaseFirestore.instance.collection(bankPath);
        return bankData.doc(uid).delete();
      }).then((_) {

        CollectionReference backup = FirebaseFirestore.instance.collection(rememberTheLastSummer);
        return backup
            .doc(uid)
            .set({
          'rate' : _rate,
          'aval' : _aval,
          'banido' : _banido,
        });

      })
      .then((_) {
        onSucess();
      });


    });

  }

}

