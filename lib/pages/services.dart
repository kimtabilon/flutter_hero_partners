
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/inclusions.dart';
import 'package:hero_partners/widgets/provider_widget.dart';

class Services extends StatefulWidget {

  final String CategoryID;//if you have multiple values add here
  Services(this.CategoryID, {Key key}): super(key: key);//add also..example this.abc,this...


  @override
  _ServicesState createState() => _ServicesState();
}

class ServiceOptionData {
  final OptionID;
  final OptionName;
  final OptionDescription;
  final OptionIcon;
  const ServiceOptionData(this.OptionID,this.OptionName,this.OptionDescription,this.OptionIcon);
}

Stream<QuerySnapshot> getServiceSnapshots(BuildContext context,String CategoryID) async* {
  yield* FirebaseFirestore.instance.collection('service').where('service_category_id', isEqualTo: CategoryID).snapshots();
  // var services = FirebaseFirestore.instance.collection('service').where('service_category_id', isEqualTo: CategoryID).snapshots();
  //
  // var data = List<ServiceOptionData>();
  // await for (var servicesSnapshot in services) {
  //   for (var ServiceDoc in servicesSnapshot.docs) {
  //     var servicesOption = await FirebaseFirestore.instance.collection('service_option').where('service_id', isEqualTo: ServiceDoc.id).get();
  //     for (var ServicesOptionDoc in servicesOption.docs) {
  //       var OptionData;
  //       OptionData = ServiceOptionData(
  //           ServicesOptionDoc.id,
  //           ServicesOptionDoc.get("name"),
  //           ServicesOptionDoc.get("description"),
  //           ServicesOptionDoc.get("icon")
  //       );
  //       data.add(OptionData);
  //     }
  //   }
  //   yield data;
  // }

}


class _ServicesState extends State<Services> {

  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        title: const Text('ADD A SERVICE', style: TextStyle(
            color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
        )),
        backgroundColor: Colors.white,
      ),
      body:
      StreamBuilder <QuerySnapshot>(
          stream: getServiceSnapshots(context,widget.CategoryID),
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
                return SafeArea(
                  child:
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Choose a Service", style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold
                        )),
                        SizedBox(height: 5),
                        Text(
                            "Choose a service that you will be offering to clients.",
                            style: TextStyle(
                              color: Colors.grey,
                            )),


                        Padding(
                          padding: const EdgeInsets.fromLTRB(1, 20, 1, 5),
                          child: Column(
                            children: [
                              Scrollbar(
                                controller: _scrollController, // <---- Here, the controller
                                isAlwaysShown: true, //
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: ListView(
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    children: OptionSnapshot.data.docs.map((DocumentSnapshot Option) {
                                      return StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance.collection('service_option')
                                            .where('service_id', isEqualTo: Option.id).snapshots(),
                                        builder: (context, AsyncSnapshot<QuerySnapshot> ServiceOptionsnapshot) {
                                          if (ServiceOptionsnapshot.connectionState == ConnectionState.waiting) {
                                            return const SpinKitDoubleBounce(
                                                color: Color(0xFF93ca68),
                                                size: 50.0);
                                          }



                                          return Container(
                                            child: ListView(
                                              physics: ClampingScrollPhysics(),
                                              shrinkWrap: true,
                                              children: ServiceOptionsnapshot.data.docs.map((DocumentSnapshot  ServiceOptionsnapshot) {


                                                return FutureBuilder<bool>(
                                                    future: getExistingSnapshots(context,ServiceOptionsnapshot.id),
                                                    builder: (BuildContext context, AsyncSnapshot<bool> Checksnapshot) {

                                                      if(Checksnapshot.hasData){
                                                        if(Checksnapshot.data) {
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
                                                                                  IconData(ServiceOptionsnapshot.get('icon'), fontFamily: 'MaterialIcons'),
                                                                                  size: 30.0,
                                                                                  color: Color(0xFF13869f),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                      ),
                                                                      title: Text(ServiceOptionsnapshot.get('name'),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                                                      subtitle: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: <Widget>[
                                                                          //Text(_selected[widget._countindex].toString()),
                                                                          Text(ServiceOptionsnapshot.get('description')),
                                                                        ],
                                                                      ),
                                                                      trailing: Column(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.end,

                                                                        children: [
                                                                        ],
                                                                      ),
                                                                      onTap: () {
                                                                        Navigator.push(context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) =>
                                                                                    Inclusions(ServiceOptionsnapshot.id)));

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
                                                      }

                                                      return Container();
                                                    }
                                                );



                                              }).toList(),

                                            ),
                                          );



                                        }
                                      );
                                    }).toList(),

                                  ),
                                ),
                              ),


                              // SizedBox(height: 10),
                              // MaterialButton(
                              //   elevation: 0,
                              //   minWidth: double.maxFinite,
                              //   height: 60,
                              //   onPressed: () {
                              //     Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //             builder: (context) =>
                              //                 Inclusions()));
                              //   },
                              //   color: Color(0xFF13869f),
                              //   child: Text('ADD THIS SERVICE',
                              //       style: TextStyle(color: Colors.white,
                              //           fontSize: 18,
                              //           fontWeight: FontWeight.bold)),
                              //   textColor: Colors.white,
                              // ),
                            ],
                          ),

                        )


                      ],
                    ),
                  ),
                );
            }
          }
      ),
    );
  }
}



class buildServiceList extends StatefulWidget {
  @override
  DocumentSnapshot _category;
  int _snaplength;
  int _countindex;

  buildServiceList(DocumentSnapshot category, int snaplength, int countindex) {
    _category = category;
    _snaplength = snaplength;
    _countindex = countindex;
  }

  _buildServiceListState createState() => _buildServiceListState();
}

class _buildServiceListState extends State<buildServiceList> {
  @override
  Widget build(BuildContext context) {
      List<bool> _selected = List.generate(widget._snaplength, (i) => false);
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
                            IconData(widget._category.data()['icon'], fontFamily: 'MaterialIcons'),
                            size: 30.0,
                            color: Color(0xFF13869f),
                          ),
                        ),
                      ),
                    )
                ),
                title: Text(widget._category.data()['name'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //Text(_selected[widget._countindex].toString()),
                    Text(widget._category.data()['description']),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                  ],
                ),
                onTap: () {
                  setState(() {

                    _selected[widget._countindex] = !_selected[widget._countindex];
                  });

                },

              ),
              decoration:
              new BoxDecoration(
                  color: _selected[widget._countindex] ? Colors.blue : Colors.white,
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



        ],

      );
  }
}


Future<bool> getExistingSnapshots(BuildContext context,String ServiceOptionID) async {
  final uid = await Provider.of(context).auth.getCurrentUID();
  var HeroData = await FirebaseFirestore.instance.collection('hero_services')
      .where('profile_id', isEqualTo: uid)
      .where('service_option_id', isEqualTo: ServiceOptionID).get();
  if(HeroData.docs.length ==  0) {
    return true;
  }else{
    return false;
  }

}