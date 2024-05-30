import 'package:flutter/material.dart';

class CustomTextForm extends StatelessWidget {
  final String hinttext;
  final TextEditingController mycontroller;
  final String? Function(String?)? validator;

  
  const CustomTextForm({super.key, required this.hinttext, required this.mycontroller,required this.validator});

  @override
  Widget build(BuildContext context) {
    bool isPassword = hinttext.toLowerCase().contains('entrer votre mot de passe');
    return TextFormField(
      validator: validator,
      controller: mycontroller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hinttext,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.grey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: Colors.grey)),
      ),
    );
  }
}
