import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reddit/core/common/helper_functions.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/responsive/responsive.dart';

import '../../../theme/pallete.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends ConsumerState<CreateCommunityScreen> {
  final communityNameController = TextEditingController();
  late TextEditingController bioController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    bioController.dispose();
    communityNameController.dispose();
  }

  void createCommunity() {
    if(communityNameController.text.isEmpty){
      toastMessage('community name must not be empty!');
      return;
    }
    if(bioController.text.isEmpty){
      toastMessage('community bio must not be empty!');
      return;
    }
    ref.read(communityControllerProvider.notifier).createCommunity(
          communityNameController.text.trim(),
          bioController.text.trim(),
          context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a community'),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SvgPicture.asset('assets/svg/community_bg.svg', fit: BoxFit.fitHeight,height: 300,),
          isLoading
              ? const Loader()
              : Column(
                children: [
                  Responsive(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text('Community Name'),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: communityNameController,
                              decoration: const InputDecoration(
                                hintText: 'Community_name',
                                filled: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(18),
                              ),
                              maxLength: 21,
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  Responsive(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.topLeft,
                              child: Text('Community Bio'),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: bioController,
                              decoration: const InputDecoration(
                                hintText: 'Community_bio',
                                filled: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(18),
                              ),
                              maxLength: 150,
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: createCommunity,
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                              child: const Text(
                                'Create community',
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
        ],
      ),
    );
  }
}
