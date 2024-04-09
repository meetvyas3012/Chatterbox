import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:user_chat/Models/messages.dart';

class photo_view_screen extends StatelessWidget {
  const photo_view_screen({super.key,required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {

    return
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 221, 245, 255),
            title: const Text("Image"),
          ),
          body: PhotoView(
              imageProvider: CachedNetworkImageProvider(message.msg),
              loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(),
              ),
          ),
        );
  }
}
