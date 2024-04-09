import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:user_chat/APIs/api.dart';
import 'package:user_chat/Helpers/my_date_util.dart';
import 'package:user_chat/Models/messages.dart';
import 'package:user_chat/Screens/chat_screen.dart';
import 'package:user_chat/Screens/profile_screen.dart';
import 'package:user_chat/Screens/view_profile_screen.dart';

import '../Models/user.dart';
import '../main.dart';

class chat_item extends StatefulWidget {
  const chat_item({super.key, required this.user});

  final ChatUser user;

  @override
  State<StatefulWidget> createState() {
    return _chat_item_state();
  }
}

class _chat_item_state extends State<chat_item> {
  Message? _message;

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => chat_screen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: API.get_last_message(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];

            return ListTile(
              //user profile picture
              leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => view_profile_screen(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: mq.height * .055,
                      height: mq.height * .055,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
              //user name
              title: Text(widget.user.name,style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 18),),

              //last message
              subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? 'Image'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1),

              //last message time
              trailing: _message == null
                  ? null //show nothing when no message is sent
                  : _message!.read.isEmpty && _message!.fromId != API.user.uid
                      ?
                      //show for unread message
                      Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              borderRadius: BorderRadius.circular(10)),
                        )
                      :
                      //message sent time
                      Text(
                          MyDateUtil.get_last_message_time(
                              context: context, time: _message!.sent),
                          style: const TextStyle(color: Colors.black54),
                        ),
            );
          },
        ),
      ),
    );
  }
}
