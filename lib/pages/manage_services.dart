import 'package:flutter/material.dart';
import 'package:hero_partners/pages/homepage.dart';
import 'package:hero_partners/pages/job.dart';
import 'package:hero_partners/pages/quotation.dart';

void main() {
  runApp(ManageServices());
}

class ManageServices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            iconTheme: IconThemeData(
                color: Colors.black
            ),
            title: const Text('Services', style: TextStyle(
                color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
            )),
            backgroundColor: Colors.white,
            bottom: TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: "My Services",),
                Tab(text: "For Quotation",),

              ],
            ),
          ),
          body: TabBarView(
            children: [
              HomePage(),
              Quotation(),
              //Icon(Icons.directions_car),


            ],
          ),
        ),
      ),
    );
  }
}