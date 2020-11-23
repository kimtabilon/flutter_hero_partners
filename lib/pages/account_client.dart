import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/pages/edit.dart';
import 'package:hero_partners/pages/review.dart';
import 'package:hero_partners/pages/setting.dart';
import 'package:hero_partners/pages/navigation.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
import 'package:hero_partners/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import 'package:rxdart/rxdart.dart';


final db = FirebaseFirestore.instance;

class AccountClient extends StatefulWidget {
  final String AccountID;

  AccountClient(this.AccountID, {Key key}): super(key: key);
  @override
  _AccountClientState createState() => _AccountClientState();
}



class _AccountClientState extends State<AccountClient> {

  @override
  final _scrollController = ScrollController();

  Widget build(BuildContext context) {


    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        title: const Text('MY ACCOUNT', style: TextStyle(
            color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
        )),
        backgroundColor: Colors.white,
      ),

      body:
      StreamBuilder(
        stream: getUserDataSnapshots(context,widget.AccountID),
        builder: (context,AsyncSnapshot<List<UserData>>  profileSnapshot) {

              if (profileSnapshot.hasError)
                return const SpinKitDoubleBounce(
                    color: Color(0xFF93ca68),
                    size: 50.0);
                switch (profileSnapshot.connectionState) {
                    case ConnectionState.waiting:
                        return const SpinKitDoubleBounce(
                      color: Color(0xFF93ca68),
                      size: 50.0);
                    default:
                        return new ListView(
                            children: profileSnapshot.data.map((   user) {
                              return new SafeArea(
                                child:  Scrollbar(
                                          controller: _scrollController, // <---- Here, the controller
                                          isAlwaysShown: true, // <---- Required
                                              child: SingleChildScrollView(
                                                controller: _scrollController,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(18.0),
                                                      child: Column(
                                                        children: [
                                                             CircleAvatar(
                                                               backgroundColor: Colors.brown.shade800,
                                                               child:
                                                                ClipOval(
                                                                  child:
                                                                  Image.network(user.photo,width: 90,
                                                                       height: 90,fit: BoxFit.fill),
                                                                    ),
                                                               radius: 25,
                                                             ),

                                                            SizedBox(height: 10),

                                                            Text(user.first_name +" "+ user.last_name
                                                                ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),

                                                            SizedBox(height: 10),

                                                             Text(user.city +","+ user.province
                                                                 ,style: TextStyle(fontSize: 12)),
                                                          SizedBox(height: 10),
                                                                   FlatButton(
                                                                       color: Color(0xFF13869f),
                                                                        minWidth: 240,
                                                                       onPressed: (){
                                                                         Navigator.push(
                                                                             context,
                                                                             MaterialPageRoute(builder: (context) => Review()));
                                                                       },
                                                                       child: Text("VIEW REVIEWS", style: TextStyle(
                                                                         color: Colors.white
                                                                       ))),
                                                                       SizedBox(height: 20),
                                                                       Divider(thickness:1,color: Colors.grey),
                                                                       SizedBox(height: 20),
                                                                       Column(
                                                                         crossAxisAlignment: CrossAxisAlignment.start,
                                                                         children: [
                                                                           Align(
                                                                             alignment: Alignment.centerLeft,
                                                                           ),
                                                                           Text("EMAIL", style: TextStyle(
                                                                               fontSize: 12,color: Colors.grey[700]
                                                                           )),
                                                                           SizedBox(height: 5),
                                                                           Text(user.email),
                                                                         ],
                                                                       ),
                                                                       SizedBox(height: 20),
                                                                       Divider(thickness:1,color: Colors.grey),
                                                                       SizedBox(height: 20),
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Align(
                                                                              alignment: Alignment.centerLeft,
                                                                            ),
                                                                            Text("MOBILE NUMBER", style: TextStyle(
                                                                                fontSize: 12,color: Colors.grey[700]
                                                                            )),
                                                                            SizedBox(height: 5),
                                                                            Text(user.mobile),
                                                                          ],
                                                                        ),
                                                                        SizedBox(height: 20),
                                                                        Divider(thickness:1,color: Colors.grey),
                                                                        SizedBox(height: 20),
                                                                       // Column(
                                                                       //   crossAxisAlignment: CrossAxisAlignment.start,
                                                                       //   children: [
                                                                       //     Align(
                                                                       //       alignment: Alignment.centerLeft,
                                                                       //     ),
                                                                       //     Text("EDUCATIONAL BACKGROUND", style: TextStyle(
                                                                       //         fontSize: 12,color: Colors.grey[700]
                                                                       //     )),
                                                                       //     SizedBox(height: 5),
                                                                       //     Text(user.educational_background),
                                                                       //     SizedBox(height: 25),
                                                                       //     Text("CERTIFICATIONS", style: TextStyle(
                                                                       //         fontSize: 12,color: Colors.grey[700]
                                                                       //     )),
                                                                       //     SizedBox(height: 5),
                                                                       //     Text(user.certification),
                                                                       //     SizedBox(height: 25),
                                                                       //     Text("WORK EXPERIENCE", style: TextStyle(
                                                                       //         fontSize: 12,color: Colors.grey[700]
                                                                       //     )),
                                                                       //     SizedBox(height: 5),
                                                                       //     Text(user.work_experience),
                                                                       //   ],
                                                                       // ),

                                                        ],
                                                      ),
                                                    ),
                                              ),





                                ),
                              );
                            }).toList()
                        );

            }
        }
      ),

    );
  }
}

class UserData {
  final email;
  final photo;
  final first_name;
  final last_name;
  final mobile;
  final province;
  final city;
  const UserData(this.email,this.photo,this.first_name, this.last_name,this.mobile,this.province,this.city);
}


Stream<List<UserData>> getUserDataSnapshots(BuildContext context,String AccountID) async* {
  final uid = await Provider.of(context).auth.getCurrentUID();
  //yield* FirebaseFirestore.instance.collection('profile').where('profile_id', isEqualTo: uid).snapshots();

  var profile = FirebaseFirestore.instance.collection('customer').doc(AccountID).snapshots();
  var data = List<UserData>();
  await for (var profileSnapshot in profile) {
      var ProfileData;
      ProfileData = UserData(
          profileSnapshot.get('email'),
          profileSnapshot.get('photo'),
          profileSnapshot.get('fname'),
          profileSnapshot.get('lname'),
          profileSnapshot.get('mobile'),
          "test",
          "test",

          );

      data.add(ProfileData);


    yield data;
  }


}


_awesomeDialogInfo(String content,BuildContext context){
  AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.INFO,
      dismissOnTouchOutside: false,
      keyboardAware: true,
      title: content,
      desc: "Send request to enable your account.",
      btnOkOnPress: () async {

        final uid = await Provider.of(context).auth.getCurrentUID();

    final request_status = await FirebaseFirestore.instance
        .collection('hero_request')
        .where('profile_id', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .where('request', isEqualTo: 'edit_profile')
        .get();

    if(request_status.docs.length ==  0){
      await db.collection('hero_request').add(
          {
              'profile_id': uid,
              'request' : 'edit_profile',
              'old_data' : false,
              'new_data' : true,
              'status': "pending",
          }
      );
    }


      },
      btnCancelOnPress: () {

      },
      btnOkText: "Submit",
      onDissmissCallback: () {
        debugPrint('Dialog Dissmiss from callback');
      }).show();
}