class Attendance {
  String user_id;
  String latitud;
  String longitud;
  String placeName;
  String placeDescription;
  DateTime fechaInicial;
  DateTime fechaFinal;

  void getDataGoogle() {
    //Geolocator().placemarkFromCoordinates(latitud, longitud);
  }

  DateTime get getFechaInicial => fechaInicial;
  DateTime get getFechaFinal => fechaFinal;
  String get getplaceName => placeName;
  String get getplaceDescription => placeDescription;

  void setFechaInicial(DateTime f) {
    fechaInicial = f;
  }

  void setFechaFinal(DateTime f) {
    fechaFinal = f;
  }
}
