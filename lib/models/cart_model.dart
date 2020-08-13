import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_flutter/datas/cart_product.dart';
import 'package:loja_flutter/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

// ignore: slash_for_doc_comments
/**
 * Essa classe esta sendo utilizada para fazer todo o 
 * controle de produtos que estão no carrinho do usuário. 
 * */

class CartModel extends Model {
  UserModel user; // Usuário logado

  List<CartProduct> products = []; // Lista local de produtos no carrinho

  String cuponCode; // Cupom de desconto que está sendo utilizaado
  int discountPercentage =
      0; // Porcentagem de desconto que está sendo aplicada.

  bool isLoading = false; // Indica se algo está sendo carregado.

  // Construtor do CartModel
   
  CartModel(this.user) {
    if (this.user.isLoggedIn()) _loadCartItems();
  }

  // Permite usar o comando CartModel.of(context)
  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  void setCoupon(String couponCode, int discountPercentage) {
    /**
     * Salva o cupom que está sendo utilizado.
     * E a porcentagem de desconto aplicado.
     */
    this.cuponCode = couponCode;
    this.discountPercentage = discountPercentage;
  }

  Future<String> finishOrder() async {
    if (products.length == 0) return null;

    isLoading = true;
    notifyListeners();

    double productPrice = getProductsPrice();
    double shipPrice = getShipPrice();
    double discount = getDiscount();

    DocumentReference refOrder =
        await Firestore.instance.collection("orders").add({
      "clientId": user.firebaseUser.uid,
      "products": products.map((cartProduct) => cartProduct.toMap()).toList(),
      "shipPrice": shipPrice,
      "productsPrice": productPrice,
      "discount": discount,
      "totalPrice": productPrice - discount + shipPrice,
      "status": 1,
    });

    await Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("orders")
        .document(refOrder.documentID)
        .setData({
      "orderId": refOrder.documentID,
    });

    QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid).collection("cart").getDocuments();

    for(DocumentSnapshot doc in query.documents){
      doc.reference.delete();
    }

    products.clear();
    discountPercentage = 0;
    cuponCode = null;

    isLoading = false;
    notifyListeners();

    return refOrder.documentID;
  }

  void updatePrices() {
    /**
     * Atualiza o preço total do carrinho.
     * É chamado sempre que um novo CartTile é criado.
     */
    notifyListeners();
  }

  double getProductsPrice() {
    /**
     * Retorna o valor total dos produtos que estão no carrinho
     */
    double price = 0.0;
    for (CartProduct c in products) {
      // Percorre todos os produtos do carrinho
      if (c.productData != null) price += c.productData.price * c.quantity;
    }
    return price;
  }

  double getDiscount() {
    /**
     * Calcula a quantidade em Reais que está sendo descontado do valor total.
     */
    return getProductsPrice() * (discountPercentage / 100);
  }

  double getShipPrice() {
    /**
     * Retorna o valor do frete.
     */
    return 9.99;
  }

  void addCardItem(CartProduct cardProduct) {
    /**
     * Adiciona um novo produto ao carrinho de compras
     */
    isLoading = true;
    notifyListeners();
    products.add(cardProduct); // Adiciona o CardProduct ao carrinho local.

    // Salva o novo produto do carrinho no banco de dados
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .add(cardProduct.toMap())
        .then((document) {
      cardProduct.cid = document.documentID;
    });
    isLoading = false;
    notifyListeners();
  }

  void removeCardItem(CartProduct cardProduct) {
    /**
     * Remove um item do carrinho.
     */
    isLoading = true;
    notifyListeners();

    // É apagado do banco de dados.
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cardProduct.cid)
        .delete();

    // É apagado da lista local.
    products.remove(cardProduct);
    isLoading = false;
    notifyListeners();
  }

  void decProduct(CartProduct cartProduct) {
    /**
     * Decrementa a quantidade daquele produto que está no carrinho.
     */
    cartProduct.quantity--;

    // Salva a alteração no banco de dados.
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  void incProduct(CartProduct cartProduct) {
    /**
     * Incrementa a quantidade daquele produto que está no carrinho.
     */
    cartProduct.quantity++;

    // Salva a alteração no banco de dados.
    Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .document(cartProduct.cid)
        .updateData(cartProduct.toMap());
    notifyListeners();
  }

  void _loadCartItems() async {
    /**
     * Pega todos os produtos do carrinho daquele usuário.
     * E salva na lista de produtos local.
     */
    QuerySnapshot query = await Firestore.instance
        .collection("users")
        .document(user.firebaseUser.uid)
        .collection("cart")
        .getDocuments();
    products =
        query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();
    notifyListeners();
  }
}
