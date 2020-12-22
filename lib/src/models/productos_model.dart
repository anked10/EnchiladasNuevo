// To parse this JSON data, do
//
//     final productos = productosFromJson(jsonString);

import 'dart:convert';

Productos productosFromJson(String str) => Productos.fromJson(json.decode(str));

String productosToJson(Productos data) => json.encode(data.toJson());

class Productos {
  Productos({
    this.result,
  });

  Result result;

  factory Productos.fromJson(Map<String, dynamic> json) => Productos(
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result.toJson(),
      };
}

class Result {
  Result({
    this.code,
    this.data,
  });

  int code;
  List<ProductosData> data;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        code: json["code"],
        data: List<ProductosData>.from(
            json["data"].map((x) => ProductosData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ProductosData {
  ProductosData({
    this.idProducto,
    this.idCategoria,
    this.productoNombre,
    this.productoFoto,
    this.productoOrden,
    this.productoPrecio,
    this.productoDelivery,
    this.productoCarta,
    this.productoUnidad,
    this.productoEstado,
    this.productoDescripcion,
    this.productoComentario,
    this.productoSeleccionado,
    this.productoFavorito,
    this.productoObservacion,
    this.sonido,
  });

  String idProducto;
  String idCategoria;
  String productoNombre;
  String productoFoto;
  String productoOrden;
  String productoPrecio;
  String productoCarta;
  String productoDelivery;
  String productoUnidad;
  String productoEstado;
  String numeroitem;
  String productoDescripcion;
  String productoComentario;
  String productoSeleccionado;
  int productoFavorito;
  String sonido;
  String productoObservacion;

  factory ProductosData.fromJson(Map<String, dynamic> json) => ProductosData(
        idProducto: json["id_producto"],
        idCategoria: json["id_categoria"],
        productoNombre: json["producto_nombre"],
        productoFoto: json["producto_foto"],
        productoOrden: json["producto_orden"],
        productoPrecio: json["producto_precio"],
        productoCarta: json["producto_carta"],
        productoDelivery: json["producto_delivery"],
        productoUnidad: json["producto_unidad"],
        productoEstado: json["producto_estado"],
        productoDescripcion: json["producto_descripcion"],
        productoObservacion: json["producto_observacion"],
        productoComentario: json["producto_comentario"],
        productoSeleccionado: json["producto_seleccionado"],
        productoFavorito: json["producto_favorito"],
        sonido: json["producto_sonido"],
      );

  Map<String, dynamic> toJson() => {
        "id_producto": idProducto,
        "id_categoria": idCategoria,
        "producto_nombre": productoNombre,
        "producto_foto": productoFoto,
        "producto_precio": productoPrecio,
        "producto_unidad": productoUnidad,
        "producto_estado": productoEstado,
        "producto_descripcion": productoDescripcion,
        "producto_favorito": productoFavorito,
      };
}