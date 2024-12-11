class Publication {
  String? pubId;
  String? title;
  String? katNo;
  String? pubNo;
  String? issn;
  String? abstract;
  String? schDate;
  String? rlDate;
  String? cover;
  String? pdf;
  String? size;
  List<Related>? related;

  Publication(
      {this.pubId,
      this.title,
      this.katNo,
      this.pubNo,
      this.issn,
      this.abstract,
      this.schDate,
      this.rlDate,
      this.cover,
      this.pdf,
      this.size,
      this.related});

  Publication.fromJson(Map<String, dynamic> json) {
    pubId = json['pub_id'];
    title = json['title'];
    katNo = json['kat_no'];
    pubNo = json['pub_no'];
    issn = json['issn'];
    abstract = json['abstract'];
    schDate = json['sch_date'];
    rlDate = json['rl_date'];
    cover = json['cover'];
    pdf = json['pdf'];
    size = json['size'];
    if (json['related'] != null) {
      related = <Related>[];
      json['related'].forEach((v) {
        related!.add(Related.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pub_id'] = pubId;
    data['title'] = title;
    data['kat_no'] = katNo;
    data['pub_no'] = pubNo;
    data['issn'] = issn;
    data['abstract'] = abstract;
    data['sch_date'] = schDate;
    data['rl_date'] = rlDate;
    data['cover'] = cover;
    data['pdf'] = pdf;
    data['size'] = size;
    if (related != null) {
      data['related'] = related!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Related {
  String? pubId;
  String? title;
  String? rlDate;
  String? url;
  String? cover;

  Related({this.pubId, this.title, this.rlDate, this.url, this.cover});

  Related.fromJson(Map<String, dynamic> json) {
    pubId = json['pub_id'];
    title = json['title'];
    rlDate = json['rl_date'];
    url = json['url'];
    cover = json['cover'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pub_id'] = pubId;
    data['title'] = title;
    data['rl_date'] = rlDate;
    data['url'] = url;
    data['cover'] = cover;
    return data;
  }
}
