import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/category.dart';
import 'package:hero_partners/pages/manage_services.dart';
import 'package:hero_partners/pages/service_details.dart';
import 'package:hero_partners/pages/services.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
import 'package:toast/toast.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class ServiceOptionData {
  final OptionID;
  final OptionName;
  final OptionDescription;
  final OptionIcon;
  final OptionStatus;
  const ServiceOptionData(this.OptionID,this.OptionName,this.OptionDescription,this.OptionIcon,this.OptionStatus);
}

Stream<QuerySnapshot> getServiceSnapshots(BuildContext context) async* {
  final uid = await Provider.of(context).auth.getCurrentUID();
  yield* FirebaseFirestore.instance.collection('hero_services').where('profile_id', isEqualTo: uid).snapshots();

  // var data = List<ServiceOptionData>();
  // await for (var servicesSnapshot in services) {
  //   for (var ServiceDoc in servicesSnapshot.docs) {
  //
  //     var servicesOption = await FirebaseFirestore.instance.collection('service_option').doc(ServiceDoc.get('service_option_id')).get();
  //     var OptionData;
  //     OptionData = ServiceOptionData(
  //         servicesOption.id,
  //         servicesOption.get("name"),
  //         servicesOption.get("description"),
  //         servicesOption.get("icon"),
  //         ServiceDoc.get('status')
  //     );
  //     data.add(OptionData);
  //   }
  //   yield data;
  // }

}


class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: FutureBuilder<bool>(
          future: getExistingSnapshots(context),
        builder: (context, AsyncSnapshot<bool> snapshot) {

          return Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 18),
            child:
            MaterialButton(
              elevation: 0,
              minWidth: double.maxFinite,
              height: 60,
              onPressed: () {
                if(snapshot.data != false){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Category()));
                }else{

                  Toast.show("Please provide your Full Address in Account Settings.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.CENTER);

                }


              },
              color: Color(0xFF13869f),
              child: Text('ADD A SERVICE',
                  style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold)),
              textColor: Colors.white,
            ),
          );
        }
      ),
      body:
      SafeArea(
        child:
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text("My Services",style: TextStyle(
                //     fontSize: 20,fontWeight: FontWeight.bold
                // )),
                SizedBox(height: 5),
                Text("List of services that you can offer",style: TextStyle(
                    color: Colors.grey,
                )),


                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    isAlwaysShown: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(1, 20, 1, 5),
                        child: Column(
                          children: [
                            StreamBuilder <QuerySnapshot>(
                              stream: getServiceSnapshots(context),
                              builder: (context,AsyncSnapshot<QuerySnapshot> OptionSnapshot) {
                                if (OptionSnapshot.hasError)
                                return const SpinKitDoubleBounce(
                                color: Color(0xFF93ca68),
                                size: 50.0);
                                switch (OptionSnapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return const SpinKitDoubleBounce(
                                        color: Color(0xFF93ca68),
                                        size: 50.0);
                                  default:
                                    return Container(
                                      child: ListView(
                                        physics: ClampingScrollPhysics(),
                                        shrinkWrap: true,
                                        children: OptionSnapshot.data.docs.map((DocumentSnapshot  Option) {
                                          return StreamBuilder<DocumentSnapshot>(
                                            stream: FirebaseFirestore.instance.collection('service_option')
                                                .doc(Option.data()['service_option_id']).snapshots(),
                                            builder: (context, AsyncSnapshot<DocumentSnapshot> ServiceDetailssnapshot) {

                                              if (ServiceDetailssnapshot.connectionState == ConnectionState.waiting) {
                                                return Container();
                                              }

                                              return new Column(
                                                  children: [
                                                    Container(
                                                        child: ListTile(
                                                          contentPadding:  EdgeInsets.all(10),
                                                          dense: true,
                                                          leading: Material(
                                                              type: MaterialType.transparency, //Makes it usable on any background color, thanks @IanSmith
                                                              child: Ink(
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
                                                                      IconData(ServiceDetailssnapshot.data.get('icon'), fontFamily: 'MaterialIcons'),
                                                                      size: 30.0,
                                                                      color: Color(0xFF13869f),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                          ),
                                                          title: Text(ServiceDetailssnapshot.data.get('name'),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                                          subtitle: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: <Widget>[
                                                              //Text(_selected[widget._countindex].toString()),
                                                              Text(ServiceDetailssnapshot.data.get('description')),
                                                            ],
                                                          ),
                                                          trailing: Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: [
                                                              Text(Option.data()['status'], style: TextStyle(
                                                                  color: Color(0xFF93ca68)
                                                              )),
                                                              // Text("For quotation", style: TextStyle(
                                                              //     color: Color(0xFF93ca68)
                                                              // )),
                                                            ],
                                                          ),
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(builder: (context) => ServiceDetails(Option.id)));
                                                          },
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
                                                    SizedBox(height: 10),
                                                  ]
                                              );
                                            }
                                          );
                                        }).toList(),

                                      ),
                                    );
                                }
                              }
                            ),



                          ],
                        ),
                      ),
                    ),
                  ),
                )


              ],
            ),
          ),
      ),
    );
  }
}


Future<bool> getExistingSnapshots(BuildContext context) async {
  final uid = await Provider.of(context).auth.getCurrentUID();
  var HeroData = await FirebaseFirestore.instance.collection('address').where('profile_id', isEqualTo: uid).get();
  if(HeroData.docs[0].get('province') !=  "") {
    return true;
  }else{
    return false;
  }

}