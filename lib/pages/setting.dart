import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hero_partners/widgets/provider_widget.dart';
class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}
final db = FirebaseFirestore.instance;
class _SettingState extends State<Setting> {
  bool isSwitched = false;
  
  @override
  final _scrollController = ScrollController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
        title: const Text('SETTINGS', style: TextStyle(
            color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
        )),
        backgroundColor: Colors.white,
      ),
      body:
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
        return SafeArea(
          child: Scrollbar(
            controller: _scrollController, // <---- Here, the controller
            isAlwaysShown: true, // <---- Required
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Switch Offline",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Switch(
                          value: snapshot.data.docs.isEmpty
                              ? isSwitched
                              : snapshot.data.docs[0].get('offline'),
                          onChanged: (value) {
                            setState(() async {
                              isSwitched = value;
                              print(isSwitched);
                              await db.collection('hero_settings').doc(
                                  snapshot.data.docs[0].id)
                                  .update(
                                  {
                                    'offline': isSwitched,
                                  });
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    Container(
                      width: 250,
                      child:
                      Text(
                          "Para hindi makatanggap ng booking, o para maging invisible sa system,"
                              "i-swipe papuntang kanan ang switch upang ma-activate.",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                    SizedBox(height: 10),
                    Divider(thickness: 1, color: Colors.grey),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Preferred Location",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Text("edit"),
                      ],
                    ),
                    Container(
                      width: 250,
                      child:
                      Text("Para makatanggap ng booking sa piling lugar,"
                          "pindutin ang Preferred Location at i-check lamang ang mga lugar"
                          "na nais mong makuhanan ng booking.",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                    // SizedBox(height: 10),
                    // Divider(thickness:1,color: Colors.grey),
                    // SizedBox(height: 10),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text("Auto Confirm Job",
                    //         style: TextStyle( fontSize: 17,fontWeight: FontWeight.bold)),
                    //     Switch(
                    //       value: isSwitched,
                    //       onChanged: (value){
                    //         setState(() {
                    //           isSwitched=value;
                    //         });
                    //       },
                    //       activeTrackColor: Colors.lightGreenAccent,
                    //       activeColor: Colors.green,
                    //     ),
                    //   ],
                    // ),
                    Container(
                      width: 250,
                      child:
                      Text("Upang maunang makapag confirm ng booking, "
                          "i-swipe papuntang kanan ang switch upang ma-activate. "
                          "Gumagana lamang ito sa mga time-based na trabaho tulad ng Housekeeping at Child Services",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),

                    SizedBox(height: 10),
                    Divider(thickness: 1, color: Colors.grey),
                    SizedBox(height: 10),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text("Edit Account",
                    //         style: TextStyle( fontSize: 17,fontWeight: FontWeight.bold)),
                    //
                    //     InkWell(
                    //       child: Text("REQUEST"),
                    //     ),
                    //   ],
                    // ),
                    // Container(
                    //   width: 250,
                    //   child:
                    //   Text("Kung may nais baguhin sa iyong profile tab,"
                    //       "pindutin ito para magsend ng request sa admin at mai-unlock ang "
                    //       "iyong profile tab",
                    //       style: TextStyle( fontSize: 14,color: Colors.grey)),
                    // ),
                    //
                    // SizedBox(height: 10),
                    // Divider(thickness:1,color: Colors.grey),
                    // SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Manage Schedule",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold)),
                        Text("edit"),
                      ],
                    ),
                    Container(
                      width: 250,
                      child:
                      Text(
                          "Pindutin ang Manage Schedule kung hindi nais makatanggap "
                              "ng booking sa mga piling petsa o araw. Tandaan: Makakatanggap "
                              "pa rin ang Hero ng Booking maliban lamang sa araw na napili niyang mag-off",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ),


                  ],
                ),
              ),
            ),
          ),
        );
    }
        }
      ),
    );
  }
}

// _awesomeDialogInfo(String content,BuildContext context){
//   AwesomeDialog(
//       context: context,
//       animType: AnimType.SCALE,
//       dialogType: DialogType.INFO,
//       dismissOnTouchOutside: false,
//       keyboardAware: true,
//       title: content,
//       desc: "Send request to enable your account.",
//       btnOkOnPress: () async {
//
//         final uid = await Provider.of(context).auth.getCurrentUID();
//
//         final request_status = await FirebaseFirestore.instance
//             .collection('hero_request')
//             .where('profile_id', isEqualTo: uid)
//             .where('status', isEqualTo: 'pending')
//             .where('request', isEqualTo: 'edit_profile')
//             .get();
//
//         if(request_status.docs.length ==  0){
//           await db.collection('hero_request').add(
//               {
//                 'profile_id': uid,
//                 'request' : 'edit_profile',
//                 'old_data' : false,
//                 'new_data' : true,
//                 'status': "pending",
//               }
//           );
//         }
//
//
//       },
//       btnCancelOnPress: () {
//
//       },
//       btnOkText: "Submit",
//       onDissmissCallback: () {
//         debugPrint('Dialog Dissmiss from callback');
//       }).show();
// }

Stream<QuerySnapshot> getUserDataSnapshots(BuildContext context) async* {
  final uid = await Provider.of(context).auth.getCurrentUID();
  yield* FirebaseFirestore.instance.collection('hero_settings').where('profile_id', isEqualTo: uid).snapshots();
}
