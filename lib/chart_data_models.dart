import 'package:flutter/material.dart';

import 'Chatbot.dart';
import 'upload_page.dart';

Color _gold = Color(0xFFD4A064);
Color _white = Color(0xFFF2F5F8);
Color _blue = Color(0xFF1C2541);
Color _red = Color(0xFFCC4E5C);

class DashboardAp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard',
      theme: ThemeData(
        primaryColor: _blue,
        scaffoldBackgroundColor: _blue,
        appBarTheme: AppBarTheme(
          backgroundColor: _blue,
          iconTheme: IconThemeData(color: _gold),
        ),
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late var dashBoard;

  @override
  void initState() {
    super.initState();
    dashBoard = api.getDashBoard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: _gold,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: _gold,
          onPressed: () {
            Navigator.pushReplacement(
              context,
                MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.adb_sharp),
            color: _gold,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Myupload()),
              );
            },
          ),
        ],
      ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24.0),
              FutureBuilder<List<Map<String, String>>>(
                future: dashBoard,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While waiting for data, show a loading indicator in the center
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16.0),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              color: _gold,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // If an error occurred, show the error message in the center
                    return Center(
                      child: Text(
                        "Board not found! try reloading this page.",
                        style: TextStyle(
                          color: _gold,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    // If data is available, build the ListView
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var qaPair = snapshot.data![index];
                        var question = qaPair.keys.first;
                        var answer = qaPair.values.first;
                        return QACard(
                          question: question,
                          answer: answer,
                        );
                      },
                    );
                  } else {
                    // If the snapshot has no data and no error, show an empty container
                    return Container();
                  }
                },
              ),
            ],
          ),
        )
    );
  }
}

// class TopWidgetsSection extends StatelessWidget {
//   final double Revenue;
//   final int Growth;
//   final int Loss;
//   final int netProfit;
//
//   TopWidgetsSection({
//     required this.Revenue,
//     required this.Growth,
//     required this.Loss,
//     required this.netProfit,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       padding: EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: _blue,
//         borderRadius: BorderRadius.circular(20.0),
//         boxShadow: [
//           BoxShadow(
//             color: _gold.withOpacity(0.8),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: InfoCard(
//                   label: 'Revenue ( crores )',
//                   value: '\$${Revenue.toStringAsFixed(0)}',
//                   iconData: Icons.sticky_note_2_sharp,
//                 ),
//               ),
//               SizedBox(width: 16.0),
//               Expanded(
//                 child: InfoCard(
//                   label: 'Growth',
//                   value: Growth.toString(),
//                   iconData: Icons.auto_graph_sharp,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.0),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: InfoCard(
//                   label: 'Loss ( crores )',
//                   value: Loss.toString(),
//                   iconData: Icons.currency_rupee,
//                 ),
//               ),
//               SizedBox(width: 16.0),
//               Expanded(
//                 child: InfoCard(
//                   label: 'Net Profit',
//                   value: '\$${netProfit.toString()}',
//                   iconData: Icons.currency_exchange,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

class QACard extends StatelessWidget {
  final String question;
  final String answer;

  QACard({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white60, Colors.white70],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            answer,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? iconData;

  InfoCard({
    required this.label,
    required this.value,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_gold.withOpacity(0.7), _gold.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: _gold.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconData != null)
                Icon(
                  iconData,
                  size: 20.0,
                  color: Colors.white,
                ),
              if (iconData != null) SizedBox(width: 8.0),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
