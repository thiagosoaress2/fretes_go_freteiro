import 'package:fretes_go_freteiro/models/usermodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {

  Future<void> saveBasicInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('uid', userModel.Uid);
    await prefs.setString('email', userModel.Email);

  }

  Future<UserModel> loadBasicInfoFromSharedPrefs(UserModel userModel) async {
    //MoveClass moveClass = MoveClass.empty();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String value = (prefs.getString('uid').toString());
    userModel.updateUid(value);
    value = (prefs.getString('email').toString());
    userModel.updateEmail(value);

  }

  Future<void> saveFireStoreInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('fullName', userModel.FullName);
    await prefs.setString('image', userModel.Image);
    await prefs.setString('apelido', userModel.Apelido);
    await prefs.setDouble('latlong', userModel.LatLong);

  }

  Future<void> savePageOneInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('image', userModel.Image);
    await prefs.setString('apelido', userModel.Apelido);
    await prefs.setDouble('latlong', userModel.LatLong);
    await prefs.setString('phone', userModel.Phone);
    await prefs.setInt('all_info_done', 1);

  }

  Future<void> savePageTwoInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('all_info_done', 2);

  }

  Future<void> savePageThreeInfo(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('vehicle', userModel.Image);
    await prefs.setString('apelido', userModel.Apelido);
    await prefs.setDouble('latlong', userModel.LatLong);
    await prefs.setString('phone', userModel.Phone);
    await prefs.setInt('all_info_done', 3);

  }

  Future<void> saveAval(UserModel userModel) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('aval', userModel.Aval);

  }

  Future<bool> thereIsBasicInfoSavedInShared() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = 'nao';
    uid = (prefs.getString('uid'));
    if(uid=='nao'){
      return false;
    } else {
      return true;
    }

  }

  Future<bool> thereIsFireStoreInfoSavedInShared() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Double = 'latlong';
    uid = (prefs.getString('uid'));
    if(uid=='nao'){
      return false;
    } else {
      return true;
    }

  }

  /*
  Future<void> saveMoveClassToShared(MoveClass moveClass) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('enderecoOrigem', moveClass.enderecoOrigem);
    await prefs.setString('enderecoDestino', moveClass.enderecoDestino);
    await prefs.setDouble('latEnderecoOrigem', moveClass.latEnderecoOrigem);
    await prefs.setDouble('longEnderecoOrigem', moveClass.longEnderecoOrigem);
    await prefs.setDouble('latEnderecoDestino', moveClass.latEnderecoDestino);
    await prefs.setDouble('longEnderecoDestino', moveClass.longEnderecoDestino);
    await prefs.setInt('ajudantes', moveClass.ajudantes);
    await prefs.setString('carro', moveClass.carro);
    await prefs.setDouble('preco', moveClass.preco);
    await prefs.setString('ps', moveClass.ps);
    await prefs.setBool('escada', moveClass.escada);
    await prefs.setInt('lancesEscada', moveClass.lancesEscada);
    await prefs.setString('freteiroId', moveClass.freteiroId);
    await prefs.setString('nomeFreteiro', moveClass.nomeFreteiro);
    await prefs.setString('dateSelected', moveClass.dateSelected);
    await prefs.setString('timeSelected', moveClass.timeSelected);
    await prefs.setString('userImage', moveClass.userImage);
    await prefs.setString('freteiroImage', moveClass.freteiroImage);
    await prefs.setString('situacao', moveClass.situacao);
    await prefs.setString('userId', moveClass.userId);

  }

  Future<MoveClass> loadMoveClassFromSharedPrefs(MoveClass moveClass) async {
    //MoveClass moveClass = MoveClass.empty();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String endereco = (prefs.getString('enderecoOrigem').toString());
    if(endereco!= null){ //se for diferente de null é pq tem coisa armazenada
      moveClass.enderecoOrigem = (prefs.getString('enderecoOrigem'));
      moveClass.enderecoDestino = (prefs.getString('enderecoDestino'));
      moveClass.latEnderecoOrigem = (prefs.getDouble('latEnderecoOrigem'));
      moveClass.longEnderecoOrigem = (prefs.getDouble('longEnderecoOrigem'));
      moveClass.latEnderecoDestino = (prefs.getDouble('latEnderecoDestino'));
      moveClass.longEnderecoDestino = (prefs.getDouble('longEnderecoDestino'));
      moveClass.ajudantes = (prefs.getInt('ajudantes'));
      moveClass.carro = (prefs.getString('carro'));
      moveClass.preco = (prefs.getDouble('preco'));
      moveClass.ps = (prefs.getString('ps'));
      moveClass.escada = (prefs.getBool('escada'));
      moveClass.lancesEscada = (prefs.getInt('lancesEscada'));
      moveClass.freteiroId = (prefs.getString('freteiroId'));
      moveClass.nomeFreteiro = (prefs.getString('nomeFreteiro'));
      moveClass.dateSelected = (prefs.getString('dateSelected'));
      moveClass.timeSelected = (prefs.getString('timeSelected'));
      moveClass.userImage = (prefs.getString('userImage'));
      moveClass.freteiroImage = (prefs.getString('freteiroImage'));
      moveClass.situacao = (prefs.getString('situacao'));
      moveClass.userId = (prefs.getString('userId'));
    }

    return moveClass;


  }

  //Aqui estes métodos são somente para a primeira página, onde salva a lista de itens do usuário
  Future<void> saveListOfItemsInShared(List<ItemClass> itemsSelectedCart) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int cont=0;

    while(cont<itemsSelectedCart.length){
      await prefs.setString('item_name'+cont.toString(), itemsSelectedCart[cont].name);
      await prefs.setString('item_image'+cont.toString(), itemsSelectedCart[cont].image);
      await prefs.setBool('item_single_person'+cont.toString(), itemsSelectedCart[cont].singlePerson);
      await prefs.setDouble('item_volume'+cont.toString(), itemsSelectedCart[cont].volume);
      await prefs.setDouble('item_weight'+cont.toString(), itemsSelectedCart[cont].weight);
      cont++;
      await prefs.setInt('item_list_size', cont);  //utilizar isto para saber o tamanho da lista
    }
  }

  //obs: Este método precisa ser chamado antes de apagar a lista
  Future<void> clearListInShared(int size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int cont=0;
    while(cont<size){
      await prefs.remove('item_name'+cont.toString());
      await prefs.remove('item_image'+cont.toString());
      await prefs.remove('item_single_person'+cont.toString());
      await prefs.remove('item_volume'+cont.toString());
      await prefs.remove('item_weight'+cont.toString());
      await prefs.remove('item_list_size');
    }

  }

  Future<bool> thereIsItemsSavedInShared() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = (prefs.getInt('item_list_size'));
    if(counter==0 || counter==null){
      return false;
    } else {
      return true;
    }

  }


   */

}