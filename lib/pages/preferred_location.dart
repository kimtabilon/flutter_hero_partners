import 'package:circular_check_box/circular_check_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/account.dart';
import 'package:hero_partners/pages/home.dart';
import 'package:hero_partners/pages/login.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hero_partners/pages/manage_services.dart';
import 'package:hero_partners/pages/navigation.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
import 'package:hero_partners/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:password_strength/password_strength.dart';
import 'package:philippines/city.dart';
import 'package:philippines/philippines.dart';
import 'package:philippines/province.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:toast/toast.dart';

import 'manage_jobs.dart';
class PreferredLocation extends StatefulWidget {
 @override
  _PreferredLocationState createState() => _PreferredLocationState();
}
final TextEditingController rateController = TextEditingController(text: '0');
final TextEditingController noteController = TextEditingController(text:'');



class _PreferredLocationState extends State<PreferredLocation> {
  final db = FirebaseFirestore.instance;
  @override
  final _scrollController = ScrollController();
  bool _isenabled = true;
  bool _firstload = true;
  bool _isButtonDisabled = false;
  bool selected=false ;
  int counter = 0;
  Map<String, dynamic> CitySelected = {};
  Map<String, dynamic> CitySaved = {};
  Map<String, bool> CityList = {};
  List<Province> _provinces = getProvinces();

  final formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {

    return FlutterEasyLoading(
      child: Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
              color: Colors.black
          ),
          title: const Text('PREFERRED LOCATION', style: TextStyle(
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
              if(CitySelected.isNotEmpty){
                try {
                  final uid = await Provider.of(context).auth.getCurrentUID();
                  var SettingDoc = await db.collection('hero_settings')
                      .where('profile_id', isEqualTo: uid).get();

                  await db.collection('hero_settings')
                      .doc(SettingDoc.docs[0].id)
                      .update({
                    'locations': CitySelected
                  });

                  EasyLoading.dismiss();


                  AwesomeDialog(
                      context: context,
                      animType: AnimType.LEFTSLIDE,
                      headerAnimationLoop: false,
                      dialogType: DialogType.SUCCES,
                      title: 'Success',
                      desc: 'Your Preferred Locations has been updated Successfully.',
                      btnOkOnPress: () {
                        setState(() {
                          rateController.text = "";
                          noteController.text = "";
                        });


                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageJobs(),
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
                Toast.show("Please select atleast 1 location", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
              }
            },
            color: Color(0xFF13869f),
            child: Text('SAVE',
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
                      Text("Check your preferred locations", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      )),


                      StreamBuilder<QuerySnapshot>(
                        stream: getUserSettingSnapshots(context),
                        builder: (context, snapshot) {

                            if (snapshot.hasError)
                            return Container();
                            switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Container();
                            default:

                              if(_firstload){
                                CitySelected = snapshot.data.docs[0].get('locations');
                              }
                              return Container(
                                padding:EdgeInsets.all(20) ,
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap:() {

                                        setState(() {
                                          _firstload =false;
                                          CitySelected.clear();
                                          CityList.forEach((k,v){
                                            CitySelected[k] = v;
                                          } );
                                        });
                                      },
                                      child:
                                      Row(
                                        children: [
                                          Text('CHECK ALL',
                                              style: TextStyle(
                                                decoration: TextDecoration.underline,
                                              )),
                                        ],
                                      ),

                                    ),
                                    Text(' / '),
                                    InkWell(
                                      onTap:() {

                                        setState(() {
                                          _firstload =false;
                                          CitySelected.clear();
                                        });
                                      },
                                      child:
                                      Row(
                                        children: [
                                          Text('UNCHECK ALL',
                                              style: TextStyle(
                                                decoration: TextDecoration.underline,
                                              )),
                                        ],
                                      ),

                                    ),
                                  ],
                                ),
                              );
                              return SizedBox(height: 15);
                            }
                        }
                      ),

                      StreamBuilder<QuerySnapshot>(
                          stream: getUserDataSnapshots(context),
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

                            List<City> _cities = getCities();
                            _provinces.map((value){
                              if(snapshot.data.docs[0].get('province') == value.name){
                                  _cities.removeWhere((city) => city.province != value.id);
                              }
                            }
                            ).toList();

                            // Map<String, bool> CityList = {};
                            _cities.map((value){

                              if(CitySelected.containsKey(value.name)){
                                CityList[value.name] = true;
                              }else{
                                CityList[value.name] = false;
                              }

                            }
                            ).toList();



                            return SafeArea(
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: ClampingScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 1,
                                childAspectRatio: 4,
                                children: _cities.map((Cityvalue) {


                                  return ListTile(
                                    leading: CircularCheckBox(
                                        value: CityList[Cityvalue.name],
                                        checkColor: Colors.white,
                                        activeColor: Colors.green,
                                        inactiveColor: Color(0xFF13869f),
                                        disabledColor: Colors.grey ,
                                        onChanged: (value) {
                                              setState(() {
                                                _firstload =false;
                                                  if(!CitySelected.containsKey(Cityvalue.name)){

                                                    CitySelected[Cityvalue.name] = value;
                                                  }else{
                                                    CitySelected.remove(Cityvalue.name);
                                                  }

                                              });
                                          },
                                    ),
                                    title: Text(Cityvalue.name),
                                    onTap: (){},
                                  );

                                  // return CheckboxListTile(
                                  //   controlAffinity: ListTileControlAffinity.leading,
                                  //   title: new Text(Cityvalue.name),
                                  //   value: CityList[Cityvalue.name],
                                  //   activeColor: Colors.deepPurple[400],
                                  //   checkColor: Colors.white,
                                  //   onChanged: (bool value) {
                                  //     setState(() {
                                  //       _firstload =false;
                                  //         if(!CitySelected.containsKey(Cityvalue.name)){
                                  //
                                  //           CitySelected[Cityvalue.name] = value;
                                  //         }else{
                                  //           CitySelected.remove(Cityvalue.name);
                                  //         }
                                  //
                                  //     });
                                  //   },
                                  // );
                                }).toList(),
                              ),


                            );

                          }


                        }
                      ),




                      SizedBox(height: 15),
                      // MaterialButton(
                      //   elevation: 0,
                      //   minWidth: double.maxFinite,
                      //   height: 60,
                      //   onPressed: _isButtonDisabled ? () {} : () async {
                      //
                      //       EasyLoading.show(status: 'loading...');
                      //       if(CitySelected.isNotEmpty){
                      //         try {
                      //           final uid = await Provider.of(context).auth.getCurrentUID();
                      //           var SettingDoc = await db.collection('hero_settings')
                      //               .where('profile_id', isEqualTo: uid).get();
                      //
                      //           await db.collection('hero_settings')
                      //               .doc(SettingDoc.docs[0].id)
                      //               .update({
                      //             'locations': CitySelected
                      //           });
                      //
                      //           EasyLoading.dismiss();
                      //
                      //
                      //           AwesomeDialog(
                      //               context: context,
                      //               animType: AnimType.LEFTSLIDE,
                      //               headerAnimationLoop: false,
                      //               dialogType: DialogType.SUCCES,
                      //               title: 'Success',
                      //               desc: 'Your Preferred Locations has been updated Successfully.',
                      //               btnOkOnPress: () {
                      //                 setState(() {
                      //                   rateController.text = "";
                      //                   noteController.text = "";
                      //                 });
                      //
                      //
                      //                 Navigator.pushReplacement(
                      //                   context,
                      //                   MaterialPageRoute(
                      //                     builder: (context) => ManageJobs(),
                      //                   ),
                      //                 );
                      //                 Navigator.of(context, rootNavigator: true).pop();
                      //                 //Navigator.pop(context);
                      //
                      //
                      //               },
                      //               btnOkIcon: Icons.check_circle,
                      //               onDissmissCallback: () {
                      //                 debugPrint('Dialog Dissmiss from callback');
                      //               }).show();
                      //
                      //         } catch (e) {
                      //           EasyLoading.dismiss();
                      //           formKey.currentState.reset();
                      //           _awesomeDialogError(
                      //               e,
                      //               context
                      //           );
                      //         }
                      //       }else{
                      //         EasyLoading.dismiss();
                      //         Toast.show("Please select atleast 1 location", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                      //       }
                      //
                      //
                      //       //
                      //
                      //
                      //
                      //   },
                      //   color: Color(0xFF13869f),
                      //   child: Text('SAVE',
                      //       style: TextStyle(color: Colors.white,
                      //           fontSize: 15,
                      //           fontWeight: FontWeight.bold)),
                      //   textColor: Colors.white,
                      // ),
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








_buildTextField(
    TextEditingController controller, String labelText) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    child: TextFormField(
      validator: (value) {

        return null;
      },
      readOnly: true,
      controller: controller,
      style: TextStyle(color: Colors.black,fontSize: 15),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.blue, fontSize:15,),
          // prefix: Icon(icon),
          ),
    ),
  );
}





_buildNumberField(
    TextEditingController controller, String labelText,bool isenabled) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    child: TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      enabled: isenabled,
      validator: (value) {

        if (value.isEmpty) {
          return 'This field is required.';
        }
        return null;
      },
      controller: controller,
      style: TextStyle(color: Colors.black,fontSize: 15),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.blue, fontSize:15,),
        // prefix: Icon(icon),
      ),
    ),
  );
}


_TextAreaField(TextEditingController controller, String labelText){
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
      style: TextStyle(color: Colors.black,fontSize: 15),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.blue, fontSize:15,),
        // prefix: Icon(icon),
      ),
    ),
  );
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

Stream<QuerySnapshot> getUserDataSnapshots(BuildContext context) async* {
  final uid = await Provider.of(context).auth.getCurrentUID();
  yield* FirebaseFirestore.instance.collection('address').where('profile_id', isEqualTo: uid).snapshots();
}

Stream<QuerySnapshot> getUserSettingSnapshots(BuildContext context) async* {
  final uid = await Provider.of(context).auth.getCurrentUID();
  yield* FirebaseFirestore.instance.collection('hero_settings').where('profile_id', isEqualTo: uid).snapshots();
}