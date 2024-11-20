import 'package:flutter/material.dart';
import 'package:meditationapp/core/app_colors.dart';
import 'package:meditationapp/core/app_utils.dart';
import 'package:meditationapp/core/image_path.dart';
import 'package:meditationapp/core/theme/theme_manager.dart';
import 'package:meditationapp/feature/home/view/music_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> imageList = [
    image1Path,
    image2Path,
    image3Path,
    image1Path,
    image2Path,
    image3Path
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: getScaffoldColor(),
      appBar: AppBar(
        surfaceTintColor: getScaffoldColor(),
        backgroundColor: getScaffoldColor(),
        centerTitle: true,
        leading:  Icon(
          Icons.menu,
          color: getTextColor(),
        ),
        title: Image.asset(
          "assets/logo_light.png",
          height: 32,
          width: 32,
          color: getLogoColor(),

        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Image.asset(
              "assets/tip_icon.png",
              width: 26,
              height: 26,
              color:   getTipIconColor()
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ListView for images
          Expanded(
            child: ListView.builder(
              itemCount: imageList.length,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MusicListScreen(),));
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: index ==  imageList.length - 1 ? 0: 16, left: 12, right: 12
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      color: Colors.grey,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: Image.asset(
                        imageList[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom container (fixed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10,bottom: 10,left: 10,right: 10),
            decoration:  BoxDecoration(
              color: getBottomCountContainerColor(),

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [
             bottomCustomRow(105.toString(), "Min of Meditation"),
             bottomCustomRow(20.toString(), "Session Completed"),
             bottomCustomRow(10.toString(), "Days of Meditation"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomCustomRow(String? number,String? text){
    return  Row(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 5,left: 8,right: 8,bottom: 5),
          decoration:  BoxDecoration(
              color: getBottomRowContainerColor(),
              borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          child:  AppUtils.commonTextWidget(text: number,fontWeight: FontWeight.bold,fontSize: 16,textColor: getTextColor(),),
        ),
        Container(
          // height: 28,
          width: 80,
          padding: const EdgeInsets.only(top: 5,left: 8,right: 8,bottom: 5),
            child:  AppUtils.commonTextWidget(text: text,fontWeight: FontWeight.w500,fontSize: 12,textColor: AppColors.blackColor,overflow: TextOverflow.visible)
        ),
      ],
    );
  }
}
