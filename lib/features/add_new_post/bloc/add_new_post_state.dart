part of 'add_new_post_bloc.dart';

abstract class AddNewPostState {}

class AddNewPostInitial extends AddNewPostState {}

class ImagePickingInProgress extends AddNewPostState {}

class ImagesPickedSuccess extends AddNewPostState {
  final Stream<InstaAssetsExportDetails> cropStream;

  ImagesPickedSuccess(this.cropStream);
}

class ImageEditingInProgress extends AddNewPostState {}

class ImageEditedSuccess extends AddNewPostState {
  final File editedFile;
  final int index;

  ImageEditedSuccess(this.editedFile, this.index);
}

class FilterApplied extends AddNewPostState {
  final int selectedFilterIndex;

  FilterApplied(this.selectedFilterIndex);
}

class PostSharingInProgress extends AddNewPostState {}

class PostSharedSuccess extends AddNewPostState {
  final List<File> images;

  PostSharedSuccess(this.images);
}

class AddNewPostError extends AddNewPostState {
  final String message;

  AddNewPostError(this.message);
}