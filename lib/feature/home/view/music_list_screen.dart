import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/storage/preference_helper.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/home/models/get_all_category_and_track.dart';
import 'package:meditationapp/feature/home/provider/home_provider.dart';
import 'package:meditationapp/feature/home/view/audio_player_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class MusicListScreen extends StatefulWidget {
  int? categoryId;
  String? categoryName;
  List<int>? trackId;
  String? bannerImageUrl;

  MusicListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.trackId,
    this.bannerImageUrl,
  });

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  late ScrollController _scrollController;
  final ValueNotifier<bool> _showAppBarTitle = ValueNotifier(false);
  String? selectedOption;
  late HomeProvider homeProvider;
  List<Tracks> filteredList = [];
  bool? isLoading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      homeProvider = Provider.of<HomeProvider>(context, listen: false);

      getTracksAccordingToCategoryId();
      loadDownloadedData();
      homeProvider.freshProgress();
      selectedOption = options.first;
      sortList(selectedOption ?? '');
    });
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  getTracksAccordingToCategoryId() {
    setState(() {
      isLoading = true;
    });
    widget.trackId?.forEach(
      (trackId) {
        for (var track in homeProvider.tracks) {
          if (track.id == trackId) {
            filteredList.add(track);
          }
        }
      },
    );

    setState(() {
      isLoading = false;
    });
  }

  // Method to handle downloading audio
  Future<void> callDownloadAudioApi(
      HomeProvider provider, String audioUrl) async {
    setState(() {
      filteredList
          .firstWhere((element) => element.trackUrl == audioUrl)
          .isDownloading = true;
    });

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${audioUrl.hashCode}_cached_audio.mp3';

    provider.downloadAudio(context, audioUrl, filePath).then((value) async {
      setState(() {
        if (value) {
          final track = filteredList
              .firstWhere((element) => element.trackUrl == audioUrl);
          track.isDownloaded = true;
          track.filePath = filePath;
          saveDownloadedData(audioUrl, filePath); // Save to SharedPreferences
        }
        filteredList
            .firstWhere((element) => element.trackUrl == audioUrl)
            .isDownloading = false;
      });
    }).catchError((error) {
      setState(() {
        filteredList
            .firstWhere((element) => element.trackUrl == audioUrl)
            .isDownloading = false;
      });
      AppUtils.snackBarFnc(
          ctx: context, contentText: "Download Failed. Please try again.");
    });
  }

  // Save download data to SharedPreferences
  Future<void> saveDownloadedData(String audioUrl, String filePath) async {
    Map<String, String> downloads = {};

    // Load existing data
    if (PreferenceHelper.containsKey('downloadedFiles')) {
      downloads = Map<String, String>.from(
          jsonDecode(PreferenceHelper.getString('downloadedFiles')!));
    }

    // Update data
    downloads[audioUrl] = filePath;

    // Save back to SharedPreferences
    await PreferenceHelper.setString('downloadedFiles', jsonEncode(downloads));
  }

  // Load persisted download data
  Future<void> loadDownloadedData() async {
    if (PreferenceHelper.containsKey('downloadedFiles')) {
      final downloads = Map<String, String>.from(
          jsonDecode(PreferenceHelper.getString('downloadedFiles')!));
      setState(() {
        for (var track in filteredList) {
          if (downloads.containsKey(track.trackUrl)) {
            track.isDownloaded = true;
            track.filePath = downloads[track.trackUrl]!;
          }
        }
      });
    }
    loadFavorites();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    filteredList.clear();
    homeProvider.freshProgress();
    super.dispose();
  }

  void _handleScroll() {
    // Show title when scrolled past a certain point (e.g., 150)
    if (_scrollController.offset > 150 && !_showAppBarTitle.value) {
      _showAppBarTitle.value = true;
    } else if (_scrollController.offset <= 150 && _showAppBarTitle.value) {
      _showAppBarTitle.value = false;
    }
  }

  void toggleFavorite(int index) async {
    final key =
        'isFav_${filteredList[index].id}'; // Use unique ID for each item
    final newValue = !(filteredList[index].isFav ?? false);

    setState(() {
      filteredList[index].isFav = newValue; // Update state
    });

    await PreferenceHelper.setBool(key, newValue); // Save to SharedPreferences
  }

  Future<void> loadFavorites() async {
    setState(() {
      for (var item in filteredList) {
        final key = 'isFav_${item.id}';
        item.isFav = PreferenceHelper.getBool(key); // Default to false
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      backgroundColor: getScaffoldColor(),
      body: isLoading == true
          ? AppUtils.loaderWidget()
          : CustomScrollView(
              controller: _scrollController,
              slivers: [
                ValueListenableBuilder(
                  valueListenable: _showAppBarTitle,
                  builder: (context, value, child) {
                    return SliverAppBar(
                      expandedHeight: height / 3,
                      collapsedHeight: 60,
                      stretch: true,
                      pinned: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      automaticallyImplyLeading: false,
                      backgroundColor: getTipIconColor(),
                      flexibleSpace: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        child: FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          titlePadding: const EdgeInsetsDirectional.only(
                            start: 0.0,
                            bottom: 16.0,
                          ),
                          // centerTitle: _showAppBarTitle ?  true : false,
                          title: _showAppBarTitle.value
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: AppUtils.backButton(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),

                                    // GestureDetector(
                                    //   onTap: () {
                                    //     Navigator.pop(context);
                                    //   },
                                    //   child: Container(
                                    //     margin: const EdgeInsets.only(
                                    //         left: 12, bottom: 0, right: 0),
                                    //     padding: const EdgeInsets.all(4),
                                    //     child: Icon(
                                    //       Icons.arrow_back,
                                    //       color: AppColors.whiteColor,
                                    //     ),
                                    //   ),
                                    // ),
                                    AppUtils.commonTextWidget(
                                        text:
                                            widget.categoryName ?? "Spiritual",
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        textColor: AppColors.whiteColor),
                                    GestureDetector(
                                      onTap: () {
                                        showSortMenu(context, selectedOption,
                                            (String newSelection) {
                                          setState(() {
                                            selectedOption = newSelection;
                                          });
                                          print(
                                              'Selected option: $selectedOption');
                                        }, true);
                                      },
                                      child: AppUtils.commonContainer(
                                        margin: const EdgeInsets.only(
                                            left: 0, bottom: 0, right: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                              color: AppColors.whiteColor),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(4)),
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.sort,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : null, // Show title only when _showAppBarTitle is true
                          background: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            child: Stack(
                              children: [
                                // Background image filling the entire area
                                Positioned.fill(
                                  child: AppUtils.cacheImage(
                                    imageUrl: widget.bannerImageUrl ?? "",
                                  ),
                                ),
                                // Back arrow icon at the top center
                                _showAppBarTitle.value
                                    ? SizedBox()
                                    : Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 32, left: 12),
                                            child: AppUtils.backButton(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                            )), /*GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 32, left: 12),
                                            // Adjust as needed for spacing
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.arrow_back,
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
                                        ),*/
                                      ),
                                // "Spiritual" text and sort icon at the bottom
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // "Spiritual" text
                                        AppUtils.commonTextWidget(
                                          text: widget.categoryName ??
                                              "Spiritual",
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          textColor: AppColors.whiteColor,
                                        ),
                                        // Sort icon with border
                                        GestureDetector(
                                          onTap: () {
                                            showSortMenu(
                                                context, selectedOption,
                                                (String newSelection) {
                                              setState(() {
                                                selectedOption = newSelection;
                                              });
                                              print(
                                                  'Selected option: $selectedOption');
                                            }, false);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                  color: AppColors.whiteColor),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.sort,
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        margin:
                            EdgeInsets.only(left: 16, right: 16, bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: getMusicListTileColor(),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: getMusicTileColorWithOpacity(),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail Image
                            ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: AppUtils.cacheImage(
                                  imageUrl: filteredList[index].imageUrl ?? "",
                                  width: 110,
                                  height: 125,
                                  fit: BoxFit.cover,
                                )),
                            const SizedBox(
                                width: 12), // Space between image and text

                            // Text and Action Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Title and Action Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title and Subtitle
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AppUtils.commonTextWidget(
                                              text: filteredList[index].title ??
                                                  "",
                                              textColor: getTextColor(),
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              maxLines: 2,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                AppUtils.commonContainer(
                                                  height: 5,
                                                  width: 5,
                                                  decoration: AppUtils
                                                      .commonBoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        AppColors.darkGreyColor,
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                AppUtils.commonTextWidget(
                                                  text:
                                                      '${filteredList[index].duration} Min',
                                                  textColor:
                                                      AppColors.darkGreyColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                SizedBox(width: 5),
                                                AppUtils.commonContainer(
                                                  height: 5,
                                                  width: 5,
                                                  decoration: AppUtils
                                                      .commonBoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: getTipIconColor(),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                AppUtils.commonTextWidget(
                                                  text: filteredList[index].tag,
                                                  textColor: getTipIconColor(),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Space before action button

                                      GestureDetector(
                                        onTap: () {
                                          if (filteredList[index]
                                                  .isDownloaded ??
                                              false) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AudioPlayerPage(
                                                    audioDescription:
                                                        filteredList[index]
                                                                .description ??
                                                            '',
                                                    trackId: filteredList[index]
                                                        .id
                                                        .toString(),
                                                    minutes: int.parse(
                                                        filteredList[index]
                                                            .duration
                                                            .toString()),
                                                    imgUrl: filteredList[index]
                                                            .imageUrl ??
                                                        '',
                                                    audioTitle:
                                                        filteredList[index]
                                                                .title ??
                                                            '',
                                                    filePath:
                                                        filteredList[index]
                                                                .filePath ??
                                                            '',
                                                  ),
                                                ));
                                          } else {
                                            callDownloadAudioApi(
                                                homeProvider,
                                                filteredList[index].trackUrl ??
                                                    '');
                                          }
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          // padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: getTipIconColor(),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(4)),
                                          ),
                                          child: filteredList[index]
                                                      .isDownloading ??
                                                  false
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Center(
                                                    child: AppUtils
                                                        .commonTextWidget(
                                                      text:
                                                          "${homeProvider.progress.toStringAsFixed(0).padLeft(2, '0')}%",
                                                      textColor: getTextColor(),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                )
                                              : Icon(
                                                  filteredList[index]
                                                              .isDownloaded ??
                                                          false
                                                      ? Icons.play_arrow_rounded
                                                      : Icons
                                                          .arrow_downward_rounded,
                                                  color: AppColors.blackColor,
                                                  size: filteredList[index]
                                                              .isDownloaded ??
                                                          false
                                                      ? 32
                                                      : 28,
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),

                                  // Description Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Description text
                                      Expanded(
                                        child: AppUtils.commonTextWidget(
                                          text:
                                              filteredList[index].description ??
                                                  '',
                                          fontSize: 14,
                                          textColor: getTextColor(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          toggleFavorite(index);
                                        },
                                        child: Icon(
                                          Icons.favorite,
                                          color:
                                              filteredList[index].isFav ?? false
                                                  ? getPrimaryColor()
                                                  : AppColors.darkGreyColor,
                                          size: 26,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount:
                        filteredList.length, // Adjust as per your requirement
                  ),
                ),
              ],
            ),
    );
  }

  List<String> options = [
    'A to Z',
    'Shortest First',
    'Downloaded First',
    'Favorites First'
  ];

  void showSortMenu(BuildContext context, String? selectedOption,
      Function(String) onOptionSelected, bool? isFromTopAppBar) {
    showMenu<String>(
      context: context,
      position: isFromTopAppBar ?? false
          ? const RelativeRect.fromLTRB(200, 80, 15, 0)
          : const RelativeRect.fromLTRB(200, 315, 15, 0),
      color: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: options.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: AppUtils.commonTextWidget(
                text: option,
                textColor: getTextColor(),
                fontSize: 16,
                fontWeight: FontWeight.w400),
            value: option,
            groupValue: selectedOption,
            activeColor: getPrimaryColor(),
            onChanged: (value) {
              Navigator.of(context).pop(value);
            },
          ),
        );
      }).toList(),
    ).then((selectedValue) {
      if (selectedValue != null) {
        onOptionSelected(selectedValue);
        sortList(selectedValue);
      }
    });
  }

  void sortList(String selectedOption) {
    setState(() {
      if (selectedOption == 'A to Z') {
        filteredList.sort((a, b) => a.title!.compareTo(b.title!));
      } else if (selectedOption == 'Shortest First') {
        filteredList.sort((a, b) => a.duration!.compareTo(b.duration!));
      } else if (selectedOption == 'Downloaded First') {
        filteredList.sort((a, b) => (b.isDownloaded ?? false ? 1 : 0)
            .compareTo(a.isDownloaded ?? false ? 1 : 0));
      } else if (selectedOption == 'Favorites First') {
        filteredList
            .sort((a, b) => (b.isFav! ? 1 : 0).compareTo(a.isFav! ? 1 : 0));
      }
    });
  }
}
