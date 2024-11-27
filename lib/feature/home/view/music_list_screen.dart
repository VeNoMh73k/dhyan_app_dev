import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
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
  String? imageUrl;

  MusicListScreen(
      {super.key,
      this.categoryId,
      this.categoryName,
      this.trackId,
      this.imageUrl});

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

  callDownloadAudioApi(HomeProvider provider, String audioUrl) async {
    setState(() {
      // Mark the track as downloading
      filteredList
          .firstWhere((element) => element.trackUrl == audioUrl)
          .isDownloading = true;
    });

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${audioUrl.hashCode}_cached_audio.mp3';

    provider.downloadAudio(context, audioUrl, filePath).then((value) {
      setState(() {
        if (value) {
          filteredList
              .firstWhere((element) => element.trackUrl == audioUrl)
              .isDownloaded = true;
          filteredList
              .firstWhere((element) => element.trackUrl == audioUrl)
              .filePath = filePath;
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
      // Optionally show an error message
      AppUtils.snackBarFnc(ctx: context,contentText: "Download Failed. Please try again.");
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    filteredList.clear();
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
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 12, bottom: 0, right: 0),
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ),
                                    AppUtils.commonTextWidget(
                                        text:
                                            widget.categoryName ?? "Spiritual",
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        textColor: AppColors.whiteColor),
                                    Container(
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
                                  child: AppUtils.networkImage(
                                    imageUrl: widget.imageUrl ?? "",
                                  ),
                                ),
                                // Back arrow icon at the top center
                                _showAppBarTitle.value
                                    ? SizedBox()
                                    : Align(
                                        alignment: Alignment.topLeft,
                                        child: GestureDetector(
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
                                        ),
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
                                              context,
                                              selectedOption,
                                              (String newSelection) {
                                                setState(() {
                                                  selectedOption = newSelection;
                                                });
                                                print(
                                                    'Selected option: $selectedOption');
                                              },
                                            );
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
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
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
                                borderRadius: BorderRadius.circular(12),
                                child: AppUtils.networkImage(
                                  imageUrl: filteredList[index].imageUrl ?? "",
                                  width: 110,
                                  height: 140,
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
                                                SizedBox(width: 5),
                                                AppUtils.commonTextWidget(
                                                  text: 'Female Voice',
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
                                          padding: EdgeInsets.all(4),
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
                                                      const EdgeInsets.all(2),
                                                  child:
                                                      AppUtils.loaderWidget(),
                                                )
                                              : Icon(
                                                  filteredList[index]
                                                              .isDownloaded ??
                                                          false
                                                      ? Icons.play_arrow_rounded
                                                      : Icons.add_rounded,
                                                  color: AppColors.blackColor,
                                                  size: 32,
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
                                        child: Text(
                                          filteredList[index].description ?? '',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: getTextColor(),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            filteredList[index].isFav =
                                                !(filteredList[index].isFav ??
                                                    false);
                                          });
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

  void showSortMenu(BuildContext context, String? selectedOption,
      Function(String) onOptionSelected) {
    const List<String> options = [
      'A to Z',
      'Shortest First',
      'Downloaded First',
      'Favorites First'
    ];

    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 315, 15, 0),
      color: getScaffoldColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      items: options.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(option),
            value: option,
            groupValue: selectedOption,
            // Tracks the current selection.
            activeColor: getPrimaryColor(),
            onChanged: (value) {
              Navigator.of(context).pop(value); // Close menu and return value.
            },
          ),
        );
      }).toList(),
    ).then((selectedValue) {
      if (selectedValue != null) {
        onOptionSelected(selectedValue); // Notify about the selected option.
      }
    });
  }
}
