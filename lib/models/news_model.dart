class News {
  int? newsId;
  String? newscatId;
  String? newscatName;
  String? title;
  String? news;
  String? rlDate;
  String? picture;

  News(
      {this.newsId,
      this.newscatId,
      this.newscatName,
      this.title,
      this.news,
      this.rlDate,
      this.picture});

  News.fromJson(Map<String, dynamic> json) {
    newsId = json['news_id'];
    newscatId = json['newscat_id'];
    newscatName = json['newscat_name'];
    title = json['title'];
    news = json['news'];
    rlDate = json['rl_date'];
    picture = json['picture'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['news_id'] = newsId;
    data['newscat_id'] = newscatId;
    data['newscat_name'] = newscatName;
    data['title'] = title;
    data['news'] = news;
    data['rl_date'] = rlDate;
    data['picture'] = picture;
    return data;
  }
}
