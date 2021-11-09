import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:snack_distribution/globals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snack_distribution/homePage.dart';


class RestockingLog extends StatefulWidget {

  @override
  _RestockingLogState createState() => _RestockingLogState();
}

class _RestockingLogState extends State<RestockingLog> {

  Map restockItemsLogMap = {};
  Map stockItemsMap = {};

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async
  {
    await getCollectionData('RestockingLog', restockItemsLogMap);
    await getCollectionData('SnackStock', stockItemsMap);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items Restocking'),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: ListView(
          children: restockItemsLogMap.keys.map((e) {
            Timestamp dateTime = restockItemsLogMap[e]['DateTime'];
            Map restockItemsMap = restockItemsLogMap[e]['RestockItems'];
            return ExpansionTile(
              title: Text(dateTime.toDate().toString().substring(0,16),style: TextStyle(fontWeight: FontWeight.bold),),
              children: restockItemsMap.keys.map((e) {
                if(restockItemsMap[e]!=0)
                  {
                    return Card(
                      child: Container(
                        margin: EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(stockItemsMap[e]['Name'],style: TextStyle(fontWeight: FontWeight.bold),),
                                Text('Refilled Stock : '+restockItemsMap[e].toString()),
                              ],
                            ),
                            Text('Current Stock : '+stockItemsMap[e]['Stock'].toString()),
                          ],
                        ),
                      ),
                    );

                  }
                return Container();
              }).toList(),
            );
          }).toList(),
        )
      ),
    );
  }
}
