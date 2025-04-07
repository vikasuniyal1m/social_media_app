import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:social_media_flutter_bloc/features/add_new_post/bloc/add_new_post_bloc.dart';
import 'package:social_media_flutter_bloc/features/add_new_post/screens/post_display_screen.dart';
import 'package:social_media_flutter_bloc/features/add_new_post/widgets/crop_result_view.dart';

class AddFilters extends StatelessWidget {
  final Stream<InstaAssetsExportDetails> cropStream;

  const AddFilters({super.key, required this.cropStream});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height - kToolbarHeight;
    return BlocListener<AddNewPostBloc, AddNewPostState>(
      listener: (context, state) {
        if (state is PostSharedSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDisplayScreen(images: state.images),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('New Post')),
        body: StreamBuilder<InstaAssetsExportDetails>(
          stream: cropStream,
          builder: (context, snapshot) => CropResultView(
            result: snapshot.data,
            heightFiles: height / 2,
            heightAssets: height / 4,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.read<AddNewPostBloc>().add(TakePhotoEvent()),
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}