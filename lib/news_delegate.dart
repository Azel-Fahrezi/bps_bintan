import 'dart:convert';
import 'package:bps_bintan/models/news_model.dart';
import 'package:bps_bintan/news_detail_page.dart';
import 'package:bps_bintan/providers/setting_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NewsSearchDelegate1 extends SearchDelegate {
  final BuildContext context;

  NewsSearchDelegate1(this.context)
      : super(
          searchFieldLabel:
              Provider.of<SettingsProvider>(context, listen: false).language ==
                      'Indonesian'
                  ? 'Cari berita...'
                  : 'Search for news...',
        );
  Future<List<dynamic>> fetchNews(String query, int page) async {
    final String apiUrl =
        'https://webapi.bps.go.id/v1/api/list/model/news/lang/ind/domain/2102/keyword/$query/key/3c54cfd18f561c31311d53db76432c89/?page=$page';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'][1] ?? [];
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    return NewsResults(query: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final setting = Provider.of<SettingsProvider>(context, listen: false);
    String lang = setting.language == 'Indonesian' ? 'ind' : 'eng';
    if (query.isEmpty) {
      return Center(
          child: Text(lang == 'ind'
              ? 'Masukkan kata kunci untuk mencari berita.'
              : 'Enter keywords to search for news.'));
    } else {
      return buildResults(context);
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }
}

class NewsResults extends StatefulWidget {
  final String query;

  const NewsResults({super.key, required this.query});

  @override
  State<NewsResults> createState() => _NewsResultsState();
}

class _NewsResultsState extends State<NewsResults> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _news = [];
  int _page = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNews(widget.query, _page);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant NewsResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _refreshNews();
    }
  }

  Future<void> _refreshNews() async {
    setState(() {
      _page = 1;
      _news.clear();
      fetchNews(widget.query, _page);
    });
  }

  Future<List<dynamic>> fetchNews(String query, int page) async {
    final setting = Provider.of<SettingsProvider>(context, listen: false);
    String lang = setting.language == 'Indonesian' ? 'ind' : 'eng';
    final String apiUrl =
        'https://webapi.bps.go.id/v1/api/list/model/news/lang/$lang/domain/2102/keyword/$query/key/3c54cfd18f561c31311d53db76432c89/?page=$page';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['data'] != "") {
        List<dynamic> data = jsonDecode(response.body)['data'][1];

        List<News> news = data.map((e) => News.fromJson(e)).toList();
        return news;
      } else {
        return [];
      }
    } else {
      throw Exception(
          lang == 'ind' ? 'Gagal menuat data berita' : 'Failed to load news');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() {
      _isLoading = true;
      _page++;
    });

    fetchNews(widget.query, _page).then((newItems) {
      setState(() {
        _isLoading = false;
        _news.addAll(newItems);
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchNews(widget.query, _page),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _news.isEmpty) {
          return Skeletonizer(
              effect: ShimmerEffect(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                duration: const Duration(seconds: 1),
              ),
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Bone.square(
                        size: 48,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      title: const Bone.text(
                        borderRadius: BorderRadius.all(
                          Radius.circular(2),
                        ),
                      ),
                      subtitle: const Bone.text(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 5),
                  itemCount: 10));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          if (snapshot.hasData && snapshot.data!.isNotEmpty && _news.isEmpty) {
            _news.addAll(snapshot.data!);
          }

          return RefreshIndicator(
            onRefresh: _refreshNews,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _news.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _news.length) {
                  News news = _news[index];

                  return ListTile(
                    leading: ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      child: CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: news.picture!,
                        width: 48,
                        progressIndicatorBuilder: (context, url, progress) {
                          return Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                value: progress.progress,
                              ),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const Icon(
                            Icons.image,
                            size: 48,
                          );
                        },
                      ),
                    ),
                    title: Text(
                      news.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(news.newscatName!),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailPage(newsId: news.newsId!)));
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          );
        }
      },
    );
  }
}
