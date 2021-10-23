import 'package:flutter/material.dart';

class PulsanteFocus extends StatelessWidget {
  PulsanteFocus({
    @required this.child,
    @required this.backgroundColor,
    @required this.onPressed,
  });

  final Function onPressed;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new MaterialButton(
      onPressed: this.onPressed,
      color: this.backgroundColor,
      minWidth: double.infinity,
      height: 60,
      child: this.child,
      textColor: Colors.white,
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.circular(50),
      ),
    );
  }
}
