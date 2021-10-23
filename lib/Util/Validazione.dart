//funzione con un solo argomento ovvero una funzione
bool validazione(Function daValidare) {
  bool valid = true;
  /*final x = (bool condizione, Function fn) {
    valid = valid && !condizione;
    if (condizione && fn != null) fn();
  };*/

  //funzione in cui viene passata la condizione booleana(email.isEmpty) ed una
  // funzione

  daValidare( (bool condizione, Function fn) {
    valid = valid && !condizione;
    if (condizione && fn != null) fn();
  } );
  return valid;
}

bool isValidEmail(String email) {
  return RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
}
