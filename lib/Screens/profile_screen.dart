import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:user_chat/APIs/api.dart';
import 'package:user_chat/Helpers/dialogs.dart';
import 'package:user_chat/Models/user.dart';
import 'package:user_chat/Screens/login_screen.dart';

import '../main.dart';

class profile_screen extends StatefulWidget
{
  const profile_screen({super.key,required this.user});

  final ChatUser user;

  @override
  State<StatefulWidget> createState() {
    return _profile_screen_state();
  }
}

class _profile_screen_state extends State<profile_screen>
{
  final _form_key=GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context)
  {
    return
        GestureDetector(
          onTap: () => Focus.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Profile Screen"),
            ),
            floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton.extended(
                    backgroundColor: Colors.red,
                    onPressed: () async{

                      Dialogs.show_progress_bar(context);
                      await API.update_status(false);

                      await API.auth.signOut().then((value) async{

                        await GoogleSignIn().signOut().then((value) {

                          Navigator.pop(context);
                          Navigator.pop(context);

                          API.auth=FirebaseAuth.instance;

                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const login_screen())
                          );
                        });
                      });
                    },
                    icon: const Icon(Icons.logout_outlined,color: Colors.white,),
                    label: const Text("Logout",style: TextStyle(color: Colors.white,fontSize: 16),)
                ),
            ),
            body: Form(
                key: _form_key,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal:mq.width*.05),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(width: mq.width,height: mq.height*.03,),
                        Stack(
                          children: [
                            (_image!=null)

                            ?
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(mq.height*.1),
                                  child: Image.file(
                                    File(_image!),
                                    width: mq.height*.2,
                                    height: mq.height*.2,
                                    fit: BoxFit.cover,
                                  ),
                                )
                            :
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(mq.height*.1),
                                  child: CachedNetworkImage(
                                    width: mq.height*.2,
                                    height: mq.height*.2,
                                    fit: BoxFit.cover,
                                    imageUrl: widget.user.image,
                                    errorWidget: (context,url,error) =>
                                        const CircleAvatar(child: Icon(CupertinoIcons.person),)
                                  ),
                                ),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: MaterialButton(
                                    elevation: 1,
                                    onPressed: (){
                                      _show_bottom_sheet();
                                    },
                                    shape: const CircleBorder(),
                                    color: Colors.white,
                                    child: const Icon(Icons.edit,color: Colors.blue,),
                                )
                            )
                          ],
                        ),
                        SizedBox(height: mq.height * .03),
                        Text(
                          widget.user.email,
                          style: const TextStyle(
                            color: Colors.black,fontSize: 16),),
                        SizedBox(height: mq.height*.03,),
                        TextFormField(
                          initialValue: widget.user.name,
                          onSaved: (val)=>API.me.name=val ?? "",
                          validator: (val) => val!=null && val.isNotEmpty ? null : "Required field",
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person,color: Colors.blue,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            hintText: "ex.John Doe",
                            labelText: "Name"
                          ),
                        ),
                        SizedBox(height: mq.height*.02,),
                        TextFormField(
                          initialValue: widget.user.about,
                          onSaved: (val)=>API.me.about=val ?? "",
                          validator: (val) => val!=null && val.isNotEmpty ? null : "Required field",
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person,color: Colors.blue,),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              hintText: "ex.Hi!!",
                              labelText: "About"
                          ),
                        ),
                        SizedBox(height: mq.height*.05,),
                        ElevatedButton.icon(
                            onPressed: (){
                              if (_form_key.currentState!.validate())
                                {
                                  _form_key.currentState!.save();
                                  API.update_user_info().then(
                                          (value) =>
                                              Dialogs.show_snackbar(context,"Details Updated Successfully")
                                  );
                                }
                            },
                            icon:const Icon(Icons.edit,size: 28,color: Colors.white,),
                            label:const Text("UPDATE",style: TextStyle(fontSize: 17,color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                              backgroundColor: Colors.blue,
                              minimumSize: Size(mq.width * .5, mq.height * .06))
                            ),
                      ],
                    ),
                  ),
                )
            ),
          ),
        );
  }

  void _show_bottom_sheet()
  {

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20)
          )
        ),
        builder:(_){
          return
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  top: mq.width*.03,
                  bottom: mq.height*.05
                ),
                children: [
                  const Text(
                      "Pick Profile Image",
                       textAlign: TextAlign.center,
                       style: TextStyle(
                         fontSize: 20,
                         fontWeight: FontWeight.w500
                       ),
                  ),
                  SizedBox(height: mq.height*.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const CircleBorder(),
                            fixedSize: Size(mq.width*.3, mq.height*.15),),
                          onPressed: () async{
                            final image_picker=ImagePicker();

                            final XFile? image=await image_picker.pickImage(
                                source: ImageSource.gallery,imageQuality: 80);

                            if (image!=null)
                              {
                                setState(() {
                                  _image=image.path;
                                });
                              }

                            API.update_profile_photo(File(_image!));
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.photo,size: 50,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width*.3, mq.height*.15),),
                        onPressed: () async{
                          final image_picker=ImagePicker();

                          final XFile? image=await image_picker.pickImage(
                              source: ImageSource.camera,imageQuality: 80);

                          if (image!=null)
                          {
                            setState(() {
                              _image=image.path;
                            });
                          }

                          API.update_profile_photo(File(_image!));
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.camera,size: 50,),
                      ),

                    ],
                  )
                ],
              );
        }
    );
  }
}


