import 'package:flutter/material.dart';
import 'package:hero_partners/pages/job.dart';

void main() {
  runApp(ManageJobs());
}

class ManageJobs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            iconTheme: IconThemeData(
                color: Colors.black
            ),
            title: const Text('Bookings', style: TextStyle(
                color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold
            )),
            backgroundColor: Colors.white,
            bottom: TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(text: "Pending",),
                Tab(text: "Active",),
                Tab(text: "Completed",),
                Tab(text: "Cancelled",),

              ],
            ),
          ),
          body: TabBarView(
            children: [
              Job('for_confirmation'),
              Job('active'),
              Job('completed'),
              Job('cancelled'),
              //Icon(Icons.directions_car),


            ],
          ),
        ),
      ),
    );
  }
}

