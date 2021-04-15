import 'package:cached_network_image/cached_network_image.dart';
import 'package:enchiladasapp/src/bloc/provider.dart';
import 'package:enchiladasapp/src/models/categoria_model.dart';
import 'package:enchiladasapp/src/models/productos_model.dart';
import 'package:enchiladasapp/src/pages/AplicacionLocal/producto_foto_local.dart';
import 'package:enchiladasapp/src/search/search_local.dart';
import 'package:enchiladasapp/src/utils/responsive.dart';
import 'package:enchiladasapp/src/widgets/customCacheManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoriasPorTipoLocal extends StatefulWidget {


  const CategoriasPorTipoLocal({Key key,@required this.idCategoriaTipo,@required this.nombreCategoriaTipo}) : super(key: key);


  final String idCategoriaTipo;
  final String nombreCategoriaTipo;

  @override
  _CategoriasPorTipoLocalState createState() => _CategoriasPorTipoLocalState();
}

class _CategoriasPorTipoLocalState extends State<CategoriasPorTipoLocal> {
  final _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh(BuildContext context) async {
    print('_onRefresh');
    final categoriasBloc = ProviderBloc.cat(context);
    categoriasBloc.cargandoCategoriasFalse();
    categoriasBloc.obtenerCategoriasPorTipo(widget.idCategoriaTipo);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final categoriasBloc = ProviderBloc.cat(context);
    categoriasBloc.cargandoCategoriasFalse();
    categoriasBloc.obtenerCategoriasPorTipo(widget.idCategoriaTipo);

    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          height: double.infinity,
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
              /*  (widget.tipo == '2') ? 'Market 247' : 'Café 247', */
              widget.nombreCategoriaTipo,
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
                    delegate: SearchLocal(hintText: 'Buscar'),
                  );
                },
              )
            ],
          ),Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(13),
                  topStart: Radius.circular(13),
                ),
                color: Colors.grey[50],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.wp(3),
                vertical: responsive.hp(1),
              ),
              child: SmartRefresher(
                controller: _refreshController,
                onRefresh: () {
                  _onRefresh(context);
                },
                child: StreamBuilder(
                  stream: categoriasBloc.categoriasPorTipoStream,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length > 0) {
                        return _conte(anchoCategorias, anchoProductos,
                            snapshot.data, context);
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _conte(double anchoCategorias, double anchoProductos,
      List<CategoriaData> categorias, BuildContext context) {
    final bottomBloc = ProviderBloc.bottom(context);
    final enchiladasNaviBloc = ProviderBloc.enchiNavi(context);
    enchiladasNaviBloc.changeIndexPage(categorias[0].idCategoria);

    return StreamBuilder(
        stream: bottomBloc.selectPageStream,
        builder: (context, snapshot) {
          return StreamBuilder(
              stream: enchiladasNaviBloc.enchiladasIndexStream,
              builder: (context, snapshot) {
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
                        index: enchiladasNaviBloc.index,
                        ancho: anchoProductos,
                      ),
                    )
                  ],
                );
              });
        });
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
    final responsive = Responsive.of(context);
    return Scaffold(
      body: _listaCategorias(widget.data, responsive),
      /* _listaCategorias(categoriasBloc), */
    );
  }

  _listaCategorias(List<CategoriaData> categoriasBloc, Responsive responsive) {
    return Container(
      color: Colors.transparent,
      width: this.widget.ancho,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: categoriasBloc.length,
        itemBuilder: (context, i) => _listaItems(context, categoriasBloc[i]),
      ),
    );
  }

  _listaItems(BuildContext context, CategoriaData categoria) {
    final size = MediaQuery.of(context).size;
    final responsive = Responsive.of(context);
    final enchiladasNaviBloc = ProviderBloc.enchiNavi(context);

    return StreamBuilder(
        stream: enchiladasNaviBloc.enchiladasIndexStream,
        builder: (context, snapshot) {
          return GestureDetector(
              child: Container(
                width: size.width * 0.25,
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  color: (categoria.idCategoria == snapshot.data)
                      ? Colors.red
                      : Colors.white,
                  border: Border.all(color: Colors.grey[100]),
                  borderRadius: BorderRadius.circular(5),
                ),
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
                            Container(
                              height: responsive.ip(6),
                              width: responsive.ip(6),
                              child: SvgPicture.network(
                                '${categoria.categoriaIcono}',
                                semanticsLabel: 'A shark?!',
                                placeholderBuilder: (BuildContext context) =>
                                    Container(
                                        padding: const EdgeInsets.all(30.0),
                                        child:
                                            const CircularProgressIndicator()),
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: responsive.hp(1),
                            ),
                            Text(categoria.categoriaNombre,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: responsive.ip(1.5),
                                ),
                                textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                enchiladasNaviBloc.changeIndexPage(categoria.idCategoria);
                //Navigator.pushNamed(context, 'ProductosID',arguments: categoria);
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
    final responsive = Responsive.of(context);
    final productosIdBloc = ProviderBloc.prod(context);

    productosIdBloc.cargandoProductosFalse();
    productosIdBloc.obtenerProductosLocalEnchiladasPorCategoria(widget.index);

    return Scaffold(
      body: _listaProductosId(productosIdBloc, responsive),
    );
  }

  Widget _listaProductosId(
      ProductosBloc productosIdBloc, Responsive responsive) {
    return Container(
      color: Colors.transparent,
      width: this.widget.ancho,
      child: StreamBuilder(
        stream: productosIdBloc.productosEnchiladasStream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              final productos = snapshot.data;

              return ListView.builder(
                itemCount: productos.length,
                itemBuilder: (BuildContext context, int index) {
                  return _itemPedido(
                      context, productos[index], productos.length.toString());
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

  Widget _itemPedido(
      BuildContext context, ProductosData productosData, String cantidad) {
    final Responsive responsive = new Responsive.of(context);

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.symmetric(
          vertical: responsive.hp(0.5),
        ),
        //height: responsive.hp(13),
        child: Hero(
          tag: '${productosData.idProducto}',
          child: Container(
            width: responsive.ip(15),
            height: responsive.ip(20),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    cacheManager: CustomCacheManager(),
                    progressIndicatorBuilder: (_, url, downloadProgress) {
                      return Container(
                  width: double.infinity,
                  height: double.infinity,
                        child: Stack(
                          children: [
                            Center(
                              child: CircularProgressIndicator(
                                value: downloadProgress.progress,
                                backgroundColor: Colors.green,
                                valueColor:
                                    new AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            ),
                            Center(
                              child: (downloadProgress.progress != null)
                                  ? Text(
                                      '${(downloadProgress.progress * 100).toInt().toString()}%')
                                  : Container(),
                            )
                          ],
                        ),
                      );
                    },
                    errorWidget: (context, url, error) => Image(
                        image: AssetImage('assets/carga_fallida.jpg'),
                        fit: BoxFit.cover),
                    imageUrl: '${productosData.productoFoto}',
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
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.hp(2),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${productosData.productoNombre}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.ip(2),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) {
              return ProductoFotoLocal(
                  cantidadItems: cantidad,
                  idCategoria: productosData.idCategoria,
                  numeroItem: productosData.numeroitem);
              /*  return DetalleProductoFotoLocal(
                productosData: productosData,
                mostrarback: true, */
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
        //Navigator.pushNamed(context, 'detalleP', arguments: productosData);
      },
    );
  }
}
