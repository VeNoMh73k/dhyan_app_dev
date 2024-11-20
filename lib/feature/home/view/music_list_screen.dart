import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/image_path.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [

          SliverAppBar(
            pinned: true, // Keep the app bar pinned
            snap: false,
            toolbarHeight: 130,
            leading: Icon(
              Icons.arrow_back,
              color: AppColors.whiteColor,
            ),
            expandedHeight: height / 3,
            automaticallyImplyLeading: false,
            surfaceTintColor: AppColors.whiteColor,
            floating: true,
            collapsedHeight: 130,
            flexibleSpace: FlexibleSpaceBar(

              // background: Image.asset( image4Path,
              //   fit: BoxFit.cover,
              // ),
              // collapseMode: CollapseMode.parallax,
              titlePadding: EdgeInsets.zero,
               title: Stack(
                 children: [
                   // Background Image
                   Container(
                     height: height / 2,
                     decoration: const BoxDecoration(
                       borderRadius: BorderRadius.only(
                         bottomRight: Radius.circular(18),
                         bottomLeft: Radius.circular(18),
                       ),
                     ),
                     child: ClipRRect(
                       borderRadius: const BorderRadius.only(
                         bottomRight: Radius.circular(18),
                         bottomLeft: Radius.circular(18),
                       ),
                       child: Image.asset(  image4Path,
                         fit: innerBoxIsScrolled  ? BoxFit.fill :  BoxFit.cover,
                       ),
                     ),
                   ),
                   // Overlaying text and icons
                   Align(
                     alignment: Alignment.bottomLeft,
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Container(
                           margin: const EdgeInsets.only(left: 12, bottom: 14),
                           child: AppUtils.commonTextWidget(
                             text: "Spiritual",
                             textColor: AppColors.whiteColor,
                             fontWeight: FontWeight.w800,
                             fontSize: 14,
                             letterSpacing: 1,
                           ),
                         ),
                         Container(
                           margin: const EdgeInsets.only(left: 12, bottom: 14, right: 12),
                           decoration: BoxDecoration(
                             color: Colors.transparent,
                             border: Border.all(color: AppColors.whiteColor),
                             borderRadius: const BorderRadius.all(Radius.circular(4)),
                           ),
                           padding: const EdgeInsets.all(4),
                           child: Icon(
                             Icons.sort,
                             color: AppColors.whiteColor,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
              // background: Stack(
              //   children: [
              //     // Background Image
              //     Container(
              //       height: height / 2,
              //       decoration: const BoxDecoration(
              //         borderRadius: BorderRadius.only(
              //           bottomRight: Radius.circular(18),
              //           bottomLeft: Radius.circular(18),
              //         ),
              //       ),
              //       child: ClipRRect(
              //         borderRadius: const BorderRadius.only(
              //           bottomRight: Radius.circular(18),
              //           bottomLeft: Radius.circular(18),
              //         ),
              //         child: Image.asset(
              //           image3Path,
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //     ),
              //     // Overlaying text and icons
              //     Align(
              //       alignment: Alignment.bottomLeft,
              //       child: Row(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Container(
              //             margin: const EdgeInsets.only(left: 12, bottom: 14),
              //             child: AppUtils.commonTextWidget(
              //               text: "Spiritual",
              //               textColor: AppColors.whiteColor,
              //               fontWeight: FontWeight.w800,
              //               fontSize: 18,
              //               letterSpacing: 1,
              //             ),
              //           ),
              //           Container(
              //             margin: const EdgeInsets.only(left: 12, bottom: 14, right: 12),
              //             decoration: BoxDecoration(
              //               color: Colors.transparent,
              //               border: Border.all(color: AppColors.whiteColor),
              //               borderRadius: const BorderRadius.all(Radius.circular(4)),
              //             ),
              //             padding: const EdgeInsets.all(8),
              //             child: Icon(
              //               Icons.sort,
              //               color: AppColors.whiteColor,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ),
          ),

        ],
        body: ListView.builder(
          itemCount: 10,
          padding: EdgeInsets.symmetric(horizontal: 14,vertical: 12),
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12),child: Image.asset(image1Path,fit: BoxFit.cover,height: 140,width: 110,)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: getTipIconColor(),
                          borderRadius: BorderRadius.all(Radius.circular(4))
                        ),
                        child: Icon(Icons.play_arrow_rounded,color: AppColors.blackColor,size: 32,),
                      ),
                      Icon(Icons.favorite,color: AppColors.primaryColor,size: 32,)
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
