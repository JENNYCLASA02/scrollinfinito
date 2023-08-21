import 'package:flutter/material.dart';
import 'package:gyphi/Models/ModeloGif.dart';
import 'package:gyphi/Providers/Gif_Provider.dart';

class GifPage extends StatefulWidget {
  const GifPage({Key? key}) : super(key: key);

  @override
  State<GifPage> createState() => _GifPageState();
}

class _GifPageState extends State<GifPage> {
  final gifsprovider = GifProvider();
  late Future<List<ModeloGif>> _listadoGifs;
  List<ModeloGif> _loadedGifs = []; // Lista de gifs cargados
  ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listadoGifs = gifsprovider.getGifs();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreGifs();
    }
  }

  Future<void> _loadMoreGifs() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
      await Future.delayed(Duration(seconds: 2));

      List<ModeloGif> newGifs = await gifsprovider.getGifs(); // Cargar más gifs
      setState(() {
        _loadedGifs.addAll(newGifs);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: FutureBuilder(
            future: _listadoGifs,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _loadedGifs = snapshot.data as List<ModeloGif>;
                return GridView.builder(
                  controller: _scrollController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: _loadedGifs.length + 1,
                  itemBuilder: (context, index) {
                    if (index < _loadedGifs.length) {
                      final gif = _loadedGifs[index];
                      final String url = gif.images?.downsized?.url as String;
                      return Card(
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Image.network(
                                url,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return _isLoading
                          ? Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : SizedBox();
                    }
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
