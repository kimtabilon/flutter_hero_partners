import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/job_details.dart';
import 'package:hero_partners/pages/quotation_details.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:intl/intl.dart';
class Quotation extends StatefulWidget {
  @override
  _QuotationState createState() => _QuotationState();
}

class _QuotationState extends State<Quotation> {
  @override
  final _scrollController = ScrollController();
  Widget build(BuildContext context) {
    return Scaffold(
      body:
        StreamBuilder<QuerySnapshot>(
            stream: getBookingDataSnapshots(context),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return const SpinKitDoubleBounce(
            color: Color(0xFF93ca68),
            size: 50.0);
      default:
        if (snapshot.hasError){
          return const SpinKitDoubleBounce(
              color: Color(0xFF93ca68),
              size: 50.0);
        }else if(snapshot.data.size == 0){
          return Container(
            child: Center(
                child: Container(
                  height: 400,
                  width:350,
                  child:  EmptyListWidget(
                      image : null,
                      packageImage: PackageImage.Image_1,
                      title: 'No Jobs',
                      subTitle: 'No jobs available yet',
                      titleTextStyle: Theme.of(context).typography.dense.headline4.copyWith(color: Color(0xFF93ca68)),
                      subtitleTextStyle: Theme.of(context).typography.dense.bodyText1.copyWith(color: Color(0xFF93ca68))
                  ),
                )
            ),
          );
        }else{
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: new ListView(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                children: snapshot.data.docs.map((booking) {

                  return FutureBuilder<bool>(
                    future: getExistingSnapshots(context,booking.id),
                    builder: (BuildContext context, AsyncSnapshot<bool> Checksnapshot) {

                      if(Checksnapshot.hasData){
                        if(Checksnapshot.data){

                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: new Column(
                              children: [
                                Container(
                                    child: StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance.collection('service_option')
                                            .doc(booking.get('service_option_id')).snapshots(),
                                        builder: (context, Servicesnapshot) {

                                          if (Servicesnapshot.connectionState == ConnectionState.waiting) {
                                            return const SpinKitDoubleBounce(
                                                color: Color(0xFF93ca68),
                                                size: 50.0);
                                          }
                                          return ListTile(
                                            contentPadding: EdgeInsets.all(10),
                                            dense: true,
                                            leading: Material(
                                                type: MaterialType.transparency,
                                                //Makes it usable on any background color, thanks @IanSmith
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Color(0xFF13869f), width: 2.0),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: InkWell(
                                                    //This keeps the splash effect within the circle
                                                    borderRadius: BorderRadius.circular(1000.0),
                                                    //Something large to ensure a circle
                                                    child: Padding(
                                                      padding: EdgeInsets.all(5.0),
                                                      child: Icon(
                                                        IconData(Servicesnapshot.data.get('icon'), fontFamily: 'MaterialIcons'),
                                                        size: 30.0,
                                                        color: Color(0xFF13869f),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ),
                                            title: Text(Servicesnapshot.data.get('name'), style: TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 18),),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(booking.get('customer_address')),
                                                Text(
                                                    DateFormat('yyyy.MM.dd | HH:mm a').format(DateTime.parse(booking.get('schedule'))).toString()
                                                ),
                                              ],
                                            ),
                                            trailing: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('For Quotation'),
                                              ],
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => QuotationDetails(booking.id)));
                                            },

                                          );
                                        }
                                    ),
                                    decoration:
                                    new BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 3,
                                            blurRadius: 3,
                                            offset: Offset(0, 3), // changes position of shadow
                                          ),
                                        ]
                                    )


                                ),



                              ],
                            ),
                          );


                        }

                      }

                      return Container();
                    },
                  );


                      














                }).toList()

            ),
          );
        }


    };
          }
        )
    );

  }
}


class BookingData {
  final BookingID;
  final ServiceName;
  final ServiceIcon;
  final CustomerAddress;
  final schedule;
  final queue;
  const BookingData(this.BookingID,this.ServiceName,this.ServiceIcon,this.CustomerAddress,this.schedule,this.queue);
}

Stream<QuerySnapshot> getBookingDataSnapshots(BuildContext context) async* {
  final uid = await Provider.of(context).auth.getCurrentUID();
  var HeroData = await FirebaseFirestore.instance.collection('hero').where('profile_id', isEqualTo: uid).get();
  //yield* FirebaseFirestore.instance.collection('booking').where('hero_id', isEqualTo: HeroData.docs[0].id).snapshots();

  yield*  FirebaseFirestore.instance.collection('booking').where('queue', isEqualTo: 'for_quotation').snapshots();
  
  // var data = List<BookingData>();
  // await for (var bookingSnapshot in booking) {
  //   for (var BookingDoc in bookingSnapshot.docs) {
  //     var OptionData;
  //     var serviceOption = await FirebaseFirestore.instance.collection(
  //         'service_option').doc(BookingDoc.get('service_option_id')).get();
  //
  //     var QuoteData = await FirebaseFirestore.instance.collection('quote')
  //         .where('hero_id', isEqualTo: HeroData.docs[0].id)
  //         .where('booking_id', isEqualTo: BookingDoc.id).get();
  //     if(QuoteData.docs.length ==  0) {
  //       OptionData = BookingData(
  //         BookingDoc.id,
  //         BookingDoc.get('service_option'),
  //         serviceOption.get('icon'),
  //         BookingDoc.get('customer_address'),
  //         BookingDoc.get('schedule'),
  //         'For Quotation',
  //       );
  //       data.add(OptionData);
  //     }
  //   }
  //   yield data;
  // }
}


Future<bool> getExistingSnapshots(BuildContext context,String BookingID) async {
  final uid = await Provider.of(context).auth.getCurrentUID();
  var HeroData = await FirebaseFirestore.instance.collection('hero').where('profile_id', isEqualTo: uid).get();
  var QuoteData = await FirebaseFirestore.instance.collection('quote')
      .where('hero_id', isEqualTo:HeroData.docs[0].id)
      .where('booking_id', isEqualTo: BookingID).get();
  if(QuoteData.docs.length ==  0) {
    return true;
  }else{
    return false;
  }

}