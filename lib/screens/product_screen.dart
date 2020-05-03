import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:loja_flutter/datas/cart_product.dart';
import 'package:loja_flutter/datas/product_data.dart';
import 'package:loja_flutter/models/cart_model.dart';
import 'package:loja_flutter/models/user_model.dart';
import 'package:loja_flutter/screens/cart_screen.dart';
import 'package:loja_flutter/screens/login_screen.dart';

class TelaDoProduto extends StatefulWidget {
  final ProductData product;

  TelaDoProduto(this.product);

  @override
  _TelaDoProdutoState createState() => _TelaDoProdutoState(product);
}

class _TelaDoProdutoState extends State<TelaDoProduto> {
  final ProductData product;
  String size;

  _TelaDoProdutoState(this.product);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 0.9,
            child: Carousel(
              images: product.images.map((url) {
                return NetworkImage(url);
              }).toList(),
              dotSize: 4.0,
              dotSpacing: 15.0,
              dotBgColor: Colors.transparent,
              dotColor: Colors.grey[500],
              dotIncreasedColor: primaryColor,
              autoplay: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  product.title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                  maxLines: 3,
                ),
                Text(
                  "R\$ ${product.price.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                ),
                SizedBox(height: 16.0),
                Text(
                  "Tamanho:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 34.0,
                  child: GridView(
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    scrollDirection: Axis.horizontal,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.5,
                    ),
                    children: product.sizes.map((s) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            size = s;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            border: Border.all(
                              color:
                                  size == s ? primaryColor : Colors.grey[500],
                              width: 3.0,
                            ),
                          ),
                          width: 50.0,
                          alignment: Alignment.center,
                          child: Text(s),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  height: 44.0,
                  child: RaisedButton(
                    color: primaryColor,
                    onPressed: size != null
                        ? () {
                            if (UserModel.of(context).isLoggedIn()) {
                              CartProduct cardProduct = CartProduct();
                              cardProduct.size = size;
                              cardProduct.quantity = 1;
                              cardProduct.pid = product.id;
                              cardProduct.category = product.category;
                              cardProduct.productData = product;

                              CartModel.of(context).addCardItem(cardProduct);

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => CartScreen()),
                              );
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text(
                      UserModel.of(context).isLoggedIn()
                          ? "Adicionar ao Carrinho"
                          : "Entre para comprar",
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  "Descrição:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 16.0),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
