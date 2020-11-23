import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/account_client.dart';
import 'package:hero_partners/pages/chats.dart';
import 'package:hero_partners/pages/chats_admin.dart';
import 'package:hero_partners/pages/gmap.dart';
import 'package:hero_partners/pages/job.dart';
import 'package:hero_partners/pages/manage_jobs.dart';
import 'package:intl/intl.dart';
final _formKey = GlobalKey<FormState>();
final TextEditingController reasonController = TextEditingController();
class JobDetails extends StatefulWidget {
  final String BookingID;

  JobDetails(this.BookingID, {Key key}): super(key: key);
  @override
  _JobDetailsState createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {
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
              stream: getBookingDataSnapshots(context,widget.BookingID),
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

                          bool confirm_status = false;
                          bool active_status = false;
                          bool completed_status = false;
                          bool cancelled_status = false;
                          var queueDetails;
                          if(snapshot.data.get('queue') == "for_confirmation" ){
                            queueDetails = "For Confirmation";
                            confirm_status = true;
                          }else if(snapshot.data.get('queue') == "active"){
                            queueDetails = "Active";
                            active_status = true;
                          }else if(snapshot.data.get('queue') == "completed"){
                            queueDetails = "Completed";
                            completed_status = true;
                          }else if(snapshot.data.get('queue') == "cancelled"){
                            queueDetails = "Cancelled";
                            cancelled_status = true;
                          }
                          return Scrollbar(
                            controller: _scrollController, // <---- Here, the controller
                            isAlwaysShown: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance.collection('service_option')
                                    .doc(snapshot.data.get('service_option_id')).snapshots(),
                                builder: (context, AsyncSnapshot<DocumentSnapshot> Servicesnapshot) {

                                  Map<String, dynamic> form_values = jsonDecode(snapshot.data.get('form_values'));
                                  final ListNextLine = form_values.toString().replaceAll(RegExp(','), '\n');
                                  final ListOpen = ListNextLine.replaceAll(RegExp('{'), '');
                                  final ListFinal = ListOpen.replaceAll(RegExp('}'), '');


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
                                                  Text(snapshot.data.get('customer_address'),style: TextStyle(
                                                      fontSize: 12,color: Colors.grey[600]
                                                  )),
                                                  Text(
                                  DateFormat('yyyy.MM.dd | HH:mm a').format(DateTime.parse(snapshot.data.get('schedule'))).toString()
                                                      ,style: TextStyle(
                                                      fontSize: 12,color: Colors.grey[600]
                                                  )),
                                                ],
                                              )


                                            ],

                                          ),


                                          Text(queueDetails,style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                        ],

                                      ),
                                      SizedBox(height: 20),

                                      FlatButton(
                                          minWidth:250,
                                          color: Color(0xFF13869f),
                                          onPressed: (){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => AccountClient(snapshot.data.get('customer_id'))));
                                          },
                                          child: Text("CLIENT PROFILE", style: TextStyle(
                                            color: Colors.white,fontSize: 12.0,
                                          ))),

                                      SizedBox(height: 10),




                                      //for_confirmation
                                      confirm_status ?
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [

                                              FlatButton(
                                                  minWidth: 150,
                                                  color: Color(0xFF13869f),
                                                  onPressed: (){
                                                    AwesomeDialog(
                                                        context: context,
                                                        animType: AnimType.LEFTSLIDE,
                                                        headerAnimationLoop: false,
                                                        dialogType: DialogType.INFO,
                                                        title: 'Confirmation',
                                                        desc: 'Are you sure do you want to accept this job?',
                                                        btnOkOnPress: () {

                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => ManageJobs(),
                                                            ),
                                                          );
                                                          Navigator.of(context, rootNavigator: true).pop();

                                                          setState(() async {
                                                            await db.collection('booking').doc(widget.BookingID)
                                                                .update({
                                                              'queue': 'active',
                                                            });


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
                                                  child: Text("ACCEPT", style: TextStyle(
                                                    color: Colors.white,fontSize: 15.0,
                                                  ))),
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
                                                        desc: 'Are you sure do you want to deny this job?',
                                                        btnOkOnPress: () {
                                                              if (_formKey.currentState.validate()) {


                                                                Navigator.pushReplacement(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => ManageJobs(),
                                                                  ),
                                                                );
                                                                Navigator.of(context, rootNavigator: true).pop();

                                                                setState(() async {
                                                                  await db.collection('booking').doc(widget.BookingID)
                                                                      .set({
                                                                    'queue': 'cancelled',
                                                                    'reason': reasonController.text,
                                                                  },SetOptions(merge: true));




                                                                });

                                                              }
                                                        },
                                                        btnCancelOnPress: () {
                                                          Navigator.of(context, rootNavigator: true).pop();
                                                        },
                                                        body: Form(
                                                          key: _formKey,
                                                          child: Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Column(
                                                              children: <Widget>[
                                                                Text('Are you sure do you want to deny this job?'),
                                                                SizedBox(height: 10,),
                                                                _TextAreaField(reasonController, "Reason"),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        btnOkText: "Confirm",
                                                        onDissmissCallback: () {
                                                          debugPrint('Dialog Dissmiss from callback');
                                                        }).show();
                                                  },
                                                  child: Text("DENY", style: TextStyle(
                                                    color: Colors.white,fontSize: 15.0,
                                                  ))),
                                            ],
                                          ),
                                        ],
                                      ) : Container(),


                                      //active
                                      active_status ?
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              FlatButton(
                                                  color: Color(0xFF13869f),
                                                  onPressed: (){
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(builder: (context) => GMap(snapshot.data.get('customer_address'))));
                                                  },
                                                  child: Text("GET DIRECTIONS", style: TextStyle(
                                                    color: Colors.white,fontSize: 12.0,
                                                  ))),
                                              SizedBox(width: 10),
                                              FlatButton(
                                                  color: Color(0xFF13869f),
                                                  onPressed: (){
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => Chats(
                                                            widget.BookingID,
                                                            snapshot.data.get('service_option_id'),
                                                            snapshot.data.get('customer_id'),
                                                            snapshot.data.get('hero_id'))));
                                                  },
                                                  child: Text("CHAT WITH CLIENT", style: TextStyle(
                                                    color: Colors.white,fontSize: 12.0,
                                                  ))),

                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          FlatButton(
                                              minWidth:250,
                                              color: Color(0xFF13869f),
                                              onPressed: (){
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => ChatsAdmin(
                                                        widget.BookingID,
                                                        snapshot.data.get('service_option_id'),
                                                        snapshot.data.get('customer_id'),
                                                        snapshot.data.get('hero_id'))));
                                              },
                                              child: Text("CHAT WITH ADMIN", style: TextStyle(
                                                color: Colors.white,fontSize: 12.0,
                                              ))),


                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              FlatButton(
                                                  minWidth: 125,
                                                  color: Color(0xFF93ca68),
                                                  onPressed: (){
                                                    AwesomeDialog(
                                                        context: context,
                                                        animType: AnimType.LEFTSLIDE,
                                                        headerAnimationLoop: false,
                                                        dialogType: DialogType.INFO,
                                                        title: 'Confirmation',
                                                        desc: 'Are you sure do you want to complete this job?',
                                                        btnOkOnPress: () {

                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => ManageJobs(),
                                                            ),
                                                          );
                                                          Navigator.of(context, rootNavigator: true).pop();

                                                          setState(() async {
                                                            await db.collection('booking').doc(widget.BookingID)
                                                                .update({
                                                              'queue': 'completed',
                                                            });

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
                                                  child: Text("COMPLETE", style: TextStyle(
                                                    color: Colors.white,fontSize: 12.0,
                                                  ))),
                                              SizedBox(width: 10),
                                              FlatButton(
                                                  minWidth: 125,
                                                  color: Color(0xFFff0000),
                                                  onPressed: (){
                                                    AwesomeDialog(
                                                        context: context,
                                                        animType: AnimType.LEFTSLIDE,
                                                        headerAnimationLoop: false,
                                                        dialogType: DialogType.INFO,
                                                        title: 'Confirmation',
                                                        desc: 'Are you sure do you want to cancel this job?',
                                                        btnOkOnPress: () {

                                                          Navigator.pushReplacement(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => ManageJobs(),
                                                            ),
                                                          );
                                                          Navigator.of(context, rootNavigator: true).pop();


                                                          setState(() async {
                                                            await db.collection('booking').doc(widget.BookingID)
                                                                .set({
                                                              'queue': 'cancelled',
                                                              'reason': 'Client did not show.',
                                                            },SetOptions(merge: true));


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
                                                  child: Text("NO SHOW", style: TextStyle(
                                                    color: Colors.white,fontSize: 12.0,
                                                  ))),

                                            ],
                                          ),

                                        ],

                                      ) : Container(),


                                      //for_cancelled
                                      cancelled_status ?
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 20),
                                          Divider(thickness:1,color: Colors.grey),
                                          SizedBox(height: 20),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("REASON FOR CANCELLATION", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(snapshot.data.get('reason')),
                                        ],
                                      ) : Container(),








                                      SizedBox(height: 20),
                                      Divider(thickness:1,color: Colors.grey),
                                      SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                          ),
                                          Text("CUSTOMER NAME", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(snapshot.data.get('customer_name')),
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
                                          Text("ADDRESS", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(snapshot.data.get('customer_address')),
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
                                          Text("DURATION", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(snapshot.data.get('timeline') +" "+ snapshot.data.get('timeline_type')),
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
                                          Text("DETAILS", style: TextStyle(
                                              fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                          )),
                                          SizedBox(height: 5),
                                          Text(ListFinal),
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

Stream<DocumentSnapshot> getBookingDataSnapshots(BuildContext context,String BookingID) async* {

  yield* FirebaseFirestore.instance.collection('booking').doc(BookingID).snapshots();
  // var data = List<QuotationData>();
  // var serviceOption = await FirebaseFirestore.instance.collection('service_option').doc(booking.get('service_option_id')).get();
  // var BookingData;
  // Map<String, dynamic> form_values = jsonDecode(booking.get('form_values'));
  // final ListNextLine = form_values.toString().replaceAll(RegExp(','), '\n');
  // final ListOpen = ListNextLine.replaceAll(RegExp('{'), '');
  // final ListFinal = ListOpen.replaceAll(RegExp('}'), '');
  //
  // var ReasonData = "";
  // try{
  //    ReasonData = booking.get('reason');
  // }catch(e){}
  // BookingData = QuotationData(
  //   serviceOption.get('icon'),
  //   serviceOption.get('name'),
  //   booking.get('schedule'),
  //   booking.get('customer_name'),
  //   booking.get('customer_address'),
  //   ListFinal,
  //   booking.get('timeline'),
  //   booking.get('timeline_type'),
  //   booking.get('queue'),
  //   ReasonData,
  //   booking.get('customer_id'),
  //   booking.get('service_option_id'),
  //   booking.get('hero_id'),
  // );
  //
  // data.add(BookingData);
  // yield data;
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