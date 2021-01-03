import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/quotation_form.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
import 'package:intl/intl.dart';
class QuotationDetails extends StatefulWidget {
  final String BookingID;
  QuotationDetails(this.BookingID, {Key key}): super(key: key);
  @override
  _QuotationDetailsState createState() => _QuotationDetailsState();
}

class _QuotationDetailsState extends State<QuotationDetails> {
  @override
  final _scrollController = ScrollController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        title: const Text('QUOTATION', style: TextStyle(
            color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
        )),
        backgroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar:
             Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 18),
              child:
              MaterialButton(
                elevation: 0,
                minWidth: double.maxFinite,
                height: 60,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QuotationForm(widget.BookingID)));

                },
                color: Color(0xFF13869f),
                child: Text('CONTINUE',
                    style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold)),
                textColor: Colors.white,
              ),
            ),

      body:
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: StreamBuilder(
            stream: getBookingDataSnapshots(context,widget.BookingID),
            builder: (context,AsyncSnapshot<List<QuotationData>> snapshot) {

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
                  return new ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                        children: snapshot.data.map((booking) {
                          return Scrollbar(
                            controller: _scrollController, // <---- Here, the controller
                            isAlwaysShown: true,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: new Column(
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
                                                  IconData(booking.icon, fontFamily: 'MaterialIcons'),
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

                                              Container(
                                                width: 200,
                                                child:
                                                Text(booking.service_name,
                                                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                                  overflow: TextOverflow.visible,softWrap: true,),
                                              ),

                                              Container(
                                                width: 200,
                                                child:
                                                Text(booking.customer_address,
                                                  style: TextStyle(fontSize: 12,color: Colors.grey[600]),
                                                  overflow: TextOverflow.visible,softWrap: true,),
                                              ),

                                              Text(
                          DateFormat('yyyy.MM.dd | HH:mm a').format(DateTime.parse(booking.schedule)).toString()
                                                  ,style: TextStyle(
                                                  fontSize: 12,color: Colors.grey[600]
                                              )),
                                            ],
                                          )


                                        ],

                                      ),
                                      Text("For Quotation"),
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
                                      Text("CUSTOMER NAME", style: TextStyle(
                                          fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                      )),
                                      SizedBox(height: 5),
                                      Text(booking.customer_name),
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
                                      Text(booking.customer_address),
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
                                      Text(booking.timeline +" "+ booking.timeline_type),
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
                                      Text("Price Type", style: TextStyle(
                                          fontSize: 12,color: Color(0xFF13869f),fontWeight: FontWeight.bold
                                      )),
                                      SizedBox(height: 5),
                                      Text(booking.booking ? "Open Price" : "Set Price"),
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
                                      Text(booking.form_values),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Divider(thickness:1,color: Colors.grey),
                                  SizedBox(height: 20),

                                  // MaterialButton(
                                  //   elevation: 0,
                                  //   minWidth: double.maxFinite,
                                  //   height: 60,
                                  //   onPressed: () {
                                  //
                                  //     Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(builder: (context) => QuotationForm(widget.BookingID)));
                                  //   },
                                  //   color: Color(0xFF13869f),
                                  //   child: Text('CONTINUE',
                                  //       style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold)),
                                  //   textColor: Colors.white,
                                  // ),
                                ],
                              ),
                            ),
                          );
                        }).toList()
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
  final booking;

  const QuotationData(this.icon,this.service_name,this.schedule,this.customer_name,this.customer_address,this.form_values,this.timeline,this.timeline_type,this.booking);
}


Stream<List<QuotationData>> getBookingDataSnapshots(BuildContext context,String BookingID) async* {
  var booking = await FirebaseFirestore.instance.collection('booking').doc(BookingID).get();
  var data = List<QuotationData>();
  var serviceOption = await FirebaseFirestore.instance.collection('service_option').doc(booking.get('service_option_id')).get();
      var BookingData;
  Map<String, dynamic> form_values = jsonDecode(booking.get('form_values'));

  final ListNextLine = form_values.toString().replaceAll(RegExp(','), '\n');
  final ListOpen = ListNextLine.replaceAll(RegExp('{'), '');
  final ListFinal = ListOpen.replaceAll(RegExp('}'), '');
  BookingData = QuotationData(
        serviceOption.get('icon'),
        serviceOption.get('name'),
        booking.get('schedule'),
        booking.get('customer_name'),
        booking.get('customer_address'),
        ListFinal,
        booking.get('timeline'),
        booking.get('timeline_type'),
        booking.get('open_booking'),
      );

      data.add(BookingData);


    yield data;


}