class HomeModel {
  String audioTitle;
  String audioUrl;
  String audioId;
  String? filePath;
  bool isDownloaded;
  bool isDownloading;

  HomeModel({
    required this.audioTitle,
    required this.audioId,
    required this.audioUrl,
    this.filePath,
    required this.isDownloaded,
    required this.isDownloading,
  });
}
