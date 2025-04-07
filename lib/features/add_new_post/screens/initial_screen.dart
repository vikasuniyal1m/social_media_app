import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_flutter_bloc/features/add_new_post/bloc/add_new_post_bloc.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.purple),
          ),
          onPressed: () {
            context.read<AddNewPostBloc>().add(PickImagesEvent());
          },
          child: const Text("Start", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}