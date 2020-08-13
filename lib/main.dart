import 'package:flutter/material.dart';
import 'package:loja_flutter/models/cart_model.dart';
import 'package:loja_flutter/models/user_model.dart';
import 'package:loja_flutter/screens/home_screen.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>( // Fornece dados do usuário
      model: UserModel(),
      child: ScopedModelDescendant<UserModel>( // Descendente do Model de usuário
        builder: (context, child, model){
          return ScopedModel<CartModel>( /** Card Model, fornece informações do carrinho.
                                           * Tem informações sobre o usuario logado */
            model: CartModel(model),
            child: MaterialApp(
              title: "Flutter's Clothing",
              theme: ThemeData(
                primarySwatch: Colors.blue,
                primaryColor: Color.fromARGB(255, 4, 125, 141),
                accentColor: Color.fromARGB(255, 4, 125, 141),
              ),
              debugShowCheckedModeBanner: false,
              home: HomeScreen(),
            ),
          );
        }
      ),
    );
  }
}
