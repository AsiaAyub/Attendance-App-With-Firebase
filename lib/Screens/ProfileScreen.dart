import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  // string to get the data from the navigator push
  final String text;

  // receive data from the otherScreen as a parameter
  const ProfileScreen({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    // list for user info
    List user = text.split(',');

    return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.amberAccent))
              ),
              height: 300,
              width: double.infinity,
              child: Image.network(
                  user[3],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if(loadingProgress == null){
                    return child;
                  }
                  else{
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: Colors.amberAccent,
                      ),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                      'assets/images/profilepic.jpg',
                    fit: BoxFit.cover,

                  );
                },
              ),

            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.amberAccent),
              title: Text(user[0]),
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.amberAccent),
              title: Text(user[1]),
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.amberAccent),
              title: Text(user[2]),
            ),
          ],
        ));
  }
}
