import 'dart:convert';
import 'package:bps_bintan/models/publication_model.dart';
import 'package:bps_bintan/providers/setting_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicationDetailPage extends StatefulWidget {
  final String pubId;
  const PublicationDetailPage({super.key, required this.pubId});

  @override
  State<PublicationDetailPage> createState() => _PublicationDetailPageState();
}

class _PublicationDetailPageState extends State<PublicationDetailPage> {
  Publication? _pubData;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();

    _fetchPublicationData();
  }

  Future<void> _fetchPublicationData() async {
    final setting = Provider.of<SettingsProvider>(context, listen: false);
    String lang = setting.language == 'Indonesian' ? 'ind' : 'eng';
    final String url =
        'https://webapi.bps.go.id/v1/api/view/domain/2102/model/publication/lang/$lang/id/${widget.pubId}/key/3c54cfd18f561c31311d53db76432c89/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _pubData = Publication.fromJson(data['data']);
          _isLoading = false;
        });
      } else {
        print(lang == 'ind'
            ? 'Gagal memuat data publikasi: ${response.statusCode}'
            : 'Failed to load publication data: ${response.statusCode}');
      }
    } catch (e) {
      print(lang == 'ind'
          ? 'Terjadi kesalahan saat mengambil data publikasi: $e'
          : 'Error fetching publication data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final setting = Provider.of<SettingsProvider>(context);

    String lang = setting.language == 'Indonesian' ? 'ind' : 'eng';

    return Scaffold(
        appBar: AppBar(
          title:
              Text(lang == 'ind' ? 'Detail Publikasi' : 'Publication Detail'),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _pubData != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            clipBehavior: Clip.hardEdge,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: _pubData!.cover!,
                              height: 200,
                              width: 150,
                              progressIndicatorBuilder:
                                  (context, url, progress) {
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
                                  size: 150,
                                );
                              },
                            ),
                          ),
                          Text(
                            _pubData!.title!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(lang == 'ind'
                              ? 'No. Katalog: ${_pubData!.katNo}'
                              : 'No. Catalog: ${_pubData!.katNo}'),
                          Text(lang == 'ind'
                              ? 'No. Publikasi: ${_pubData!.pubNo}'
                              : 'No. Publication: ${_pubData!.pubNo}'),
                          Text('ISSN: ${_pubData!.issn!}'),
                          const SizedBox(height: 16),
                          Text(
                            lang == 'ind' ? 'Abstrak:' : 'Abstact:',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _pubData!.abstract!.replaceAll('\r\n', ' '),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _launchUrl(_pubData!.pdf!),
                            child: Text(lang == 'ind'
                                ? 'Unduh PDF (${_pubData!.size!})'
                                : 'Download PDF (${_pubData!.size!})'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            lang == 'ind'
                                ? 'Publikasi Terkait:'
                                : 'Related Publications:',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ..._pubData!.related!.map((relatedPub) {
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5)),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: relatedPub.cover!,
                                  width: 50,
                                  height: 50,
                                  progressIndicatorBuilder:
                                      (context, url, progress) {
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
                                      size: 50,
                                    );
                                  },
                                ),
                              ),

                              title: Text(relatedPub.title!),
                              subtitle: Text(lang == 'ind'
                                  ? 'Rilis: ${relatedPub.rlDate!}'
                                  : 'Release: ${relatedPub.rlDate}'),
                              // onTap: () => _launchUrl(relatedPub.url!),
                            );
                          }),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: Text('Data tidak ditemukan'),
                  ));
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}
