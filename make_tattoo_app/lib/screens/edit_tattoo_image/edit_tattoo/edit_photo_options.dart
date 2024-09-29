import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:make_tattoo_app/utils/style_config.dart';

class EditPhotoOptions extends StatelessWidget {
  final bool showEditPhotoOptions;
  final VoidCallback onCancel;

  const EditPhotoOptions({
    Key? key,
    required this.showEditPhotoOptions,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showEditPhotoOptions) {
      return const SizedBox.shrink();
    }
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            height: MediaQuery.of(context).size.height * 0.18,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Edit photo".tr,
                          style: TextStyle(color: iconColor, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: iconColor),
                        onPressed: onCancel,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: const Color.fromARGB(255, 54, 53, 53),
                  height: 1,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _bottomBarItem(Icons.filter, 'Change Photo', () {
                          Navigator.of(context).pushNamed('/selectphoto');
                        }),
                      ),
                      Expanded(
                        child: _bottomBarItem(Icons.filter, 'Filter', () {
                          Navigator.of(context).pushNamed('/filter');
                        }),
                      ),
                      Expanded(
                        child: _bottomBarItem(Icons.flip, 'Flip & Rotate', () {
                          Navigator.of(context).pushNamed('/flip');
                        }),
                      ),
                      Expanded(
                        child: _bottomBarItem(Icons.crop, 'Crop', () {
                          Navigator.of(context).pushNamed('/crop');
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomBarItem(IconData icon, String title, VoidCallback onPress) {
    return InkWell(
      onTap: onPress,
      child: Padding(
        padding: const EdgeInsets.only(top: 11),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 59, 53, 53),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                Text(
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  title,
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
