import 'package:flutter/material.dart';

class AppFormField extends StatelessWidget {
  AppFormField({
    @required this.label,
    @required this.iconaSx,
    @required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.controller,
    this.error,
    //this.iconaDx,
  });

  final String label;
  final IconData iconaSx;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
   TextEditingController controller = new TextEditingController();
   final String error;

  //final IconData iconaDx;
  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        new Text(
          label,
          style: new TextStyle(
            color: Colors.black45,
          ),
        ),
        new Container(
          decoration: new BoxDecoration(
            border: new Border(
              bottom: BorderSide(color: Colors.black12),
            ),
          ),
          width: double.infinity,
          child: new Row(
            children: [
              new Icon(
                this.iconaSx,
                color: Colors.black26,
              ),
              new SizedBox(
                width: 10,
              ),
              new Expanded(
                child: new TextFormField(
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  controller: this.controller,
                  obscureText: this.obscureText,
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    hintText: this.hintText,
                  ),
                  keyboardType: this.keyboardType,
                ),
              ),

              /*new IconButton(
                icon: new Icon(
                 iconaDx,
                  color: Colors.black26,
                ),
                onPressed: () {
                  print("ciao");
                },
              )*/
            ],
          ),
        ),
        if(error != null) new Padding(padding: EdgeInsets.only(top:5), child:
        new
        Text(
        error,
          style: new TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),),
      ],
    );
  }
}
