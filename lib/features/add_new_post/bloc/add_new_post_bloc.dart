import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_media_flutter_bloc/features/add_new_post/screens/add_filters.dart';

part 'add_new_post_event.dart';
part 'add_new_post_state.dart';

class AddNewPostBloc extends Bloc<AddNewPostEvent, AddNewPostState> {
  final GlobalKey<NavigatorState> navigatorKey;

  AddNewPostBloc({required this.navigatorKey}) : super(AddNewPostInitial()) {
    on<PickImagesEvent>(_onPickImages);
    on<TakePhotoEvent>(_onTakePhoto);
    on<ApplyFilterEvent>(_onApplyFilter);
    on<SaveEditedImageEvent>(_onSaveEditedImage);
    on<SharePostEvent>(_onSharePost);
  }

  Future<void> _onPickImages(
      PickImagesEvent event,
      Emitter<AddNewPostState> emit,
      ) async {
    emit(ImagePickingInProgress());
    try {
      final theme = InstaAssetPicker.themeData(Colors.deepPurple);
      final result = await InstaAssetPicker.pickAssets(
        navigatorKey.currentContext!,
        pickerConfig: InstaAssetPickerConfig(
          pickerTheme: theme.copyWith(
            // ... your theme config ...
          ),
        ), onCompleted: (Stream<InstaAssetsExportDetails> exportDetails) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => AddFilters(cropStream: exportDetails),
            ),
          );
      },
      );
    } catch (e) {
      emit(AddNewPostError('Failed to pick images: $e'));
    }
  }

  Future<void> _onTakePhoto(
      TakePhotoEvent event,
      Emitter<AddNewPostState> emit,
      ) async {
    emit(ImagePickingInProgress());
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        // You might want to handle this differently since it's a single image
        // For now, we'll just emit a success state with the bytes
        // You may need to adjust this based on your needs
        emit(ImageEditedSuccess(
          await _saveEditedImage(bytes),
          0,
        ));
      }
    } catch (e) {
      emit(AddNewPostError('Failed to take photo: $e'));
    }
  }

  Future<void> _onApplyFilter(
      ApplyFilterEvent event,
      Emitter<AddNewPostState> emit,
      ) async {
    emit(FilterApplied(event.filterIndex));
  }

  Future<void> _onSaveEditedImage(
      SaveEditedImageEvent event,
      Emitter<AddNewPostState> emit,
      ) async {
    emit(ImageEditingInProgress());
    try {
      final editedFile = await _saveEditedImage(event.imageBytes);
      emit(ImageEditedSuccess(editedFile, event.index));
    } catch (e) {
      emit(AddNewPostError('Failed to save edited image: $e'));
    }
  }

  Future<void> _onSharePost(
      SharePostEvent event,
      Emitter<AddNewPostState> emit,
      ) async {
    emit(PostSharingInProgress());
    try {
      // Here you would typically upload the images to your backend
      // For now, we'll just emit a success state
      emit(PostSharedSuccess(event.images));
    } catch (e) {
      emit(AddNewPostError('Failed to share post: $e'));
    }
  }

  Future<File> _saveEditedImage(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    return await file.writeAsBytes(bytes);
  }
}