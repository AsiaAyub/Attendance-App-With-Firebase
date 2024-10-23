// lib/widgets/search_list_view.dart

import 'package:flutter/material.dart';


class SearchListView extends StatelessWidget {
  final List<int> searchIndexList;
  final List<dynamic> students;

  const SearchListView({super.key, required this.searchIndexList, required this.students});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: searchIndexList.length,
      itemBuilder: (context, index) {
        index = searchIndexList[index];
        return Card(child: ListTile(title: Text(students[index].name)));
      },
    );
  }
}
