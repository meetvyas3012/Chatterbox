import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:user_chat/APIs/api.dart';
import 'package:user_chat/Helpers/dialogs.dart';
import 'package:user_chat/Helpers/my_date_util.dart';
import 'package:user_chat/Models/messages.dart';
import 'package:user_chat/Screens/photo_view_screen.dart';

import '../main.dart';

class message_card extends StatefulWidget
{
  const message_card({super.key,required this.message});

  final Message message;

  @override
  State<StatefulWidget> createState() => _message_card_state();
}

class _message_card_state extends State<message_card>
{
  void _show_message_update_dialog()
  {
    String updated_message=widget.message.msg;

    showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24,right: 24,top: 20,bottom: 10
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 18,
                  ),
                  SizedBox(width: 10,),
                  Text("Update Message")
                ],
              ),
              content: TextFormField(
                initialValue: updated_message,
                maxLines: null,
                onChanged: (value) => updated_message=value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)
                    )
                ),
              ),
              actions: [
                MaterialButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.redAccent,fontSize: 16),
                  ),
                ),
                MaterialButton(
                  onPressed: (){
                    Navigator.pop(context);
                    API.update_message(widget.message, updated_message);
                  },
                  child: const Text(
                    "UPDATE",
                    style: TextStyle(color: Colors.blue,fontSize: 16),
                  ),
                )
              ],
            )
    );
  }

  void _show_bottom_sheet(bool is_me)
  {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20)
          )
        ),
        builder: (_) => ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: mq.height*.015,
                horizontal: mq.width*.4
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8)
              ),
            ),

            widget.message.type==Type.text
                ? 
                _option_item(
                    icon: const Icon(Icons.copy_all_rounded),
                    on_tap: () async{
                      await Clipboard.setData(ClipboardData(text: widget.message.msg)).then(
                              (value){
                                Navigator.pop(context);
                                Dialogs.show_snackbar(context, "Text copied");
                              }
                              );
                      },
                    name: "Copy Text"
                )
                :
            _option_item(
                icon: const Icon(Icons.copy_all_rounded),
                on_tap: () async {
                  try{
                    await GallerySaver.
                    saveImage(widget.message.msg, albumName: "User Chat")
                        .then(
                            (value) {
                          Navigator.pop(context);

                          if (value != null && value) {
                            Dialogs.show_snackbar(
                                context, "Image Added to Gallery");
                          }
                        });
                  }
                  catch(e){
                    Dialogs.show_snackbar(context,"Error");
                  }
                },
                name: "Save Image"
            ),
            if (widget.message.type==Type.text && is_me)
              _option_item(
                  icon: const Icon(Icons.edit,color: Colors.blue,size: 26,),
                  on_tap: (){
                    Navigator.pop(context);
                    _show_message_update_dialog();
                  },
                  name: "Edit Message"
              ),
            if(is_me)
              _option_item(
                  icon:const Icon(Icons.delete_forever,color: Colors.red,size: 26,),
                  on_tap: ()async{
                    await API.delete_message(widget.message).then(
                            (value) =>
                                Navigator.pop(context)
                    );
                  },
                  name: "Delete Message"
              ),
            _option_item(
                icon:const Icon(Icons.remove_red_eye,color: Colors.blue,),
                on_tap: (){},
                name: "Sent at:${MyDateUtil.get_message_time(context: context, time: widget.message.sent)}"
            ),
            _option_item(
                icon:const Icon(Icons.remove_red_eye,color: Colors.blue,),
                on_tap: (){},
                name:  widget.message.read.isEmpty
                    ? "Read at:Not seen yet"
                    : "Read at:${MyDateUtil.get_message_time(context: context, time: widget.message.sent)}"
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context)
  {
    bool is_me=widget.message.fromId==API.user.uid;

    return
        InkWell(
          onLongPress:(){ _show_bottom_sheet(is_me);},
          onTap: (){
            if (widget.message.type==Type.image)
              {
                Navigator.push(context, MaterialPageRoute(
                    builder:(context) =>photo_view_screen(message: widget.message)
                )
                );
              }
          },
          child: (is_me) ? _green_message() : _blue_message(),
        );
  }

  Widget _green_message()
  {

    return
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.message.read.isNotEmpty)
                const Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),
              const SizedBox(width: 2,),
              Text(
                MyDateUtil.get_formatted_date(
                    context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 13,color: Colors.black54),
              )
            ],
          ),
          Flexible(
              child: Container(
                padding: EdgeInsets.all(
                    widget.message.type==Type.image
                        ? mq.width*.03
                        : mq.width*.04
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: mq.width*.03,vertical: mq.height*.01
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 218, 255, 176),
                  border: Border.all(color: Colors.lightGreen),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30)
                  )
                ),
                child:
                widget.message.type==Type.text
                  ? Text(
                  widget.message.msg,
                  style: const TextStyle(fontSize: 15,color: Colors.black87),
                )
                  : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context,url) => const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                      ),
                      errorWidget: (context,url,error) =>
                          const Icon(Icons.image,size: 70,)
                  ),
                )
              )
          )
        ],
      );
  }

  Widget _blue_message()
  {
    if (widget.message.read.isEmpty)
      {
        API.update_message_read_status(widget.message);
      }
    return
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Container(
                    padding: EdgeInsets.all(
                        widget.message.type==Type.image
                            ? mq.width*.03
                            : mq.width*.04
                    ),
                    margin: EdgeInsets.symmetric(
                        horizontal: mq.width*.03,vertical: mq.height*.01
                    ),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 221, 245, 255),
                        border: Border.all(color: Colors.lightBlue),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30)
                        )
                    ),
                    child:
                    widget.message.type==Type.text
                        ? Text(
                      widget.message.msg,
                      style: const TextStyle(fontSize: 15,color: Colors.black87),
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context,url) => const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context,url,error) =>
                          const Icon(Icons.image,size: 70,)
                      ),
                    )
                )
            ),
            Padding(
                padding: EdgeInsets.only(right: mq.width*.04),
                child: Text(
                  MyDateUtil.get_formatted_date(
                      context: context, time: widget.message.sent),
                  style: const TextStyle(fontSize: 13,color: Colors.black54),
                ),
            )
          ],
        );
  }
}

class _option_item extends StatelessWidget
{

  const _option_item({super.key,required this.icon,required this.on_tap, required this.name});

  final Icon icon;
  final String name;
  final VoidCallback on_tap;

  @override
  Widget build(BuildContext context)
  {
    return
        InkWell(
          onTap: on_tap,
          child:
          Padding(
            padding: EdgeInsets.only(
              left: mq.width*.05,
              top: mq.height*.015,
              bottom: mq.height*.015
            ),
            child: Row(
              children: [
                icon,
                Flexible(
                    child: Text(
                      "  $name",
                      style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          letterSpacing: 0.5),
                    )
                )
              ],
            ),
          ),
        );
  }
}
