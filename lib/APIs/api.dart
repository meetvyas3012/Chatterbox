import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:user_chat/Helpers/dialogs.dart';
import 'package:user_chat/Models/messages.dart';

import '../Models/user.dart';

class API
{
  static FirebaseAuth auth=FirebaseAuth.instance;
  static FirebaseFirestore fire_store=FirebaseFirestore.instance;
  static FirebaseStorage storage=FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  static FirebaseMessaging f_message=FirebaseMessaging.instance;

  static Future<bool> user_exists() async
  {
    return (await fire_store.collection("users").doc(user.uid).get()).exists;
  }

  static ChatUser me=ChatUser(
      image: user.photoURL.toString(),
      about: "Hello World",
      name: user.displayName.toString(),
      createdAt: "",
      isOnline: false,
      id: user.uid,
      lastActive: "",
      email: user.email.toString(),
      pushToken: ""
  );

  static Future<void> create_user() async
  {
    final time=DateTime.now().millisecondsSinceEpoch.toString();

    final chat_user=ChatUser(
        image: user.photoURL.toString(),
        about: "Hello World",
        name: user.displayName.toString(),
        createdAt: time,
        isOnline: false,
        id: user.uid,
        lastActive: time,
        email: user.email.toString(),
        pushToken: ""
    );

    return
      await fire_store
          .collection("users")
          .doc(user.uid)
          .set(chat_user.to_json());
  }

  static Future<bool> add_chat_user(String email) async
  {
    final data=await fire_store
        .collection("users")
        .where("email",isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id!=user.uid)
    {
      fire_store.collection("users")
          .doc(user.uid)
          .collection("my_users")
          .doc(data.docs.first.id)
          .set({});

      return true;
    }

    return false;
  }

  static Future<void> get_firebase_messaging_token() async
  {
    await f_message.requestPermission();

    await f_message.getToken().then(
            (value){
                if (value!=null)
                {
                  me.pushToken=value;
                }
            }
    );
  }

  static Future<void> update_status(bool is_online) async
  {
    fire_store.collection("users").doc(user.uid).update({
      "is_online":is_online,
      "last_active":DateTime.now().millisecondsSinceEpoch.toString(),
      "push_token":me.pushToken
    });
  }

  static Future<void> get_self_info() async
  {
    await fire_store.collection("users").doc(user.uid).get().then(
            (value) async{
              if (value.exists)
                {
                  me=ChatUser.fromJson(value.data()!);
                  await get_firebase_messaging_token();

                  update_status(true);
                }
              else
                {
                  await create_user().then((value) => get_self_info());
                }
            }
            );
  }

  static Stream<QuerySnapshot<Map<String,dynamic>>> get_my_users_id()
  {
    return fire_store
        .collection("users")
        .doc(user.uid)
        .collection("my_users")
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String,dynamic>>> get_all_users(List<String> user_id)
  {
    return fire_store
        .collection("users")
        .where("id",whereIn: user_id.isEmpty?[""]:user_id)
        .snapshots();
  }

  static String get_conversation_id(String id) =>
      (user.uid.hashCode <= id.hashCode)
      ? "${user.uid}_$id"
      : "${id}_${user.uid}";

  static Stream<QuerySnapshot<Map<String,dynamic>>> get_last_message(ChatUser user)
  {
    return fire_store
        .collection("chats/${get_conversation_id(user.id)}/messages/")
        .orderBy("sent",descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> update_profile_photo(File file) async
  {
    final ext=file.path.split(".").last;

    final ref=storage.ref().child("profile_pictures/${user.uid}.$ext");

    await ref.putFile(file,SettableMetadata(contentType: "image/$ext"));

    me.image=await ref.getDownloadURL();

    await fire_store
        .collection("users")
        .doc(user.uid)
        .update({"image":me.image});
  }

  static Stream<QuerySnapshot<Map<String,dynamic>>> get_user_info(ChatUser chat_user)
  {
    return
       fire_store
            .collection("users")
            .where("id",isEqualTo: chat_user.id)
            .snapshots();
  }

  static Stream<QuerySnapshot<Map<String,dynamic>>> get_all_messages(ChatUser user)
  {
    return
        fire_store
            .collection("chats/${get_conversation_id(user.id)}/messages/")
            .orderBy("sent",descending: true)
            .snapshots();
  }

  static Future<void> update_message_read_status(Message message) async
  {
    fire_store
        .collection("users/${get_conversation_id(message.fromId)}/messages/")
        .doc(message.sent)
        .update({"read":DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Future<void> update_message(Message message,String updated_message) async
  {
    await fire_store
        .collection("chats/${get_conversation_id(message.toId)}/messages/")
        .doc(message.sent)
        .update({"msg":updated_message});
  }

  static Future<void> delete_message(Message message) async
  {
    await fire_store
        .collection("chats/${get_conversation_id(message.toId)}/messages/")
        .doc(message.sent)
        .delete();

    if (message.type==Type.image)
      {
        await storage.refFromURL(message.msg).delete();
      }
  }

  static Future<void> send_push_notification(ChatUser chat_user,String msg) async
  {
    try{
      final body={
        "to":chat_user.pushToken,
        "notification":{
          "title":me.name,
          "body":msg,
          "android_channel_id":"chats"
        }
      };

      var res=await post(
          Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers:{
            HttpHeaders.contentTypeHeader:"application/json",
            HttpHeaders.authorizationHeader:
                "AAAAQsFoJXk:APA91bHBWWItP8fJmjGlQk9hZSDj7lKUsd3gYup5_Oa-cKDvB0Kf2cnI1CURrZtzx291MHUBfgCo8DNwSm29N8rpFKQFHZxi5WfkhQKNA0wdPwxkTFiuqqKRElVK4kiQQpVmwKpPYuhh",
          },
          body: jsonEncode(body)
      );
    }catch(e){
      print("error");
    }
  }

  static Future<void> send_message(ChatUser chat_user,String msg,Type type) async
  {
    final time=DateTime.now().millisecondsSinceEpoch.toString();

    final message=Message(
        toId: chat_user.id,
        msg: msg,
        read: "",
        type: type,
        fromId: user.uid,
        sent: time);


    final ref=fire_store.collection("chats/${get_conversation_id(chat_user.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) => send_push_notification(chat_user, msg));
  }

  static Future<void> send_chat_image(ChatUser user,File file)  async
  {
    final ext=file.path.split(".").last;

    final ref=storage
        .ref()
        .child("images/${get_conversation_id(user.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");

    await ref.putFile(file,SettableMetadata(contentType: "image/$ext"));

    final image_url=await ref.getDownloadURL();
    await send_message(user, image_url, Type.image);
  }

  static Future<void> send_first_message(ChatUser chat_user,String msg,Type type) async
  {
    await fire_store
        .collection("users")
        .doc(chat_user.id)
        .collection("my_users")
        .doc(user.uid)
        .set({}).then((value) => send_message(chat_user, msg, type));
  }

  static Future<void> update_user_info() async
  {
    await fire_store
        .collection("users")
        .doc(user.uid)
        .update({
      "name":me.name,
      "about":me.about
    });
  }

}