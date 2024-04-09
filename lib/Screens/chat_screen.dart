
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_chat/APIs/api.dart';
import 'package:user_chat/Helpers/my_date_util.dart';
import 'package:user_chat/Screens/view_profile_screen.dart';
import 'package:user_chat/Widgets/message_card.dart';

import '../Models/messages.dart';
import '../Models/user.dart';
import '../main.dart';

class chat_screen extends StatefulWidget
{
  const chat_screen({super.key,required this.user});

  final ChatUser user;

  @override
  State<StatefulWidget> createState() {
    return _chat_screen_state();
  }
}

class _chat_screen_state extends State<chat_screen>
{
  List<Message> _list=[];
  bool _show_emoji=false;
  bool _is_uploading=false;

  final _text_controller=TextEditingController();

  @override
  Widget build(BuildContext context)
  {

    return
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: WillPopScope(
              onWillPop: (){
                  if (_show_emoji)
                    {
                      setState(() {
                        _show_emoji=!_show_emoji;
                      });
                      return Future.value(false);
                    }
                  return Future.value(true);
              },
                child:Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    flexibleSpace: _app_bar(),
                    backgroundColor: const Color.fromARGB(255, 234, 248, 255),
                  ),
                  body: Column(
                    children: [
                      Expanded(
                          child: StreamBuilder(
                            stream: API.get_all_messages(widget.user),
                            builder: (context,snapshot) {

                             switch(snapshot.connectionState)
                              {
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                  return const SizedBox();

                                case ConnectionState.done:
                                case ConnectionState.active:
                                  final data=snapshot.data?.docs;
                                  _list=data?.map(
                                          (e) => Message.fromJson(e.data())).toList()
                                           ?? [];

                                  if (_list.isNotEmpty)
                                    {
                                      return ListView.builder(
                                          reverse: true,
                                          itemCount: _list.length,
                                          padding: EdgeInsets.only(top: mq.height * .01),
                                          itemBuilder: (context,index){
                                            return message_card(message: _list[index]);
                                          }
                                      );
                                    }
                                  else
                                    {
                                      return const Center(
                                        child: Text("Say Hi!",style: TextStyle(fontSize: 20),),
                                      );
                                    }
                              }
                            }
                          )
                      ),
                      if (_is_uploading)
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                              child: CircularProgressIndicator(strokeWidth: 2,),
                          ),
                        ),
                      _chat_input(),

                      if (_show_emoji)
                          SizedBox(
                            height: mq.height*0.35,
                            child: EmojiPicker(
                              textEditingController: _text_controller, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                              config: Config(
                                emojiViewConfig: EmojiViewConfig(
                                  columns: 7,
                                  emojiSizeMax: 32 *
                                      (Platform.isIOS
                                          ?  1.20
                                          :  1.0),
                                ),
                              ),
                            )
                          )
                    ],
                  ),
                )

          ),
        );
  }

  Widget _chat_input()
  {

    return
        Padding(
            padding: EdgeInsets.symmetric(
              vertical: mq.height*.01,
              horizontal: mq.width*.025
            ),
            child: Row(
              children: [
                Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: (){
                                FocusScope.of(context).unfocus();
                                setState(() => _show_emoji=!_show_emoji );
                              },
                              icon: const Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.blueAccent,
                                size: 25,
                              )
                          ),
                          Expanded(
                              child:TextField(
                                controller: _text_controller,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                onTap:(){
                                  if (_show_emoji)
                                  {
                                    setState(() {
                                      _show_emoji=!_show_emoji;
                                    });
                                  }
                                },
                                decoration: const InputDecoration(
                                    hintText: "Send Message",
                                    hintStyle: TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.w400),
                                    border: InputBorder.none
                                ),
                              ),
                          ),
                          IconButton(
                              onPressed: () async{
                                final image_picker=ImagePicker();

                                final List<XFile> images=await image_picker.pickMultiImage(imageQuality: 70);

                                for (var i in images)
                                {
                                  setState(() {
                                    _is_uploading=true;
                                  });
                                  await API.send_chat_image(widget.user, File(i.path));
                                  setState(() {
                                    _is_uploading=false;
                                  });
                                }
                              },
                              icon: const Icon(Icons.image,color: Colors.blueAccent,size: 26,)
                          ),
                          IconButton(
                              onPressed: () async{
                                final image_picker=ImagePicker();

                                final XFile? image=await image_picker.pickImage(
                                    source: ImageSource.camera,imageQuality: 70
                                );

                                if (image!=null)
                                {
                                  setState(() {
                                    _is_uploading=true;
                                  });
                                  await API.send_chat_image(widget.user, File(image.path));
                                  setState(() {
                                    _is_uploading=false;
                                  });
                                }
                              },
                              icon:const Icon(Icons.camera_alt_rounded,color: Colors.blueAccent,size: 26,)
                          ),
                          SizedBox(width: mq.width*.02,)
                        ],
                      ),
                    ),
                ),
                MaterialButton(
                    onPressed: (){
                      if (_text_controller.text.isNotEmpty)
                        {
                          if (_list.isEmpty)
                            {
                              API.send_first_message(widget.user, _text_controller.text, Type.text);
                            }
                          else
                            {
                              API.send_message(widget.user, _text_controller.text, Type.text);
                            }
                          _text_controller.text="";
                        }
                    },
                  minWidth: 0,
                  padding: const EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10),
                  shape: const CircleBorder(),
                  color: Colors.green,
                  child: const Icon(Icons.send,color: Colors.white,size: 28,),
                )
              ],
            )
        );
  }

  Widget _app_bar()
  {

    return
       SafeArea(
           child:InkWell(
             onTap: (){
               Navigator.push(
                   context,
                   MaterialPageRoute(
                       builder: (_)=> view_profile_screen(user: widget.user,)
                   )
               );
             },
             child: StreamBuilder(
                 stream: API.get_user_info(widget.user),
                 builder: (context,snapshot){
                   final data=snapshot.data?.docs;
                   final list=data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                   print(list.length);
                   print(API.get_user_info(widget.user).length.toString());

                   return Row(
                     children: [
                       IconButton(
                           onPressed: () => Navigator.pop(context),
                           icon: const Icon(Icons.arrow_back,color: Colors.black,)
                       ),
                       ClipRRect(
                         borderRadius: BorderRadius.circular(mq.height*.03),
                         child: CachedNetworkImage(
                           fit: BoxFit.cover,
                           width: mq.height * .05,
                           height: mq.height * .05,
                           imageUrl:
                           list.isNotEmpty
                               ? list[0].image
                               : widget.user.image,
                           errorWidget: (context,url,error) => const CircleAvatar(
                             child: Icon(CupertinoIcons.person),
                           ),
                         ),
                       ),
                       const SizedBox(width: 10,),
                       Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const SizedBox(height: 5,),
                           Expanded(child: Text(
                             list.isNotEmpty ? list[0].name : widget.user.name,
                             style: const TextStyle(
                                 fontSize: 20,color: Colors.black87,fontWeight: FontWeight.w500),
                           )),

                           Expanded(
                               child: Text(
                                 list.isNotEmpty
                                     ? list[0].isOnline
                                     ? "Online"
                                     : MyDateUtil.get_last_active_time(context, list[0].lastActive)
                                     : MyDateUtil.get_last_active_time(context, widget.user.lastActive),
                                 style: const TextStyle(color: Colors.black,fontSize: 13),
                               )
                           )

                         ],
                       )

                     ],
                   );
                 }
             ),
           )
       );
  }
}