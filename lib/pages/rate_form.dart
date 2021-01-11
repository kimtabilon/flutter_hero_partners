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
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:toast/toast.dart';

import 'manage_jobs.dart';
class RateForm extends StatefulWidget {
  final String ProfileID;//if you have multiple values add here
  final String BookingID;
  final String HeroID;
  final String ClientName;
  RateForm(this.ProfileID,this.BookingID,this.HeroID,this.ClientName, {Key key}): super(key: key);
  @override
  _RateFormState createState() => _RateFormState();
}
final TextEditingController rateController = TextEditingController(text: '0');
final TextEditingController noteController = TextEditingController(text:'');



class _RateFormState extends State<RateForm> {
  final db = FirebaseFirestore.instance;
  @override

  bool _isenabled = true;
  bool _isButtonDisabled = false;
  final formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {

    return FlutterEasyLoading(
      child: Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
              color: Colors.black
          ),
          title: const Text('RATE CLIENT', style: TextStyle(
              color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
          )),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("REVIEW FORM ("+widget.ClientName+")", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )),
                  SizedBox(height: 25),
                  SmoothStarRating(
                      allowHalfRating: true,
                      onRated: (v) {

                        setState(() {
                          rateController.text = v.toString();
                        });

                      },
                      starCount: 5,
                      size: 40.0,
                      isReadOnly:false,
                      color: Colors.green,
                      borderColor: Colors.green,
                      spacing:0.0
                  ),
                  Text('Rate: '+rateController.text),
                  SizedBox(height: 15),
                  _TextAreaField(noteController, 'Comments'),
                  SizedBox(height: 15),
                  MaterialButton(
                    elevation: 0,
                    minWidth: double.maxFinite,
                    height: 60,
                    onPressed: _isButtonDisabled ? () {} : () async {
                      if (formKey.currentState.validate()) {

                        EasyLoading.show(status: 'loading...');
                        if(rateController.text != "0"){
                          try {

                            await db.collection('customer_review').add(
                                {
                                  'booking_id': widget.BookingID,
                                  'customer_id': widget.ProfileID,
                                  'hero_id': widget.HeroID,
                                  'rating':rateController.text,
                                  'comment':noteController.text,
                                }
                            );
                            EasyLoading.dismiss();


                            AwesomeDialog(
                                context: context,
                                animType: AnimType.LEFTSLIDE,
                                headerAnimationLoop: false,
                                dialogType: DialogType.SUCCES,
                                title: 'Success',
                                desc: 'Your Review has been Successfully Submitted.',
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
                          Toast.show("Please input a rating.", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                        }


                        //


                      }
                    },
                    color: Color(0xFF13869f),
                    child: Text('SUBMIT',
                        style: TextStyle(color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    textColor: Colors.white,
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

Stream<DocumentSnapshot> getBookingDataSnapshots(BuildContext context,String ProfileID) async* {

  yield*  FirebaseFirestore.instance.collection('customer').doc(ProfileID).snapshots();

}