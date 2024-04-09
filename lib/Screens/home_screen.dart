import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user_chat/APIs/api.dart';
import 'package:user_chat/Helpers/dialogs.dart';
import 'package:user_chat/Screens/profile_screen.dart';
import 'package:user_chat/Widgets/chat_item.dart';

import '../Models/user.dart';
import '../main.dart';

class home_screen extends StatefulWidget
{
  const home_screen({super.key});

  @override
  State<home_screen> createState() {
    return _home_screen_state();
  }
}

class _home_screen_state extends State<home_screen>
{
  bool _is_searching=false;

  List<ChatUser> _list=[];
  final List<ChatUser> _search_list=[];


  @override
  void initState()
  {
    super.initState();

    API.get_self_info();

    SystemChannels.lifecycle.setMessageHandler(
            (message) {

              if (API.auth.currentUser!=null)
                {
                  if (message.toString().contains("resume"))
                    {
                      API.update_status(true);
                    }
                  if (message.toString().contains("pause"))
                    {
                      API.update_status(false);
                    }
                }
              
              return Future.value(message);
            }
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: WillPopScope(
              onWillPop: (){
                if (_is_searching)
                  {
                    setState(() {
                      _is_searching=!_is_searching;
                    });

                    return Future.value(false);
                  }
                else
                  {
                    return Future.value(true);
                  }
              },
            child: Scaffold(
              appBar: AppBar(
                title:
                  _is_searching
                    ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: " Enter Text,Email..."
                    ),
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 18,
                      letterSpacing: 0.5
                    ),
                    onChanged: (val){
                      _search_list.clear();

                      for (var i in _list)
                        {
                          if (i.name.toLowerCase().contains(val.toLowerCase())||
                              i.email.toLowerCase().contains(val.toLowerCase()))
                            {
                              _search_list.add(i);

                              setState(() {
                                _search_list;
                              });
                            }
                        }
                    },
                  )
                  : const Text("Chat"),
                backgroundColor: const Color.fromARGB(255, 234, 248, 255),
                actions: [
                  IconButton(
                      onPressed: (){
                        setState(() {
                          _is_searching=!_is_searching;
                        });
                      },
                      icon: Icon(
                          _is_searching
                          ? CupertinoIcons.clear_thick
                          : Icons.search
                      )
                  ),
                  IconButton(
                      onPressed: (){
                        Navigator.push(
                            context,MaterialPageRoute(
                            builder: (_) =>  profile_screen(user: API.me,)
                        )
                        );
                      },
                      icon: const Icon(Icons.more_vert)
                  )
                ],
              ),
              floatingActionButton:
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                  onPressed: () { _add_chat_user_dialog(); },
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.add_comment_rounded),
                ),
              ),
              body: StreamBuilder(
                  stream: API.get_my_users_id(),
                  builder: (context,snapshot){

                    switch(snapshot.connectionState)
                    {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(child: CircularProgressIndicator(),);

                      case ConnectionState.active:
                      case ConnectionState.done:
                        return StreamBuilder(
                            stream: API.get_all_users(
                                snapshot.data!.docs.map((e) => e.id).toList() ?? []
                            ),
                            builder: (context,snapshot){

                              switch(snapshot.connectionState)
                              {
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                  return const Center(child: CircularProgressIndicator(),);

                                case ConnectionState.active:
                                case ConnectionState.done:
                                  final data=snapshot.data?.docs;
                                  _list=data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                                  if (_list.isNotEmpty)
                                    {
                                      return ListView.builder(
                                          itemCount: _is_searching
                                              ? _search_list.length
                                              : _list.length,
                                          padding: EdgeInsets.only(top: mq.height*.01),
                                          physics: const BouncingScrollPhysics(),
                                          itemBuilder: (context,index){
                                           return chat_item(
                                                user: _is_searching
                                                       ? _search_list[index]
                                                       : _list[index]
                                            );
                                          }
                                      );
                                    }
                                  else
                                    {
                                      return
                                          const Center(
                                            child: Text(
                                              "No Chats found",
                                               style: TextStyle(fontSize: 20),
                                            ),
                                          );
                                    }
                              }
                            }
                        );
                    }
                  }
              ),
            ),
          ),
        );
  }

  void _add_chat_user_dialog()
  {
    String email="";

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(
            left: 15,right: 15,top: 20,bottom: 10
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          title:const Row(
            children: [
              Icon(
                Icons.person_add,
                color: Colors.blue,
                size: 28,
              ),
              SizedBox(width: 15,),
              Text("Add User")
            ],
          ),
          content: TextFormField(
            maxLines: null,
            onChanged: (value) => email=value,
            decoration: InputDecoration(
              hintText: "Email Id",
              focusColor: Colors.blueAccent,
              prefixIcon: const Icon(Icons.email,color: Colors.blue,),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18)
              )
            ),
          ),
          actions: [
            MaterialButton(
                onPressed:(){ Navigator.pop(context);},
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.redAccent,fontSize: 16),
                ),
            ),
            MaterialButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (email.isNotEmpty)
                    {
                      await API.add_chat_user(email).then((value) {

                        if (!value)
                          {
                            Dialogs.show_snackbar(context, "User does not exist");
                          }
                      });
                    }
                },
              child: const Text(
                "ADD",
                style: TextStyle(color: Colors.blue,fontSize: 16),
              ),
            )
          ],
        )
    );
  }
}
