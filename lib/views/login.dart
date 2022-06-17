import 'package:flutter/material.dart';
import 'package:pasaporte/services/http_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'menu.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String user = "";
  String password = "";
  bool passenable = true;

  @override
  void initState(){
    checkLogin();
    super.initState();
  }

  void checkLogin() async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("token");
    if(token != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Menu()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
          child: Column(
            mainAxisAlignment : MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/sre.png',
                  height: 150,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: TextStyle(
                      color: Color(0xffb621132)
                  ),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.person,
                    color: Color(0xffb621132),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffb621132), width: 2.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    user = value;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
              ),
              TextFormField(
                obscureText: passenable,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(
                      color: Color(0xffb621132)
                  ),
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(onPressed: (){ //add Icon button at end of TextField
                    setState(() { //refresh UI
                      if(passenable){ //if passenable == true, make it false
                        passenable = false;
                      }else{
                        passenable = true; //if passenable == false, make it true
                      }
                    });
                  }, icon: Icon(passenable == true?Icons.remove_red_eye:Icons.password), color: Color(0xffb621132)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xffb621132), width: 2.0),
                  ),
                ),
                enableSuggestions: false,
                autocorrect: false,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              InkWell(
                  onTap: () async {
                    if(password == "" || user == ""){
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Error al ingresar'),
                          content: const Text('Debe de ingresar todos los campos solicitados'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'OK'),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else{
                      await HttpService.login(user, password, context);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 30),
                    child: const Center(
                      child: Text(
                        "Ingresar",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Color(0xffb621132),
                        borderRadius: BorderRadius.circular(25)),
                  ))
            ],
          ),
        )
      // ignore: avoid_unnecessary_containers
    );
  }
}