// lib/widgets/default_list_view.dart

import 'dart:io';
import 'package:attendence_app/Screens/ProfileScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:http/http.dart' as http;


class DefaultListView extends StatelessWidget {
  final List<dynamic> students;
  final List<bool> selections;
  final Function(int) onToggle;

  const DefaultListView({
    super.key,
    required this.students,
    required this.selections,
    required this.onToggle,
  });

  // function for sharing data
  _onShareData(BuildContext context, String txt) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    await Share.share(txt,
        subject: "User Information",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    var box2 = Hive.box('box2');
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Padding(
          padding: const EdgeInsets.all(9),
          child: ListTile(
            title: const Text("Change time format"),
            trailing: ToggleButtons(
              isSelected: selections,
              onPressed: onToggle,
              color: Colors.amberAccent,
              fillColor: Colors.amber,
              borderColor: Colors.transparent,
              children: const <Widget>[Icon(Icons.access_time_filled, color: Colors.amberAccent)],
            ),
          ),
        ),
        students.isNotEmpty?
        Column(
          children: students.map((student) {
            return Padding(
              padding: const EdgeInsets.all(9),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
                color: Colors.black,
                child: InkWell(
                  onTap: () {
                  // open profile page with the respective user info
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    // all was joined into a single string to split later
                    builder: (context) => ProfileScreen(
                      text: '${student.name},${student.phone_number},${student.checking},${student.imageUrl}',
                    ),
                  ));
            } ,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child:
                          ClipOval(
                            child: student.imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                              imageUrl: student.imageUrl,
                              fit: BoxFit.cover,
                              // Placeholder while the image is loading
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              // Error widget
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/profilepic.jpg', // Fallback image
                                fit: BoxFit.cover,
                              ),
                            )
                                : Image.asset(
                              'assets/images/profilepic.jpg', // Fallback image
                              fit: BoxFit.cover,
                            ),
                          ),

                        ),

                        const SizedBox(width: 30),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.amberAccent,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(student.name),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.amberAccent,),
                                    tooltip: 'Increase volume by 10',
                                      onPressed: () {
                                        _onShareData(context,
                                            "${student.name}\n${student.phone_number}\n${student.checking}");
                                      },
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Colors.amberAccent,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(student.phone_number.toString())
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.date_range,
                                    color: Colors.amberAccent,
                                  ),
                                  const SizedBox(width: 15),
                                  if (box2.get('toggle') == 0 || box2.get('toggle') == null)
                                    Text(DateFormat('dd MMM yyyy, h:mm a')
                                        .format(student.checking)
                                        .toString())
                                  else if (box2.get('toggle') == 1)
                                    Text(timeago.format(student.checking))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )

                  ),
                ),
              ),
            );
          }).toList(),)
              :  // If the list is empty, display the "No users. Add new users" message.
            Padding(
              padding: const EdgeInsets.all(9),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
                color: Colors.black,
                child: const Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Center(
                    child: Text(
                      'No users. Add new users',
                      style: TextStyle(color: Colors.amberAccent, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),


        if (students.length > 2)
        Container(
          height: 50,
          width: double.infinity,
          color: Colors.amber,
          child: const Center(
            child: Text('end of user list', style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}
