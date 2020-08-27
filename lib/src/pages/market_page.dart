import 'package:cached_network_image/cached_network_image.dart';
import 'package:enchiladasapp/src/bloc/provider.dart';
import 'package:enchiladasapp/src/models/categoria_model.dart';
import 'package:enchiladasapp/src/models/productos._model.dart';
import 'package:enchiladasapp/src/search/search_delegate.dart';
import 'package:enchiladasapp/src/utils/responsive.dart';
import 'package:enchiladasapp/src/utils/utilidades.dart' as utils;
import 'package:enchiladasapp/src/widgets/zona_direction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MarketPage extends StatelessWidget {
  final _refreshController = RefreshController(initialRefresh: false);
  void _onRefresh(BuildContext context) async {
    print('_onRefresh');
    final categoriasBloc = ProviderBloc.cat(context);
    categoriasBloc.cargandoCategoriasFalse();
    categoriasBloc.obtenerCategoriasMarket();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final categoriasBloc = ProviderBloc.cat(context);
    categoriasBloc.cargandoCategoriasFalse();
    categoriasBloc.obtenerCategoriasMarket();

    final reaponsive = Responsive.of(context);

    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          height: reaponsive.hp(50),
          width: double.infinity,
          color: Colors.red,
        ),
        rowDatos(context, categoriasBloc)
      ]),
    );
  }

  Widget rowDatos(BuildContext context, CategoriasBloc categoriasBloc) {
    final responsive = Responsive.of(context);
    final anchoCategorias = responsive.wp(24);
    final anchoProductos = responsive.wp(70);

    return SafeArea(
      child: Column(
        children: <Widget>[
          AppBar(
            backgroundColor: Colors.red,
            elevation: 0,
            title: Text(
              'Market 247',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.ip(2.8),
                  fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: responsive.ip(3.5),
                ),
                onPressed: () {
                  showSearch(
                      context: context,
                      delegate: DataSearch(hintText: 'Buscar'));
                },
              )
            ],
          ),
          Expanded(
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.only(
                        topEnd: Radius.circular(13),
                        topStart: Radius.circular(13)),
                    color: Colors.grey[50]),
                padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(3), vertical: responsive.hp(1)),
                child: SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () {
                    _onRefresh(context);
                  },
                  child: StreamBuilder(
                    stream: categoriasBloc.categoriasMarketStream,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length > 0) {
                          return _conte(context,
                              anchoCategorias, anchoProductos, snapshot.data);
                        } else {
                          return Center(
                            child: Text('No hay datos de categorias'),
                          );
                        }
                      } else {
                        return Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }
                    },
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _conte(BuildContext context, double anchoCategorias,
      double anchoProductos, List<CategoriaData> categorias) {
    final marketBloc = ProviderBloc.market(context);
    marketBloc.changeIndexPage(categorias[0].idCategoria);

    return StreamBuilder(
      stream: marketBloc.indexStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Row(
          children: <Widget>[
            Container(
              width: anchoCategorias,
              child: CategoriasProducto(
                ancho: anchoCategorias,
                data: categorias,
              ),
            ),
            Container(
              width: anchoProductos,
              child: ProductosIdPage(
                ancho: anchoProductos,
                index: marketBloc.index,
              ),
            )
          ],
        );
      },
    );
  }
}

class CategoriasProducto extends StatefulWidget {
  final double ancho;
  final List<CategoriaData> data;

  const CategoriasProducto({Key key, @required this.ancho, @required this.data})
      : super(key: key);

  @override
  _CategoriasProductoState createState() => _CategoriasProductoState();
}

class _CategoriasProductoState extends State<CategoriasProducto> {
  @override
  Widget build(BuildContext context) {
    final productosIdBloc = ProviderBloc.prod(context);
    productosIdBloc.cargandoProductosFalse();
    productosIdBloc
        .obtenerProductosMarketPorCategoria(widget.data[0].idCategoria);

    return Scaffold(
      body: _listaCategorias(widget.data),
      /* _listaCategorias(categoriasBloc), */
    );
  }

  _listaCategorias(List<CategoriaData> categoriasBloc) {
    return Container(
        color: Colors.transparent,
        width: this.widget.ancho,
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: categoriasBloc.length,
            itemBuilder: (context, i) =>
                _listaItems(context, categoriasBloc[i])));
  }

  _listaItems(BuildContext context, CategoriaData categoria) {
    final size = MediaQuery.of(context).size;
    final responsive = Responsive.of(context);
    final marketBloc = ProviderBloc.market(context);
    final productosIdBloc = ProviderBloc.prod(context);

    return StreamBuilder(
        stream: marketBloc.indexStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return GestureDetector(
              child: Container(
                width: size.width * 0.25,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4)
                    ],
                    color: (categoria.idCategoria == snapshot.data)
                        ? Colors.red
                        : Colors.white,
                    border: Border.all(color: Colors.grey[100]),
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.person,
                              size: responsive.hp(5),
                            ),
                            Text(categoria.categoriaNombre,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: responsive.ip(1.3)),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                //setState(() {});
                marketBloc.changeIndexPage(categoria.idCategoria);

                /* productosIdBloc.cargandoProductosFalse();
                productosIdBloc
                    .obtenerProductosMarketPorCategoria(marketBloc.index); */
              });
        });
  }
}

class ProductosIdPage extends StatefulWidget {
  final double ancho;
  final String index;

  const ProductosIdPage({Key key, @required this.ancho, @required this.index})
      : super(key: key);

  @override
  _ProductosIdPageState createState() => _ProductosIdPageState();
}

class _ProductosIdPageState extends State<ProductosIdPage> {
  @override
  Widget build(BuildContext context) {
    //final _currenIndex = Provider.of<PaginacionCategoria>(context).currentIndex;
    final productosIdBloc = ProviderBloc.prod(context);
    productosIdBloc.obtenerProductosMarketPorCategoria(widget.index);

    return Scaffold(
      body: _listaProductosId(productosIdBloc),
    );
  }

  Widget _listaProductosId(ProductosBloc productosIdBloc) {
    return Container(
      color: Colors.transparent,
      width: this.widget.ancho,
      child: StreamBuilder(
        stream: productosIdBloc.productosMarketStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              final productos = snapshot.data;

              return ListView.builder(
                itemCount: productos.length,
                itemBuilder: (BuildContext context, int indexed) {
                  return _itemPedido(context, productos[indexed]);
                },
              );
            }
            return Center(
              child: Text('no hay productos en esta categoría'),
            );
          } else {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _itemPedido(BuildContext context, ProductosData productosData) {
    final Responsive responsive = new Responsive.of(context);

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
            color: Colors.white,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.symmetric(vertical: responsive.hp(0.5)),
        //height: responsive.hp(13),
        child: Row(
          children: <Widget>[
            Container(
              width: responsive.wp(28),
              height: responsive.hp(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  cacheManager: CustomCacheManager(),
                  placeholder: (context, url) => Image(
                      image: AssetImage('assets/jar-loading.gif'),
                      fit: BoxFit.cover),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  imageUrl: '${productosData.productoFoto}',
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                    )),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    productosData.productoNombre,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: responsive.ip(2),
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'S/ ${productosData.productoPrecio}',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.ip(2.5)),
                  ),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                (productosData.productoFavorito == 1)
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            utils.quitarFavoritos(
                              context, productosData);
                          });
                          
                        },
                        icon: Icon(
                          FontAwesomeIcons.solidHeart,
                          color: Colors.red,
                        ),
                      )
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            
                          utils.agregarFavoritos(context, productosData);
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.heart,
                          color: Colors.red,
                        ))
              ],
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.pushNamed(context, 'detalleP', arguments: productosData);
      },
    );
  }
}
