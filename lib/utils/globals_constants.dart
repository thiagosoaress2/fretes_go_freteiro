class GlobalsConstants {


  //constants de punição do freteiro
  static final int banishementTime1 = 1; //1 semana de banimento para sair sem terminar a mudança
  static final int banishementTime2 = 2; //2 semana de banimento por nao aparecer pra mudança
  static final String banishmentInform1 = 'Abandono da mudança sem concluir';  //aviso colocado para o trucker no bd...é o que ele vai ler na popup
  static final String banishmentInform2 = 'Não compareceu para fazer a mudança';

  //constants de punição que nao levam a banimento
  static final String punishmentEntry1 = 'trucker desistiu após pagamento do user';
  static final String punishmentEntry2 = 'trucker não concluiu a mudança';
  static final String punishmentEntry3 = 'trucker não apareceu';

  //aviso colocado para o trucker no bd...é o que ele vai ler na popup

  //variaveis de situação
  static String sitAguardando = 'aguardando';  //<<fazer nada
  static String sitAguardandoFreteiro = 'aguardando_freteiro';
  static String sitTruckerFinished = 'trucker_finished';  //<<desabilitar os controles e exibir mensagem
  static String sitTruckerIsFinishingNow = 'trucker_is_finishing';
  static String sitTruckerQuitAfterPayment = 'trucker_quited_after_payment';  //<<desabilitar os controles e exibir mensagem mas permitir trocar motorista
  static String sitUserInformTruckerDidntMakeMove = 'user_informs_trucker_didnt_make_move';  //<<desabilitar os controles e exibir a mensagem
  static String sitUserInformTruckerDidntFinishedMove = 'user_informs_trucker_didnt_finished_move'; //<<desabilitar os controles e exibir a mensagem
  static String sitAccepted = 'accepted'; //<<exibir tudo
  static String sitPago = 'pago';  //<<exibir tudo
  static String sitQuit = 'quit';  //<<exibir tudo
  static String sitDeny = 'deny';
  static String sitUserInformTruckerDidntFinishedButItsGoingBack = 'user_informs_trucker_didnt_finished_move_goingback'; //<<esse n tem correspondencia no app do user
  static String sitUserFinished = 'user_finished';
  static String sitTruckerIsGoingToMove = 'motorista a caminho';
  static String sitReschedule = 'reagendou';
  static String sitAguardandoEspecifico = 'aguardando_especifico';


  //veiculos
  static String carroca = 'carroca';
  static String pickupPequena = 'pickupP';
  static String pickupGrande = 'pickupG';
  static String kombiFechada = 'kombiF';
  static String kombiAberta = 'kombiA';
  static String caminhaoBauPequeno = 'caminhaoBP';
  static String caminhaoBauGrande = 'caminhaoBG';
  static String caminhaoPequenoAberto = 'caminhaoPA';

}

