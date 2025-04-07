part of 'add_new_post_bloc.dart';

abstract class AddNewPostEvent {}

class PickImagesEvent extends AddNewPostEvent {}

class TakePhotoEvent extends AddNewPostEvent {}

class ApplyFilterEvent extends AddNewPostEvent {
  final int filterIndex;
  final Uint8List imageBytes;

  ApplyFilterEvent(this.filterIndex, this.imageBytes);
}

class SaveEditedImageEvent extends AddNewPostEvent {
  final Uint8List imageBytes;
  final int index;

  SaveEditedImageEvent(this.imageBytes, this.index);
}

class SharePostEvent extends AddNewPostEvent {
  final List<File> images;

  SharePostEvent(this.images);
}