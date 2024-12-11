import 'dart:convert';

import 'package:bps_bintan/models/news_model.dart';
import 'package:bps_bintan/providers/setting_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:provider/provider.dart';

class NewsDetailPage extends StatefulWidget {
  final int newsId;
  const NewsDetailPage({super.key, required this.newsId});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  News? _newsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
  }

  Future<void> _fetchNewsData() async {
    final setting = Provider.of<SettingsProvider>(context, listen: false);
    String lang = setting.language == 'Indonesian' ? 'ind' : 'eng';
    final String url =
        'https://webapi.bps.go.id/v1/api/view/domain/2102/model/news/lang/$lang/id/${widget.newsId}/key/3c54cfd18f561c31311d53db76432c89/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _newsData = News.fromJson(data['data']);
          _isLoading = false;
        });
      } else {
        print(lang == 'ind'
            ? 'Gagal memuat data berita: ${response.statusCode}'
            : 'Failed to load news data: ${response.statusCode}');
      }
    } catch (e) {
      print(lang == 'ind'
          ? 'Terjadi kesalahan saat mengambil data: $e'
          : 'Error fetching news data: $e');
    }
  }

  String parseHtmlString(String htmlString) {
    // Decode HTML entities
    final unescape = HtmlUnescape();
    final decodedHtml = unescape.convert(htmlString);

    // Parse HTML menggunakan paket 'html'
    final document = html_parser.parse(decodedHtml);

    // Mengambil teks tanpa tag HTML
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final setting = Provider.of<SettingsProvider>(context, listen: false);
    String lang = setting.language == 'Indonesian' ? 'ind' : 'eng';

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'ind' ? 'Detail Berita' : 'Detail News'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _newsData != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: _newsData!.picture!,
                          height: 200,
                          width: 150,
                          progressIndicatorBuilder: (context, url, progress) {
                            return SizedBox(
                              width: 24,
                              height: 24,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return const Icon(
                              Icons.image,
                              size: 200,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        lang == 'ind'
                            ? _newsData!.title ?? 'Tidak ada judul'
                            : _newsData!.title ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        lang == 'ind'
                            ? 'Kategori: ${_newsData!.newscatName ?? 'Tidak ada Kategori'}'
                            : 'Category: ${_newsData!.newscatName ?? 'No Category'}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        lang == 'ind'
                            ? 'Tanggal Rilis: ${_newsData!.rlDate ?? 'Tidak ada tanggal'}'
                            : 'Release Date : ${_newsData!.rlDate ?? 'No Date'}',
                        style:
                            const TextStyle(fontSize: 16.0, color: Colors.grey),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        parseHtmlString(_newsData!.news!),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(lang == 'ind'
                      ? 'Data tidak ditemukan'
                      : 'Data not found'),
                ),
    );
  }
}
