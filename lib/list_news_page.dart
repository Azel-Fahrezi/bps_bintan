import 'dart:convert';
import 'package:bps_bintan/models/news_model.dart';
import 'package:bps_bintan/news_detail_page.dart';
import 'package:bps_bintan/providers/setting_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ListNewsPage extends StatefulWidget {
  const ListNewsPage({super.key});

  @override
  State<ListNewsPage> createState() => _ListNewsPageState();
}

class _ListNewsPageState extends State<ListNewsPage> {
  final ScrollController _scrollController = ScrollController();
  final List<News> _data = []; // Data yang akan ditampilkan
  int _currentPage = 1; // Halaman saat ini
  bool _isLoading = false; // Untuk mencegah pemuatan ganda

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchData1(); // Memuat data awal
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData1() async {
    final setting = Provider.of<SettingsProvider>(context, listen: false);
    String lang = setting.language == 'Indonesian' ? 'ind' : 'eng';
    final String url =
        'https://webapi.bps.go.id/v1/api/list/model/news/lang/$lang/domain/2102/key/3c54cfd18f561c31311d53db76432c89/page/$_currentPage';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['data'] != "") {
        List<dynamic> data = jsonDecode(response.body)['data'][1];
        List<News> news = data.map((e) => News.fromJson(e)).toList();
        setState(() {
          _data.addAll(news);
          _isLoading = false;
        });
      }
    } else {
      throw Exception(lang == 'ind'
          ? 'Gagal memuat data: ${response.statusCode}'
          : 'Failed to load data: ${response.statusCode}');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchData1(); // Memuat data saat mencapai bagian bawah
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _currentPage = 1;
      _data.clear();
    });
    await _fetchData1();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading || _data.isEmpty
          ? Skeletonizer(
              effect: ShimmerEffect(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                duration: const Duration(seconds: 1),
              ),
              child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 2,
                      ),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      child: ListTile(
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
                      ),
                    );
                  },
                  itemCount: 10))
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(10),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 2,
                ),
                controller: _scrollController,
                itemCount: _data.length + 1, // Tambahkan 1 untuk loader
                itemBuilder: (context, index) {
                  if (index == _data.length) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  News newsItem = _data[index];

                  return Card(
                    elevation: 5,
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailPage(newsId: newsItem.newsId!),
                            ));
                      },
                      leading: ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: newsItem.picture!,
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
                        newsItem.title!,
                        maxLines: 2,
                      ),
                      subtitle: Text(newsItem.newscatName!),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
