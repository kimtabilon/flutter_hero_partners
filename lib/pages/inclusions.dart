import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/service_form.dart';

class Inclusions extends StatefulWidget {

  final String OptionID;//if you have multiple values add here
  Inclusions(this.OptionID, {Key key}): super(key: key);//add also..example this.abc,this...

  @override
  _InclusionsState createState() => _InclusionsState();
}

class _InclusionsState extends State<Inclusions> {
  @override
  final _scrollController = ScrollController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        title: const Text('INCLUSIONS', style: TextStyle(
            color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
        )),
        backgroundColor: Colors.white,
      ),
      body:
      SafeArea(
        child:
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Inclusions",style: TextStyle(
                  fontSize: 20,fontWeight: FontWeight.bold
              )),
              SizedBox(height: 5),
              Text("Please read the following instructions",style: TextStyle(
                color: Colors.grey,
              )),


              StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('service_option').doc(widget.OptionID).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {

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
                      var OptionDocument = snapshot.data.data;
                      return Expanded(
                        child: Scrollbar(
                          controller: _scrollController,
                          // <---- Here, the controller
                          isAlwaysShown: true,
                          // <---- Required
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(1, 20, 1, 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(OptionDocument()['inclusions']),
                                  SizedBox(height: 20),
                                  MaterialButton(
                                    elevation: 0,
                                    minWidth: double.maxFinite,
                                    height: 60,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => ServiceForm(
                                              widget.OptionID,OptionDocument()['service_type']
                                          )));

                                    },
                                    color: Color(0xFF13869f),
                                    child: Text('ACCEPT',
                                        style: TextStyle(color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    textColor: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                  }
                }
              )


            ],
          ),
        ),
      ),
    );
  }
}

