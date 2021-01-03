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
class QuotationForm extends StatefulWidget {
  final String BookingID;//if you have multiple values add here
  QuotationForm(this.BookingID, {Key key}): super(key: key);
  @override
  _QuotationFormState createState() => _QuotationFormState();
}
final TextEditingController rateController = TextEditingController();
final TextEditingController noteController = TextEditingController(text:'');



class _QuotationFormState extends State<QuotationForm> {
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
          title: const Text('QUOTATION', style: TextStyle(
              color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
          )),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder(
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
                        rateController.text = snapshot.data.get('total');

                        if(snapshot.data.get('open_booking') == false){
                          _isenabled = false;
                        }else{
                          _isenabled = true;
                        }

                        return Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("QUOTATION FORM", style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              )),
                              SizedBox(height: 10),
                              Text("Fill up the form", style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              )),
                              SizedBox(height: 10),
                              _buildNumberField(rateController, 'Rate',_isenabled ),
                              SizedBox(height: 15),
                              _TextAreaField(noteController, 'Notes'),
                              SizedBox(height: 15),
                              MaterialButton(
                                elevation: 0,
                                minWidth: double.maxFinite,
                                height: 60,
                                onPressed: _isButtonDisabled ? () {} : () async {
                                  if (formKey.currentState.validate()) {

                                    EasyLoading.show(status: 'loading...');

                                    try {
                                      final uid = await Provider
                                          .of(context)
                                          .auth
                                          .getCurrentUID();
                                      if (uid != null) {
                                        var emailSnapshot = await FirebaseFirestore.instance
                                            .collection("hero").where(
                                            'profile_id', isEqualTo: uid).get();
                                        var addressSnapshot = await FirebaseFirestore.instance
                                            .collection("address").where(
                                            'profile_id', isEqualTo: uid).get();
                                        var profileSnapshot = await FirebaseFirestore.instance
                                            .collection("profile").where(
                                            'profile_id', isEqualTo: uid).get();
                                        var contactSnapshot = await FirebaseFirestore.instance
                                            .collection("contact").where(
                                            'profile_id', isEqualTo: uid).get();
                                        await db.collection('quote').add(
                                            {
                                              'booking_id': widget.BookingID,
                                              'hero_address':
                                              addressSnapshot.docs[0].get("street")
                                                  + " " +
                                                  addressSnapshot.docs[0].get("barangay")
                                                  + " " + addressSnapshot.docs[0].get("city")
                                                  + " " +
                                                  addressSnapshot.docs[0].get("province"),
                                              'hero_id': emailSnapshot.docs[0].id,
                                              'hero_name': profileSnapshot.docs[0].get(
                                                  'first_name') + " " +
                                                  profileSnapshot.docs[0].get('last_name'),
                                              'notes': noteController.text,
                                              'rate': rateController.text,
                                              'hero_mobile': contactSnapshot.docs[0].get(
                                                  "value"),
                                            }
                                        );
                                        EasyLoading.dismiss();


                                        AwesomeDialog(
                                            context: context,
                                            animType: AnimType.LEFTSLIDE,
                                            headerAnimationLoop: false,
                                            dialogType: DialogType.SUCCES,
                                            title: 'Success',
                                            desc: 'Your Quotation has been Successfully Submitted.',
                                            btnOkOnPress: () {
                                              setState(() {
                                                rateController.text = "";
                                                noteController.text = "";
                                              });


                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ManageServices(),
                                                ),
                                              );
                                              Navigator.of(context, rootNavigator: true).pop();
                                              //Navigator.pop(context);


                                            },
                                            btnOkIcon: Icons.check_circle,
                                            onDissmissCallback: () {
                                              debugPrint('Dialog Dissmiss from callback');
                                            }).show();
                                      }
                                    } catch (e) {
                                      EasyLoading.dismiss();
                                      formKey.currentState.reset();
                                      _awesomeDialogError(
                                          e,
                                          context
                                      );
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
                        );
                    }


              }
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

Stream<DocumentSnapshot> getBookingDataSnapshots(BuildContext context,String BookingID) async* {

  yield*  FirebaseFirestore.instance.collection('booking').doc(BookingID).snapshots();

}