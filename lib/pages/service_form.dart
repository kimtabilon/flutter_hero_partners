import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hero_partners/pages/login.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hero_partners/pages/manage_services.dart';
import 'package:hero_partners/pages/navigation.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
import 'package:hero_partners/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:password_strength/password_strength.dart';
class ServiceForm extends StatefulWidget {
  final String OptionID;//if you have multiple values add here
  final String ServiceType;
  ServiceForm(this.OptionID,this.ServiceType, {Key key}): super(key: key);
  @override
  _ServiceFormState createState() => _ServiceFormState();
}
final TextEditingController yearsController = TextEditingController();
final TextEditingController servicerateController = TextEditingController();
final TextEditingController dailyrateController = TextEditingController(text:'0');
final TextEditingController hourlyrateController = TextEditingController(text:'0');
final TextEditingController certController = TextEditingController();


class _ServiceFormState extends State<ServiceForm> {
  final db = FirebaseFirestore.instance;
  @override

  bool _isButtonDisabled = false;
  final formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
        bool _showrate = true;
    if(widget.ServiceType == "quotation" || widget.ServiceType == "session"){
      _showrate = false;
    }else{
      _showrate = true;
    }


    return FlutterEasyLoading(
      child: Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
              color: Colors.black
          ),
          title: const Text('SERVICE FORM', style: TextStyle(
              color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
          )),
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Register a Service",style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                  )),
                  SizedBox(height: 10),
                  Text("Fill up the form",style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  )),
                  SizedBox(height: 10),
                  _buildNumberField(yearsController, 'Years of Experience'),
                  SizedBox(height: 5),
                  _buildNumberField(servicerateController, 'Rate yourself from 1 to 10'),
                  SizedBox(height: 15),
                  _TextAreaField(certController, 'Certification'),
                  SizedBox(height: 15),
                  _showrate ? _buildNumberField(dailyrateController, 'Daily Rate') : Container(),
                  SizedBox(height: 15),
                  _showrate ? _buildNumberField(hourlyrateController, 'Hourly Rate') : Container(),
                  SizedBox(height: 15),
                  MaterialButton(
                    elevation: 0,
                    minWidth: double.maxFinite,
                    height: 60,
                    onPressed: _isButtonDisabled ? (){} : () async {

                    if (formKey.currentState.validate()) {

                      setState(() => _isButtonDisabled = true);
                      EasyLoading.show(status: 'loading...');


                      try {
                        final uid = await Provider.of(context).auth.getCurrentUID();
                        if(uid != null){
                          var emailSnapshot = await FirebaseFirestore.instance.collection("hero").where('profile_id', isEqualTo: uid).get();
                          var addressSnapshot = await FirebaseFirestore.instance.collection("address").where('profile_id', isEqualTo: uid).get();
                          var profileSnapshot = await FirebaseFirestore.instance.collection("profile").where('profile_id', isEqualTo: uid).get();
                          var contactSnapshot = await FirebaseFirestore.instance.collection("contact").where('profile_id', isEqualTo: uid).get();
                          await db.collection('hero_services').add(
                              {
                                'profile_id': uid,
                                'hero_id': emailSnapshot.docs[0].id,
                                'hero_photo': profileSnapshot.docs[0].get("photo"),
                                'hero_name': profileSnapshot.docs[0].get("first_name")
                              +" "+ profileSnapshot.docs[0].get("last_name"),
                                'hero_address':
                                addressSnapshot.docs[0].get("street")
                                    +" "+ addressSnapshot.docs[0].get("barangay")
                                    +" "+ addressSnapshot.docs[0].get("city")
                                    +" "+ addressSnapshot.docs[0].get("province"),
                                'hero_province':addressSnapshot.docs[0].get("province").toUpperCase(),
                                'hero_city':addressSnapshot.docs[0].get("city").toUpperCase(),
                                'service_option_id': widget.OptionID,
                                'hero_experience': yearsController.text,
                                'hero_rate': servicerateController.text,
                                'hero_mobile': contactSnapshot.docs[0].get("value"),
                                'hero_cert': certController.text,
                                'daily_rate': int.parse(dailyrateController.text),
                                'hourly_rate': int.parse(hourlyrateController.text),
                                'status': 'Pending',
                              }
                          );
                          EasyLoading.dismiss();
                          _awesomeDialogSucces(
                              'Your Service Application Form has been Successfully Submitted.',
                              Navigation(),
                              context
                          );
                        }


                      } catch (e) {
                        EasyLoading.dismiss();
                        formKey.currentState.reset();
                        _awesomeDialogError(
                            e,
                            context
                        );
                      }

                      setState(() => _isButtonDisabled = false);




                    }




                   },
                    color: Color(0xFF13869f),
                    child: Text('SUBMIT',
                        style: TextStyle(color: Colors.white, fontSize: 15,fontWeight: FontWeight.bold)),
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




_awesomeDialogSucces(String content,Widget Redirect,BuildContext context){
  AwesomeDialog(
      context: context,
      animType: AnimType.LEFTSLIDE,
      headerAnimationLoop: false,
      dialogType: DialogType.SUCCES,
      title: 'Success',
      desc: content,
      btnOkOnPress: () {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ManageServices(),
          ),
        );
        Navigator.of(context, rootNavigator: true).pop();

        // Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => Navigation()));
      },
      btnOkIcon: Icons.check_circle,
      onDissmissCallback: () {
        debugPrint('Dialog Dissmiss from callback');
      }).show();
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
    TextEditingController controller, String labelText) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    child: TextFormField(
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {

        if (value.isEmpty) {
          return 'This field is required.';
        }
        if(controller == servicerateController && (int.parse(value) > 10 || int.parse(value) == 0)){
          return 'Please Rate only from 1 to 10';
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

