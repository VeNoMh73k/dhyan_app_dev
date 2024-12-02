class GetAllCategoryAndTracks {
  List<Categories>? categories;
  List<Tracks>? tracks;

  GetAllCategoryAndTracks({this.categories, this.tracks});

  GetAllCategoryAndTracks.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(new Categories.fromJson(v));
      });
    }
    if (json['tracks'] != null) {
      tracks = <Tracks>[];
      json['tracks'].forEach((v) {
        tracks!.add(new Tracks.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    if (this.tracks != null) {
      data['tracks'] = this.tracks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  int? id;
  String? title;
  String? imageUrl;
  String? bannerImageUrl;
  String? createdAt;
  List<int>? trackIds;

  Categories(
      {this.id,
        this.title,
        this.imageUrl,
        this.bannerImageUrl,
        this.createdAt,
        this.trackIds});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    imageUrl = json['image_url'];
    bannerImageUrl = json['banner_image_url'];
    createdAt = json['created_at'];
    trackIds = json['track_ids'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['image_url'] = this.imageUrl;
    data['banner_image_url'] = this.bannerImageUrl;
    data['created_at'] = this.createdAt;
    data['track_ids'] = this.trackIds;
    return data;
  }
}

class Tracks {
  int? id;
  String? title;
  String? description;
  int? duration;
  String? tag;
  String? imageUrl;
  String? trackUrl;
  bool? isPaid;
  String? createdAt;
  bool? isDownloaded;
  bool? isFav;
  String? filePath;
  bool? isDownloading;
  List<int>? categoryIds;
  int? downloadProgress;

  Tracks(
      {this.id,
        this.title,
        this.description,
        this.duration,
        this.tag,
        this.imageUrl,
        this.trackUrl,
        this.isPaid,
        this.createdAt,
        this.isDownloaded,
        this.isFav,
        this.filePath,
        this.isDownloading,
        this.categoryIds,
        this.downloadProgress
      });

  Tracks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    duration = json['duration'];
    tag = json['tag'];
    imageUrl = json['image_url'];
    trackUrl = json['track_url'];
    isPaid = json['is_paid'];
    createdAt = json['created_at'];
    isDownloaded = json['isDownloaded'];
    isFav = json['isFav'];
    filePath = json['filePath'];
    isDownloading = json['isDownloading'];
    categoryIds = json['category_ids'].cast<int>();
    downloadProgress = json['downloadProgress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['duration'] = this.duration;
    data['tag'] = this.tag;
    data['image_url'] = this.imageUrl;
    data['track_url'] = this.trackUrl;
    data['is_paid'] = this.isPaid;
    data['created_at'] = this.createdAt;
    data['isDownloaded'] = this.isDownloaded;
    data['isFav'] = this.isFav;
    data['filePath'] = this.filePath;
    data['isDownloading'] = this.isDownloading;
    data['category_ids'] = this.categoryIds;
    data['downloadProgress'] = this.downloadProgress;

    return data;
  }
}
