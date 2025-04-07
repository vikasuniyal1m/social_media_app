import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_flutter_bloc/features/add_new_post/bloc/add_new_post_bloc.dart';

class FullScreenImage extends StatefulWidget {
  final Uint8List imageBytes;

  const FullScreenImage({super.key, required this.imageBytes});

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddNewPostBloc, AddNewPostState>(
      builder: (context, state) {
        int selectedFilterIndex = 0;
        if (state is FilterApplied) {
          selectedFilterIndex = state.selectedFilterIndex;
        }

        final List<Map<String, dynamic>> filters = [
          {
            'name': 'Filter 1',
            'matrix': ColorFilter.matrix([
              0.7, 0.0, 0.0, 0.0, 0.0,
              0.0, 0.9, 0.0, 0.0, 0.0,
              0.0, 0.0, 0.8, 0.0, 0.0,
              0.0, 0.0, 0.0, 1.0, 0.0,
            ]),
          },
          {
            'name': 'Filter 2',
            'matrix': ColorFilter.matrix([
              1.2, 0.0, 0.0, 0.0, 0.0,
              0.0, 1.0, 0.0, 0.0, 0.0,
              0.0, 0.0, 0.9, 0.0, 0.0,
              0.0, 0.0, 0.0, 1.0, 0.0,
            ]),
          },
          {
            'name': 'Filter 3',
            'matrix': ColorFilter.matrix([
              0.5, 0.5, 0.5, 0.0, 0.0,
              0.5, 0.5, 0.5, 0.0, 0.0,
              0.5, 0.5, 0.5, 0.0, 0.0,
              0.0, 0.0, 0.0, 1.0, 0.0,
            ]),
          },
          {
            'name': 'Filter 4',
            'matrix': ColorFilter.matrix([
              1.0, 0.0, 0.0, 0.0, 0.0,
              0.0, 0.8, 0.0, 0.0, 0.0,
              0.0, 0.0, 0.8, 0.0, 0.0,
              0.0, 0.0, 0.0, 1.0, 0.0,
            ]),
          },
        ];

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: TextButton(
                  onPressed: _saveAndReturn,
                  child: const Text('Next', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: InteractiveViewer(
                    maxScale: 5.0,
                    child: ColorFiltered(
                      colorFilter: filters[selectedFilterIndex]['matrix'],
                      child: Image.memory(widget.imageBytes),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => context
                          .read<AddNewPostBloc>()
                          .add(ApplyFilterEvent(index, widget.imageBytes)),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedFilterIndex == index
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ColorFiltered(
                          colorFilter: filters[index]['matrix'],
                          child: Image.memory(
                            widget.imageBytes,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAndReturn() async {
    try {
      final RenderRepaintBoundary boundary =
      _repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List bytes = byteData!.buffer.asUint8List();

      if (!mounted) return;
      Navigator.pop(context, bytes);
    } catch (e) {
      print('Error saving image: $e');
    }
  }
}