import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/account_client.dart';
import 'package:hero_partners/pages/chats.dart';
import 'package:hero_partners/pages/gmap.dart';
import 'package:hero_partners/pages/homepage.dart';
import 'package:hero_partners/pages/job.dart';
import 'package:hero_partners/pages/manage_jobs.dart';
import 'package:hero_partners/pages/manage_services.dart';
import 'package:intl/intl.dart';
final _formKey = GlobalKey<FormState>();
final TextEditingController reasonController = TextEditingController();
class ServiceDetails extends StatefulWidget {
  final String ServiceID;

  ServiceDetails(this.ServiceID, {Key key}): super(key: key);
  @override
  _ServiceDetailsState createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  @override
  final db = FirebaseFirestore.instance;
  final _scrollController = ScrollController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        title: const Text('DETAILS', style: TextStyle(
            color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
        )),
        backgroundColor: Colors.white,
      ),

      body:
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: StreamBuilder<DocumentSnapshot>(
              stream: getServiceDataSnapshots(context,widget.ServiceID),
              builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot) {


                if (snapshot.hasError)
                  return const SpinKitDoubleBounce(
                      color: Color(0xFF93ca68),
                      size: 50.0);
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const SpinKitDoubleBounce(
                        color: Color(0xFF93ca68),
                        size: 50.0);
                  default:
                    
                    
                          return Scrollbar(
                            controller: _scrollController, // <---- Here, the controller
                            isAlwaysShown: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance.collection('service_option')
                                    .doc(snapshot.data.get('service_option_id')).snapshots(),
                                builder: (context, AsyncSnapshot<DocumentSnapshot> Servicesnapshot) {



                                  if (Servicesnapshot.connectionState == ConnectionState.waiting) {
                                    return const SpinKitDoubleBounce(
                                        color: Color(0xFF93ca68),
                                        size: 50.0);
                                  }

                                  return new Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Ink(
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Color(0xFF13869f), width: 2.0),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: InkWell(
                                                  //This keeps the splash effect within the circle
                                                  borderRadius: BorderRadius.circular(1000.0), //Something large to ensure a circle
                                                  child: Padding(
                                                    padding:EdgeInsets.all(5.0),
                                                    child: Icon(
                                                      IconData(Servicesnapshot.data.get('icon'), fontFamily: 'MaterialIcons'),
                                                      size: 30.0,
                                                      color: Color(0xFF13869f),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(Servicesnapshot.data.get('name'),style: TextStyle(
                                                      fontSize: 20,fontWeight: FontWeight.bold
                                                  )),

                                                ],
                                              ),


                                            ],

                                          ),
                                          Text(snapshot.data.get('status'),style: TextStyle(
                                              fontWeight: FontWeight.bold,color: Color(0xFF93ca68))),
                                        ],

                                      ),
                                      SizedBox(height: 20),


                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 15),
                                              FlatButton(
                                                  minWidth: 150,
                                                  color: Colors.red,
                                                  onPressed: (){
                                                    AwesomeDialog(
                                                        context: context,
                                                        animType: AnimType.LEFTSLIDE,
                                                        headerAnimationLoop: false,
                                                        dialogType: DialogType.INFO,
                                                        title: 'Confirmation',
                                                        desc: 'Are you sure do you want to delete this service?',
                                                        btnOkOnPress: () {


                                                                Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => ManageServices(),
                                                                  ),
                                                                );
                                                                Navigator.of(context, rootNavigator: true).pop();

                                                                setState(() async {
                                                                  await db.collection('hero_services').doc(snapshot.data.id).delete();

                                                                });


                                                        },
                                                        btnCancelOnPress: () {
                                                          Navigator.of(context, rootNavigator: true).pop();
                                                        },
                                                        btnOkText: "Confirm",
                                                        onDissmissCallback: () {
                                                          debugPrint('Dialog Dissmiss from callback');
                                                        }).show();
                                                  },
                                                  child: Text("DELETE", style: TextStyle(
                                                    color: Colors.white,fontSize: 15.0,
                                                  ))),
                                            ],
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 20),
                                      Divider(thickness:1,color: Colors.grey),
                                      SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("Daily Rate", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(snapshot.data.get('daily_rate').toString()),
                                          SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("Hourly Rate", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(snapshot.data.get('hourly_rate').toString()),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Divider(thickness:1,color: Colors.grey),
                                      SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("Service Type", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(Servicesnapshot.data.get('service_type')),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Divider(thickness:1,color: Colors.grey),
                                      SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("Pricing", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Servicesnapshot.data.get('open_price') ? Text("Open Price") : Text("Set Price"),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Divider(thickness:1,color: Colors.grey),
                                      SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("Booking Type", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Servicesnapshot.data.get('multiple_booking') ? Text("Multi Booking") : Text("Single Booking"),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Divider(thickness:1,color: Colors.grey),
                                      SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("Min. Timeline", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(Servicesnapshot.data.get('min_timeline').toString()),
                                          SizedBox(height: 10),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("Max Timeline", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(Servicesnapshot.data.get('max_timeline').toString()),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Divider(thickness:1,color: Colors.grey),
                                      SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("DESCRIPTION", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(Servicesnapshot.data.get('description')),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Divider(thickness:1,color: Colors.grey),
                                      SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("INCLUSIONS", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(Servicesnapshot.data.get('inclusions')),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Divider(thickness:1,color: Colors.grey),
                                      SizedBox(height: 20),

                                    ],
                                  );
                                }
                              ),
                            ),
                          );


                }


              }
          ),
        ),
      ),


    );
  }
}

class QuotationData {
  final icon;
  final service_name;
  final schedule;
  final customer_name;
  final customer_address;
  final form_values;
  final timeline;
  final timeline_type;
  final queue;
  final reason;
  final customer_id;
  final service_option_id;
  final hero_id;
  const QuotationData(this.icon,this.service_name,this.schedule,this.customer_name,this.customer_address,this.form_values,this.timeline,this.timeline_type,this.queue,this.reason,this.customer_id,this.service_option_id,this.hero_id);
}

Stream<DocumentSnapshot> getServiceDataSnapshots(BuildContext context,String BookingID) async* {

  yield* FirebaseFirestore.instance.collection('hero_services').doc(BookingID).snapshots();
}


_TextAreaField(TextEditingController controller, String labelText){
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        color: Color(0xFFffffff).withOpacity(0.4)),
    child: TextFormField(
      keyboardType: TextInputType.multiline,
      minLines: 3,
      maxLines: 5,
      validator: (value) {
        if (value.isEmpty) {
          return 'This field is required.';
        }
        return null;
      },
      controller: controller,
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
          border: InputBorder.none),
    ),
  );
}