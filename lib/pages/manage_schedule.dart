import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/account.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:hero_partners/pages/manage_services.dart';
import 'package:hero_partners/pages/navigation.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
import 'package:hero_partners/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'block_dates.dart';

class ManageSchedule extends StatefulWidget {
 @override
  _ManageScheduleState createState() => _ManageScheduleState();
}



class _ManageScheduleState extends State<ManageSchedule> {
  final db = FirebaseFirestore.instance;
  @override
  final _scrollController = ScrollController();


  final formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {

    return FlutterEasyLoading(
      child: Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
              color: Colors.black
          ),
          title: const Text('MANAGE SCHEDULE', style: TextStyle(
              color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
          )),
          backgroundColor: Colors.white,
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Add block dates", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
                  SizedBox(height: 10),
                  RaisedButton(
                    padding: EdgeInsets.all(25),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.0),
                        side: BorderSide(color: Colors.black)
                    ),
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BlockDates()));

                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.play_arrow, color: Colors.black,),
                        Text('Select Dates', style: TextStyle(color: Colors.black),),

                      ],
                    ),
                  ),


                  SizedBox(height: 20),
                  Text("List of unavailable dates", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
                  StreamBuilder<QuerySnapshot>(
                    stream: getUserSettingSnapshots(context),
                    builder: (context, snapshot) {
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

                              String DateList = snapshot.data.docs[0].get('block_dates');

                              final ListOpen = DateList.replaceAll('[', '');
                              final List2nd = ListOpen.replaceAll(']', '');
                              final ListFinal = List2nd.replaceAll('"', '');
                              var Lists = ListFinal.split(',');
                              return Container(
                                height: 500,
                                child: Scrollbar(
                                  controller: _scrollController, // <---- Here, the controller
                                  isAlwaysShown: true,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                        children: ListFinal.split(',').map((e){
                                            return Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Container(
                                                child: Text(e,
                                                           style: TextStyle(color: Colors.black,
                                                               fontSize: 15)),
                                              ),
                                            );
                                        }).toList(),
                                    ),
                                  ),
                                ),
                              );
                          }


                      return Text("List of unavailable dates", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ));
                    }
                  ),
                ],
              ),
            ),



          ),
        ),
      ),
    );
  }
}

















_awesomeDialogError(String content,BuildContext context){
  AwesomeDialog(
      context: context,
      animType: AnimType.LEFTSLIDE,
      headerAnimationLoop: false,
      dialogType: DialogType.ERROR,
      title: 'Error',
      desc: content,
      btnOkOnPress: () {
      },
      btnOkIcon: Icons.cancel,
      onDissmissCallback: () {
        debugPrint('Dialog Dissmiss from callback');
      }).show();
}

Stream<QuerySnapshot> getUserSettingSnapshots(BuildContext context) async* {
  final uid = await Provider.of(context).auth.getCurrentUID();
  yield* FirebaseFirestore.instance.collection('hero_settings').where('profile_id', isEqualTo: uid).snapshots();
}