class AudioListModel {
  String? title;
  String? description;
  String? imgUrl;
  String? audioUrl;
  String? filePath;
  bool? isDownloaded;
  bool? isDownloading;

  AudioListModel(
      {this.title,
      this.description,
      this.imgUrl,
      this.audioUrl,
      this.filePath,
      this.isDownloaded,
      this.isDownloading});

  AudioListModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    imgUrl = json['imgUrl'];
    audioUrl = json['audioUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['description'] = this.description;
    data['imgUrl'] = this.imgUrl;
    data['audioUrl'] = this.audioUrl;
    return data;
  }
}
