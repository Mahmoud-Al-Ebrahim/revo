import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_text.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/constants.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controlller/auth_controller.dart';
import 'package:reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit/responsive/responsive.dart';
import 'package:reddit/theme/pallete.dart';

import '../../../core/common/helper_functions.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;

  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController bioController;
  late ValueNotifier<String?> showSelectedDate ;


  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: ref.read(userProvider)!.firstName);
    lastNameController = TextEditingController(text: ref.read(userProvider)!.lastName);
    bioController = TextEditingController(text: ref.read(userProvider)!.bio);
    showSelectedDate = ValueNotifier(ref.read(userProvider)!.birthDate);
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();

    if (res != null) {
      if (kIsWeb) {
        setState(() {
          bannerWebFile = res.files.first.bytes;
        });
      } else {
        setState(() {
          bannerFile = File(res.files.first.path!);
        });
      }
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();

    if (res != null) {
      if (kIsWeb) {
        setState(() {
          profileWebFile = res.files.first.bytes;
        });
      } else {
        setState(() {
          profileFile = File(res.files.first.path!);
        });
      }
    }
  }

  void save() {
    ref.read(userProfileControllerProvider.notifier).editCommunity(
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
          firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
          bio: bioController.text,
          birthDate : showSelectedDate.value ,
          bannerWebFile: bannerWebFile,
          profileWebFile: profileWebFile,
        );
  }

  String? birthDateInString;
  DateTime? birthDate;
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) => Scaffold(
            backgroundColor: currentTheme.dialogBackgroundColor,
            appBar: AppBar(
              title: const Text('Edit Profile'),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: save,
                  child: const Text('Save'),
                ),
              ],
            ),
            body: isLoading
                ? const Loader()
                : Responsive(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: selectBannerImage,
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    dashPattern: const [10, 4],
                                    strokeCap: StrokeCap.round,
                                    color: currentTheme
                                        .textTheme.bodyText2!.color!,
                                    child: Container(
                                      width: double.infinity,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerWebFile != null
                                          ? Image.memory(bannerWebFile!)
                                          : bannerFile != null
                                              ? Image.file(bannerFile!)
                                              : user.banner.isEmpty ||
                                                      user.banner ==
                                                          Constants
                                                              .bannerDefault
                                                  ? const Center(
                                                      child: Icon(
                                                        Icons
                                                            .camera_alt_outlined,
                                                        size: 40,
                                                      ),
                                                    )
                                                  : Image.network(user.banner),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: selectProfileImage,
                                    child: profileWebFile != null
                                        ? CircleAvatar(
                                            backgroundImage:
                                                MemoryImage(profileWebFile!),
                                            radius: 32,
                                          )
                                        : profileFile != null
                                            ? CircleAvatar(
                                                backgroundImage:
                                                    FileImage(profileFile!),
                                                radius: 32,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    user.profilePic),
                                                radius: 32,
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'First Name',
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Last Name',
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          ),
                          SizedBox(height: 15,),
                          TextField(
                            controller: bioController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'Bio',
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(18),
                            ),
                          ),
                          SizedBox(height: 15,),
                          GestureDetector(
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrange,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        new Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        ValueListenableBuilder<String?>(
                                            valueListenable: showSelectedDate,
                                            builder: (context, date, _) {
                                              return Text(
                                                '${date == null ? 'select birth date' : date}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              );
                                            })
                                      ],
                                    ),
                                  )),
                              onTap: () async {
                                final datePick = await showDatePicker(
                                    context: context,
                                    initialDate: new DateTime.now(),
                                    firstDate: new DateTime(1900),
                                    lastDate: new DateTime(2100));
                                if (datePick != null) {
                                  if(datePick.year > 2014){
                                    notifyDialog(context, 'Year of Birth can\'t be smaller than 2014!');
                                    return ;
                                  }
                                  birthDate = datePick;
                                  showSelectedDate.value =
                                  "${birthDate!.month}/${birthDate!.day}/${birthDate!.year}";
                                }
                              }),
                        ],
                      ),
                    ),
                  ),
          ),
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(
            error: error.toString(),
          ),
        );
  }
}
