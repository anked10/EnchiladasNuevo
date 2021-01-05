import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:enchiladasapp/src/bloc/provider.dart';
import 'package:enchiladasapp/src/database/adicionales_database.dart';
import 'package:enchiladasapp/src/database/item_observacion_database.dart';
import 'package:enchiladasapp/src/models/carrito_model.dart';
import 'package:enchiladasapp/src/models/productos_model.dart';
import 'package:enchiladasapp/src/models/validar_producto.dart';
import 'package:enchiladasapp/src/pages/detalle_observaciones.dart';
import 'package:enchiladasapp/src/utils/responsive.dart';
import 'package:enchiladasapp/src/utils/translate_animation.dart';
import 'package:enchiladasapp/src/utils/utilidades.dart' as utils;
import 'package:enchiladasapp/src/utils/utilidades.dart';
import 'package:enchiladasapp/src/widgets/cantidad_producto.dart';
import 'package:enchiladasapp/src/utils/preferencias_usuario.dart';
import 'package:enchiladasapp/src/widgets/customCacheManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SliderDetalleProductos extends StatefulWidget {
  final String numeroItem;
  final String idCategoria;
  final String cantidadItems;
  const SliderDetalleProductos(
      {Key key,
      @required this.numeroItem,
      @required this.idCategoria,
      @required this.cantidadItems})
      : super(key: key);

  @override
  _SliderDetalleProductosState createState() => _SliderDetalleProductosState();
}

class _SliderDetalleProductosState extends State<SliderDetalleProductos> {
  @override
  Widget build(BuildContext context) {
    final _pageController =
        PageController(initialPage: int.parse(widget.numeroItem));

    final productoBloc = ProviderBloc.prod(context);
    final contadorProductosFotoLocal = ProviderBloc.contadorLocal(context);
    productoBloc
        .obtenerProductosdeliveryEnchiladasPorCategoria(widget.idCategoria);
    contadorProductosFotoLocal.changeContador(int.parse(widget.numeroItem));

    final responsive = Responsive.of(context);

    return Scaffold(
        body: Stack(
      children: [
        StreamBuilder(
            stream: productoBloc.productosEnchiladasStream,
            builder: (context, AsyncSnapshot<List<ProductosData>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  return PageView.builder(
                      itemCount: snapshot.data.length,
                      controller: _pageController,
                      itemBuilder: (BuildContext context, int index) {
                        return DetalleProductitoss(
                          productosData: snapshot.data[index],
                          mostrarback: false,
                        );
                      },
                      onPageChanged: (int index) {
                        contadorProductosFotoLocal.changeContador(index);
                      });
                } else {
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              } else {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              }
            }),
        StreamBuilder(
            stream: contadorProductosFotoLocal.selectContadorStream,
            builder: (context, snapshotContador) {
              if (snapshotContador.hasData) {
                if (snapshotContador.data != null) {
                  return Container(
                    height: kToolbarHeight + 50,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      actions: [
                        Container(
                          height: responsive.hp(1),
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.wp(2),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[300],
                            border: Border.all(color: Colors.grey[300]),
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: responsive.wp(5),
                            vertical: responsive.hp(1.3),
                          ),
                          child: Row(
                            children: [
                              Text(
                                (contadorProductosFotoLocal.pageContador + 1)
                                    .toString(),
                                style: TextStyle(
                                    fontSize: responsive.ip(1.5),
                                    color: Colors.black),
                              ),
                              Text(
                                ' / ',
                                style: TextStyle(
                                    fontSize: responsive.ip(1.5),
                                    color: Colors.black),
                              ),
                              Text(
                                '${widget.cantidadItems}',
                                style: TextStyle(
                                    fontSize: responsive.ip(1.5),
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                } else
                  return Center(
                    child: CupertinoActivityIndicator(),
                  );
              } else {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              }
            }),
      ],
    ));
  }
}

class DetalleProductitoss extends StatefulWidget {
  final ProductosData productosData;
  final bool mostrarback;

  const DetalleProductitoss(
      {Key key, @required this.productosData, @required this.mostrarback})
      : super(key: key);
  @override
  _DetalleProducto createState() => _DetalleProducto();
}

class _DetalleProducto extends State<DetalleProductitoss> {
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();

  bool mostrar = false;

  bool estadoDelivery = false;
  double _panelHeightOpen;

  TextEditingController observacionProductoController = TextEditingController();
  PanelController panelController = new PanelController();

  @override
  void dispose() {
    // Limpia el controlador cuando el Widget se descarte
    observacionProductoController.dispose();
    super.dispose();
  }

  void llamado() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = Preferences();
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;
    //final ProductosData productos = ModalRoute.of(context).settings.arguments;
    final responsive = Responsive.of(context);
    final productosIdBloc = ProviderBloc.prod(context);

    productosIdBloc.obtenerProductoPorId(widget.productosData.idProducto);
    productosIdBloc.verificarDisponibilidad(widget.productosData.idProducto);

    return ShowCaseWidget(
      onFinish: () {
        preferences.pantallaDProducto = '1';
      },
      autoPlay: false,
      autoPlayDelay: Duration(seconds: 3),
      autoPlayLockEnable: true,
      builder: Builder(builder: (context) {
        Future.delayed(Duration(milliseconds: 700)).then((value) {
          if (preferences.pantallaDProducto != "1") {
            WidgetsBinding.instance.addPostFrameCallback((_) =>
                ShowCaseWidget.of(context).startShowCase([_one, _two, _three]));
          }
        });

        return Material(
          child: StreamBuilder(
            stream: productosIdBloc.productosIdStream,
            initialData: [],
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  return SlidingUpPanel(
                    maxHeight: _panelHeightOpen,
                    minHeight: responsive.hp(7),
                    controller: panelController,
                    parallaxEnabled: true,
                    parallaxOffset: 0.1,
                    backdropEnabled: true,
                    body: Stack(children: <Widget>[
                      _backgroundImage(context, snapshot.data[0]),
                      _crearAppbar(responsive, widget.mostrarback),
                      TranslateAnimation(
                        duration: const Duration(milliseconds: 400),
                        child: _contenido(snapshot.data[0], responsive, context,
                            productosIdBloc),
                      ),
                    ]),
                    panelBuilder: (sc) {
                      return Showcase(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: responsive.wp(40)),
                        key: _three,
                        description:
                            'Puedes presionar o deslizar hacia arriba para ver más detalles y hacer tu pedido',
                        child: TranslateAnimation(
                          duration: const Duration(milliseconds: 600),
                          child: _carritoProductos(responsive, sc),
                        ),
                      );
                    },
                    borderRadius: const BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                    ),
                    //onPanelSlide: (double pos) => setState(() {}),
                  );
                } else {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              } else {
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              }
            },
          ),
        );
      }),
    );
  }

  Widget botonesBajos(Responsive responsive, ProductosData productosData,
      ProductosBloc productosBloc) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: responsive.hp(1),
      ),
      height: responsive.hp(7),
      width: double.infinity,
      child: Row(
        children: <Widget>[
          Showcase(
            key: _one,
            description: 'Presione para agregar añadir a favoritos',
            child: Container(
              width: responsive.wp(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red),
              ),
              child: Center(
                child: (productosData.productoFavorito == 1)
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            print('quitar');
                            utils.quitarFavoritos(context, productosData);
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.solidHeart,
                          color: Colors.red,
                          size: responsive.ip(2.5),
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            print('agregar');
                            utils.agregarFavoritos(context, productosData);
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.heart,
                          color: Colors.red,
                          size: responsive.ip(2.5),
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(
            width: responsive.wp(5),
          ),
          StreamBuilder(
              stream: productosBloc.categoriaTemporizador,
              builder: (context, AsyncSnapshot<ValidarProducto> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.valor) {
                    return Showcase(
                      key: _two,
                      description: 'Presione para agregar producto al carrito',
                      child: GestureDetector(
                        child: Container(
                          width: responsive.wp(65),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red,
                            border: Border.all(color: Colors.red),
                          ),
                          child: Center(
                            child: Text(
                              'Agregar al Carrito',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.ip(2.5),
                              ),
                            ),
                          ),
                        ),
                        onTap: () async {
                          final adicionalesDatabase = AdicionalesDatabase();

                          await adicionalesDatabase
                              .updateAdicionalesEnFalseDb();

                          final itemObservacionDatabase =
                              ItemObservacionDatabase();
                          itemObservacionDatabase.deleteItemObservacion();

                          agregarItemObservacion(
                              context, productosData.idProducto, true);

                          Navigator.of(context)
                              .push(_createRoute(productosData.idProducto,productosData.productoAdicionalOpciones));
                          /* setState(() {
                            mostrar =true;
                            
                          }); */
                          //utils.agregarCarrito(productosData, context, "1");
                        },
                      ),
                    );
                  } else {
                    return InkWell(
                      child: Container(
                        width: responsive.wp(65),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey,
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Center(
                          child: Text(
                            'Agregar al Carrito',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.ip(2.5),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        utils.showToast(
                            '${snapshot.data.mensaje}', 2, ToastGravity.TOP);
                        //utils.agregarCarrito(productosData, context, "1");
                      },
                    );
                  }
                } else {
                  return InkWell(
                    child: Container(
                      width: responsive.wp(65),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: Text(
                          'Agregar al Carrito',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: responsive.ip(2.5),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      utils.showToast(
                          'En estos momentos el producto esta deshabilitado',
                          2,
                          ToastGravity.TOP);
                      //utils.agregarCarrito(productosData, context, "1");
                    },
                  );
                }
              })
        ],
      ),
    );
  }

  Route _createRoute(String idProducto,String adicionalObservacio) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return DetalleObservaciones(
          idProductoArgument: idProducto,
          idCategoria:adicionalObservacio
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Widget _contenido(ProductosData productosData, Responsive responsive,
      BuildContext context, ProductosBloc productosBloc) {
    final precioProdcuto = utils.format(
      double.parse(productosData.productoPrecio),
    );
    return Container(
      margin: EdgeInsets.only(
        top: responsive.hp(25),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.7,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20),
                color: Colors.white),
            padding: EdgeInsets.symmetric(
              horizontal: responsive.wp(5),
            ),
            child: SingleChildScrollView(
              controller: controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: responsive.hp(3),
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          productosData.productoNombre,
                          style: TextStyle(
                              fontSize: responsive.ip(3),
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(
                        width: responsive.wp(3),
                      ),
                      Text(
                        'S/ $precioProdcuto',
                        style: TextStyle(
                            color: Colors.red,
                            fontSize: responsive.ip(4),
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    height: responsive.hp(3),
                  ),
                  botonesBajos(responsive, productosData, productosBloc),
                  //_cantidad(responsive),
                  SizedBox(
                    height: responsive.hp(1),
                  ),

                  ('${productosData.productoNuevo}' == '1')
                      ? Positioned(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: responsive.wp(3),
                              vertical: responsive.wp(.5),
                            ),
                            decoration: BoxDecoration(
                                //borderRadius: BorderRadius.circular(10),
                                color: Colors.red),
                            child: Text(
                              'Producto Nuevo',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: responsive.ip(2),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: responsive.hp(1),
                  ),
                  Text(
                    '${productosData.productoDescripcion}',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: responsive.ip(2),
                    ),
                  ),
                  SizedBox(
                    height: responsive.hp(1.5),
                  ),
                  ('${productosData.productoComentario}' != 'null')
                      ? Text(
                          '${productosData.productoComentario}',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: responsive.ip(2),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: responsive.hp(1.5),
                  ),
                  Text(
                    'Imagen Referencial',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.ip(2),
                    ),
                  ),

                  SizedBox(
                    height: responsive.hp(3),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _carritoProductos(Responsive responsive, ScrollController sc) {
    final carritoBloc = ProviderBloc.carrito(context);
    carritoBloc.obtenerCarrito();

    return StreamBuilder(
      stream: carritoBloc.carritoIdStream,
      builder: (BuildContext context, AsyncSnapshot<List<Carrito>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            return _contenidoDeCarrito(responsive, snapshot.data, sc);
          } else {
            return Column(children: <Widget>[
              GestureDetector(
                onTap: () {
                  //setState(() {
                  if (panelController.isPanelOpen) {
                    panelController.animatePanelToPosition(0);
                  } else {
                    panelController.animatePanelToPosition(1);
                  }
                  //});
                },
                child: panelRojoMonto(responsive, 0.00, '0'),
              ),
              SizedBox(
                height: responsive.hp(3),
              ),
              Container(
                height: responsive.hp(30),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: responsive.wp(10),
                  ),
                  child: SvgPicture.asset('assets/carrito.svg'),
                ),
              ),
              SizedBox(
                height: responsive.hp(3),
              ),
              Text(
                'No hay Productos en el carrito',
                style: TextStyle(color: Colors.black, fontSize: 22),
              )
            ]);
          }
        } else {
          return Center(
            child: SvgPicture.asset('assets/carrito.svg'),
          );
        }
      },
    );
  }

  Widget panelRojoMonto(
      Responsive responsive, double total, String cantidadPedidos) {
    String montoFinalex = utils.format(total);
    return Container(
      height: responsive.hp(8),
      padding: EdgeInsets.symmetric(
        horizontal: responsive.wp(5),
        vertical: responsive.hp(1),
      ),
      decoration: const BoxDecoration(
          borderRadius: BorderRadiusDirectional.only(
            topEnd: Radius.circular(20),
            topStart: Radius.circular(20),
          ),
          color: Colors.red),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: responsive.hp(.4),
            ),
            child: Container(
              height: responsive.hp(.6),
              width: responsive.wp(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Monto S/$montoFinalex',
                  style: TextStyle(
                      color: Colors.white, fontSize: responsive.ip(3)),
                ),
              ),
              Stack(children: <Widget>[
                Icon(
                  Icons.shopping_cart,
                  size: responsive.ip(4),
                  color: Colors.white,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: BounceInDown(
                    from: 10,
                    child: Container(
                      child: Text(
                        '$cantidadPedidos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.ip(1.5),
                        ),
                      ),
                      alignment: Alignment.center,
                      width: responsive.ip(1.8),
                      height: responsive.ip(1.8),
                      decoration: BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                    ),
                  ),
                )
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contenidoDeCarrito(
      Responsive responsive, List<Carrito> carrito, ScrollController sc) {
    double subtotal = 0;
    double total = 0;
    double valorDelivery = 0;
    int cant = 0;
    for (int i = 0; i < carrito.length; i++) {
      if (carrito[i].productoTipo != '1') {
        subtotal = subtotal +
            (double.parse(carrito[i].productoPrecio) *
                double.parse(carrito[i].productoCantidad));
      } else {
        estadoDelivery = true;
        valorDelivery = double.parse(carrito[i].productoPrecio);
      }
      /* subtotal = subtotal +
          (double.parse(carrito[i].productoPrecio) *
              double.parse(carrito[i].productoCantidad)); */
      cant++;
    }

    total = subtotal + valorDelivery;
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            /* setState(
              () { */
            if (panelController.isPanelOpen) {
              panelController.animatePanelToPosition(0);
            } else {
              panelController.animatePanelToPosition(1);
            }
            /* },
            ); */
          },
          child: panelRojoMonto(
            responsive,
            total,
            cant.toString(),
          ),
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: <Widget>[
              _resumenPedido(responsive, subtotal, valorDelivery),
              _pagarCarrito(context, responsive),
              _listaProductos(responsive, carrito),
            ],
          ),
        )
      ],
    );
  }

  Widget _listaProductos(Responsive responsive, List<Carrito> carrito) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 3, color: Colors.black26),
        ],
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(13),
      ),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemCount: carrito.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: EdgeInsets.only(
                top: responsive.hp(1.2),
                left: responsive.wp(2),
                right: responsive.wp(2),
              ),
              child: Text(
                'Productos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: responsive.ip(2.8),
                ),
              ),
            );
          }
          final index = i - 1;

          if (carrito[index].idCategoria == '97') {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: responsive.hp(2)),
              child: Row(
                children: [
                  Text(
                    '${carrito[index].productoNombre}',
                    style: TextStyle(
                        fontSize: responsive.ip(2),
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    'S/.${carrito[index].productoPrecio}',
                    style: TextStyle(
                        fontSize: responsive.ip(2),
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: responsive.ip(4),
                    ),
                    onPressed: () {
                      utils.deleteProductoCarrito(
                          context, carrito[index].idProducto);
                    },
                  ),
                ],
              ),
            );
          }
          return _itemPedido(
            responsive,
            carrito[index],
          );
        },
      ),
    );
  }

  Widget _itemPedido(Responsive responsive, Carrito carrito) {
    final preciofinal = utils.format(double.parse(carrito.productoPrecio) *
        double.parse(carrito.productoCantidad));
    var observacionProducto = 'Toca para agregar una observación';
    if (carrito.productoObservacion != null &&
        carrito.productoObservacion != ' ') {
      observacionProducto = carrito.productoObservacion;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: responsive.hp(1),
      ),
      child: (carrito.productoTipo != '1')
          ? Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: responsive.wp(35),
                      height: responsive.hp(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          cacheManager: CustomCacheManager(),
                          placeholder: (context, url) => Image(
                              image: AssetImage('assets/jar-loading.gif'),
                              fit: BoxFit.cover),
                          errorWidget: (context, url, error) => Image(
                              image: AssetImage('assets/carga_fallida.jpg'),
                              fit: BoxFit.cover),
                          imageUrl: '${carrito.productoFoto}',
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: responsive.wp(2),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            carrito.productoNombre,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: responsive.ip(1.8),
                            ),
                          ),
                          Text(
                            '$preciofinal',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: responsive.ip(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: responsive.ip(3),
                            ),
                            onPressed: () {
                              utils.deleteProductoCarrito(
                                  context, carrito.idProducto);
                            },
                          ),
                          Container(
                            child: CantidadTab(
                                carrito: carrito, llamada: this.llamado),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: responsive.hp(1),
                ),
                GestureDetector(
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: responsive.wp(1),
                      ),
                      Icon(
                        Icons.mode_edit,
                        color: Colors.red,
                        size: responsive.ip(2),
                      ),
                      SizedBox(
                        width: responsive.wp(1),
                      ),
                      Expanded(
                        child: Text(
                          '$observacionProducto',
                          style: TextStyle(
                            fontSize: responsive.ip(2),
                          ),
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    observacionProductoController.text =
                        '${carrito.productoObservacion}';
                    dialogoObservacionProducto('${carrito.idProducto}');
                  },
                )
              ],
            )
          : Container(),
    );
  }

  Widget _resumenPedido(
      Responsive responsive, double subtotal, double valorDelivery) {
    final subtotal2 = utils.format(subtotal);
    final valorDelivery2 = utils.format(valorDelivery);
    final totalex = utils.format(subtotal + valorDelivery);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.wp(2),
      ),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: EdgeInsets.all(
            responsive.wp(2),
          ),
          child: Column(children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Sub Total ',
                    style: TextStyle(
                      fontSize: responsive.ip(2),
                    ),
                  ),
                ),
                Text(
                  'S/ $subtotal2',
                  style: TextStyle(
                    fontSize: responsive.ip(2),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: responsive.hp(2),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Entrega rápida',
                    style: TextStyle(
                      fontSize: responsive.ip(2),
                    ),
                  ),
                ),
                Text(
                  'S/ $valorDelivery2',
                  style: TextStyle(
                    fontSize: responsive.ip(2),
                  ),
                )
              ],
            ),
            SizedBox(
              height: responsive.hp(2),
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  'Total a pagar',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.ip(2.2),
                  ),
                )),
                Text(
                  'S/ $totalex',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.ip(2.2),
                  ),
                )
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Widget _pagarCarrito(BuildContext context, Responsive responsive) {
    final preferences = Preferences();
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.all(
          responsive.wp(2),
        ),
        child: Container(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: responsive.hp(5),
                child: RaisedButton(
                    color: Colors.white,
                    textColor: Colors.red,
                    child: Text(
                      'Continuar Comprando',
                      style: TextStyle(
                        fontSize: responsive.ip(2),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              SizedBox(
                height: responsive.hp(.8),
              ),
              SizedBox(
                width: double.infinity,
                height: responsive.hp(5),
                child: RaisedButton(
                    color: (preferences.rol == '5') ? Colors.red : Colors.grey,
                    textColor: Colors.white,
                    child: Text(
                      'Ordenar Pedido',
                      style: TextStyle(
                        fontSize: responsive.ip(2),
                      ),
                    ),
                    onPressed: () {
                      if (preferences.rol == '5') {
                        final prefs = Preferences();

                        if (prefs.email != null && prefs.email != "") {
                          prefs.propinaRepartidor = '0';
                          Navigator.pushNamed(context, 'detallePago');
                        } else {
                          pedirLogueo();
                        }
                        /* utils.showToast(
                            'No tiene permisos', 2, ToastGravity.TOP); */
                      } else {
                        utils.showToast(
                            'No tiene permisos', 2, ToastGravity.TOP);
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        final prefs = Preferences();

        if (prefs.email != null && prefs.email != "") {
          prefs.propinaRepartidor = '0';
          Navigator.pushNamed(context, 'detallePago');
        } else {
          pedirLogueo();
        }
      },
    );
  }

  void pedirLogueo() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (contextd) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text('Debe registrarse para Ordenar'),
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              FlatButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, 'login', (route) => false);
                },
                child: Text('Continuar'),
              ),
            ],
          );
        });
  }

  Widget _crearAppbar(Responsive responsive, bool mostrar) {
    return (mostrar)
        ? Container(
            height: kToolbarHeight + 30,
            child: AppBar(
              leading: BackButton(
                color: Colors.white,
              ),
              backgroundColor: Colors.transparent,
            ),
          )
        : Container();
  }
  //flutter build apk -- release gliutter buils apk -- releadse

  Widget _backgroundImage(BuildContext context, ProductosData carrito) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'detalleProductoFoto', arguments: carrito);
      },
      onVerticalDragUpdate: (drag) {
        if (drag.primaryDelta > 7) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: double.infinity,
        height: size.height * 0.50,
        child: Hero(
          tag: '${carrito.idProducto}',
          child: ClipRRect(
            child: CachedNetworkImage(
              cacheManager: CustomCacheManager(),
              placeholder: (context, url) => Image(
                  image: const AssetImage('assets/jar-loading.gif'),
                  fit: BoxFit.cover),
              errorWidget: (context, url, error) => Image(
                  image: AssetImage('assets/carga_fallida.jpg'),
                  fit: BoxFit.cover),
              imageUrl: '${carrito.productoFoto}',
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void dialogoObservacionProducto(String id) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (contextd) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text('Ingrese la observación del producto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  maxLines: 3,
                  controller: observacionProductoController,
                ),
                //Text('Producto agregado al carrito correctamente'),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar')),
              FlatButton(
                onPressed: () async {
                  utils.actualizarObservacion(
                      context, observacionProductoController.text, id);

                  observacionProductoController.text = '';

                  Navigator.pop(context);
                },
                child: Text('Aceptar'),
              ),
            ],
          );
        });
  }
}
