import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat/dash_chat.dart';


class Chats extends StatefulWidget {

  final String BookingID;
  final String service_option_id;
  final String customer_id;
  final String hero_id;
  Chats(this.BookingID,this.service_option_id,this.customer_id,this.hero_id, {Key key}): super(key: key);
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {

  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection("booking").doc(widget.BookingID).snapshots(),
          builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            return RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: snapshot.data.get('customer_name'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      )),
                  TextSpan(text: '\n'),
                  TextSpan(
                    text: snapshot.data.get('service_option') +' • '
                    +DateFormat('yyyy.MM.dd | HH:mm a').format(DateTime.parse(snapshot.data.get('schedule'))).toString() ,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  )

                ],
              ),
            );
          }
        ),
        actions: [
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection("booking").doc(widget.BookingID).snapshots(),
              builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }
              return OutlineButton(
                child: Text('${snapshot.data.get('total')}.00 PHP\n${snapshot.data.get('timeline')} ${snapshot.data.get('timeline_type')}', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                onPressed: (){},
              );
            }
          )
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController, // <---- Here, the controller
          isAlwaysShown: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('chat')
                          .where('customer_id',isEqualTo: widget.customer_id)
                          .where('hero_id',isEqualTo: widget.hero_id)
                          .where('service_option_id', isEqualTo: widget.service_option_id)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, chatsnapshot) {
                        if (!chatsnapshot.hasData || chatsnapshot.data == null) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: chatsnapshot.hasData ? chatsnapshot.data.documents.length : 0,
                            itemBuilder: (context, chatindex) {
                              return _chatBubble(context, chatsnapshot.data.documents[chatindex]);
                              //return BookingTileWidget(booking: snapshot.data[index],);
                            },
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _sendMessageArea(context,widget.BookingID),
    );
  }
}

_chatBubble(context, DocumentSnapshot chat) {
  Alignment align = Alignment.topLeft;
  Color bgColor = Colors.white;
  Color textColor = Colors.black54;

  if(chat.get('from')!='client') {
    align = Alignment.topRight;
    bgColor = Colors.blue;
    textColor = Colors.white;
  }

  return Column(
    children: <Widget>[
      Container(
        alignment: align,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.80,
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200],
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Text(
            chat.get('message'),
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
      ),

    ],
  );

}

_sendMessageArea(context,String BookingID) {
  final db = FirebaseFirestore.instance;
  TextEditingController messageCtrl  = TextEditingController();
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8,vertical: 1),
    height: 70,
    color: Colors.white,
    child: Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: messageCtrl,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Send a message..',
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(20.0),
                borderSide: new BorderSide(),
              ),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          iconSize: 25,
          color: Colors.blue,
          onPressed: () async {

            var bookingSnapshot = await FirebaseFirestore.instance.collection("booking").doc(BookingID).get();

              await db.collection('chat').add({
                'from':'hero',
                'service_option_id':bookingSnapshot.get('service_option_id'),
                'service_option':bookingSnapshot.get('service_option'),
                'hero_id':bookingSnapshot.get('hero_id'),
                'hero_name':bookingSnapshot.get('hero_name'),
                'customer_id':bookingSnapshot.get('customer_id'),
                'customer_name':bookingSnapshot.get('customer_name'),
                'message':messageCtrl.text,
                'seen':false,
                'timestamp':DateTime.now(),
              });



            // ChatService().sendChat(
            //     booking.heroId,
            //     booking.heroName,
            //     booking.customerId,
            //     booking.customerName,
            //     booking.serviceOptionId,
            //     booking.serviceOption,
            //     messageCtrl.text
            // );
            messageCtrl.clear();
          },
        ),
      ],
    ),
  );
}