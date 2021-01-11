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
import 'package:hero_partners/pages/setting.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
import 'package:hero_partners/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
class BlockDates extends StatefulWidget {
 @override
  _BlockDatesState createState() => _BlockDatesState();
}



class _BlockDatesState extends State<BlockDates> {
  final db = FirebaseFirestore.instance;
  @override
  final _scrollController = ScrollController();
  DateRangePickerController _datePickerController;
  List<String> selectedDates = [];
  final formKey = GlobalKey<FormState>();

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    selectedDates.clear();
     // selectedDates.add(args.value.toString());
    args.value.map((e){
      String MonthText,DayText;
      if(e.month < 10){
        MonthText = '0' + e.month.toString();
      }else{
        MonthText = e.month.toString();
      }
      if(e.day < 10){
        DayText = '0' + e.day.toString();
      }else{
        DayText = e.day.toString();
      }
      selectedDates.add('"'+e.year.toString()+"-"+MonthText+"-"+DayText+'"');
    }).toString();
    print(selectedDates);
  }




  Widget build(BuildContext context) {

    return FlutterEasyLoading(
      child: Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
              color: Colors.black
          ),
          title: const Text('ADD BLOCK DATES', style: TextStyle(
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
            onPressed: () async {
              EasyLoading.show(status: 'loading...');
              if(selectedDates.isNotEmpty){
                try {
                  final uid = await Provider.of(context).auth.getCurrentUID();
                  var SettingDoc = await db.collection('hero_settings')
                      .where('profile_id', isEqualTo: uid).get();

                  await db.collection('hero_settings')
                      .doc(SettingDoc.docs[0].id)
                      .update({
                    'block_dates': selectedDates.toString()
                  });

                  EasyLoading.dismiss();


                  AwesomeDialog(
                      context: context,
                      animType: AnimType.LEFTSLIDE,
                      headerAnimationLoop: false,
                      dialogType: DialogType.SUCCES,
                      title: 'Success',
                      desc: 'Your Block Dates has been updated Successfully.',
                      btnOkOnPress: () {


                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Setting(),
                          ),
                        );
                        Navigator.of(context, rootNavigator: true).pop();
                        //Navigator.pop(context);


                      },
                      btnOkIcon: Icons.check_circle,
                      onDissmissCallback: () {
                        debugPrint('Dialog Dissmiss from callback');
                      }).show();

                } catch (e) {
                  EasyLoading.dismiss();
                  formKey.currentState.reset();
                  _awesomeDialogError(
                      e,
                      context
                  );
                }
              }else{
                EasyLoading.dismiss();
                Toast.show("Please select atleast 1 date", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);

              }
            },
            color: Color(0xFF13869f),
            child: Text('BLOCK THE DATE/S',
                style: TextStyle(color: Colors.white, fontSize: 18,fontWeight: FontWeight.bold)),
            textColor: Colors.white,
          ),
        ),
        body: SafeArea(
          child: Scrollbar(
            controller: _scrollController, // <---- Here, the controller
            isAlwaysShown: true,
            child: SingleChildScrollView(
              controller: _scrollController,
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
                      SizedBox(height: 20),
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

                                _datePickerController = DateRangePickerController ();
                                List<DateTime> DateList = [];
                                if(snapshot.data.docs[0].get('block_dates') != ""){
                                  var ab = json.decode(snapshot.data.docs[0].get('block_dates'));
                                  ab.map((e){
                                    print(e);
                                    DateList.add(DateTime.parse(e));
                                  }).toList();
                                  _datePickerController.selectedDates =DateList;
                                }


                                return SfDateRangePicker(
                                  onSelectionChanged: _onSelectionChanged,
                                  selectionMode: DateRangePickerSelectionMode.multiple,
                                  controller: _datePickerController,
                                );

                            }



                        }
                      ),
                    ],
                  ),
                ),



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