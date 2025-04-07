import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:social_media_flutter_bloc/features/add_new_post/bloc/add_new_post_bloc.dart';
import 'package:social_media_flutter_bloc/features/add_new_post/widgets/full_screen_image.dart';

class CropResultView extends StatefulWidget {
  const CropResultView({
    super.key,
    required this.result,
    this.heightFiles = 300.0,
    this.heightAssets = 120.0,
  });

  final InstaAssetsExportDetails? result;
  final double heightFiles;
  final double heightAssets;

  @override
  State<CropResultView> createState() => _CropResultViewState();
}

class _CropResultViewState extends State<CropResultView> {
  final Map<int, File> editedImages = {};

  List<InstaAssetsExportData?> get data => widget.result?.data ?? [];
  List<AssetEntity> get selectedAssets => widget.result?.selectedAssets ?? [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddNewPostBloc, AddNewPostState>(
      listener: (context, state) {
        if (state is ImageEditedSuccess) {
          setState(() {
            editedImages[state.index] = state.editedFile;
          });
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: kThemeChangeDuration,
              curve: Curves.easeInOut,
              height: data.isNotEmpty ? widget.heightFiles : 40.0,
              child: Column(
                children: <Widget>[
                  _buildTitle('Selected images', data.length),
                  _buildCroppedAssetsListView(context),
                ],
              ),
            ),
            if (editedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.result != null &&
                        widget.result?.progress != null &&
                        widget.result!.progress >= 1 &&
                        selectedAssets.isNotEmpty
                        ? () {
                      final List<File> finalImages = data
                          .asMap()
                          .entries
                          .map((entry) =>
                      editedImages[entry.key] ??
                          entry.value!.croppedFile!)
                          .toList();
                      context
                          .read<AddNewPostBloc>()
                          .add(SharePostEvent(finalImages));
                    }
                        : null,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Share'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTitle(String title, int length) {
    return SizedBox(
      height: 20.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(title),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            padding: const EdgeInsets.all(4.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurpleAccent,
            ),
            child: Text(
              length.toString(),
              style: const TextStyle(color: Colors.white, height: .7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCroppedAssetsListView(BuildContext context) {
    if (widget.result?.progress == null) {
      return const SizedBox.shrink();
    }

    final double progress = widget.result!.progress;

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (BuildContext _, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 16.0,
                ),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (data[index]?.croppedFile != null) {
                          final bytes =
                          await data[index]!.croppedFile!.readAsBytes();
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                  imageBytes: bytes),
                            ),
                          );

                          if (result != null && result is Uint8List) {
                            context.read<AddNewPostBloc>().add(
                                SaveEditedImageEvent(result, index));
                          }
                        }
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: data[index]?.croppedFile != null
                            ? Image.file(
                          editedImages.containsKey(index)
                              ? editedImages[index]!
                              : data[index]!.croppedFile!,
                        )
                            : Container(),
                      ),
                    ),
                    if (data[index]?.croppedFile != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () async {
                            final bytes =
                            await data[index]!.croppedFile!.readAsBytes();
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ImageEditor(image: bytes),
                              ),
                            );

                            if (result != null && result is Uint8List) {
                              context.read<AddNewPostBloc>().add(
                                  SaveEditedImageEvent(result, index));
                            }
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          if (progress < 1.0)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(.5),
                ),
              ),
            ),
          if (progress < 1.0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: progress,
                    semanticsLabel: '${progress * 100}%',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}