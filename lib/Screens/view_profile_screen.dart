import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_chat/Helpers/my_date_util.dart';
import 'package:user_chat/Models/user.dart';

import '../main.dart';

class view_profile_screen extends StatefulWidget
{
  const view_profile_screen({super.key,required this.user});

  final ChatUser user;

  @override
  State<view_profile_screen> createState() {
    return _view_profile_screen_state();
  }
}

class _view_profile_screen_state extends State<view_profile_screen>
{
  @override
  Widget build(BuildContext context)
  {

    return
      GestureDetector(
        onTap:(){ Focus.of(context).unfocus();},
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.user.name),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Joined on:",
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15
                ),
              ),
              Text(
                MyDateUtil.get_last_message_time(
                    context: context,
                    time: widget.user.createdAt,
                    show_year: true),
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15
                ),
              )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal:mq.height*0.01),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width,height: mq.height*.03,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height*.1),
                    child: CachedNetworkImage(
                      width: mq.height*.2,
                      height: mq.height*.2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context,url,error) =>
                      const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  SizedBox(height: mq.height*.05,),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                    ),
                  ),
                  SizedBox(height: mq.height*.03,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "About: ",
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15
                        ),
                      ),
                      Text(
                        widget.user.about,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 15,

                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
  }
}