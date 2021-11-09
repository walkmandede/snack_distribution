import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:snack_distribution/globals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snack_distribution/homePage.dart';


class ItemRestock extends StatefulWidget {

  @override
  _ItemRestockState createState() => _ItemRestockState();
}

class _ItemRestockState extends State<ItemRestock> {

  Map snackStockMap = {};
  var snackImage;
  TextEditingController txtName = new TextEditingController(text: '');
  TextEditingController txtPrice = new TextEditingController(text: '0');
  TextEditingController txtDescription = new TextEditingController(text: '');
  TextEditingController txtQuantity = new TextEditingController(text: '0');
  TextEditingController txtNewCategory = new TextEditingController(text: '');
  Map itemQuantityMap = {};

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async
  {
    await getCollectionData('SnackStock', snackStockMap);
    snackStockMap.keys.forEach((element) {
      setState(() {
        itemQuantityMap.addEntries({
          MapEntry(element, 0)
        });
      });
    });
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: snackStockMap.keys.map((e) {
                  if(snackStockMap[e]['Status']=='Deleted')
                    {
                      return Container();
                    }
                  else
                    {
                      TextEditingController txtEE = new TextEditingController(text: itemQuantityMap[e].toString());
                      return Card(
                        child: Container(
                          margin: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.14,height: MediaQuery.of(context).size.width*0.14,
                                child: CachedNetworkImageBuilder(url: snackStockMap[e]['Photo'],
                                  builder: (image) {
                                    return Image.file(image);
                                  },),
                              ),
                              Column(
                                children: [
                                  Text(snackStockMap[e]['Name'],style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text('Current Stock : '+snackStockMap[e]['Stock'].toString()),
                                ],
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    IconButton(onPressed: () {
                                      setState(() {
                                        itemQuantityMap[e] = itemQuantityMap[e] + 1;
                                      });
                                    }, icon: Icon(Icons.add)),
                                    Container(
                                      width: 20,
                                      child: TextField(
                                        controller: new TextEditingController(text: txtEE.text),
                                        keyboardType: TextInputType.numberWithOptions(),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,

                                        ),
                                        onSubmitted: (value) {
                                          setState(() {
                                            itemQuantityMap[e] = int.parse(value);
                                          });
                                        },
                                      ),
                                    ),
                                    IconButton(onPressed: () {
                                      if(itemQuantityMap[e]>0)
                                      {
                                        setState(() {
                                          itemQuantityMap[e] = itemQuantityMap[e] - 1;
                                        });
                                      }
                                    }, icon: Icon(Icons.remove)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                }).toList(),
              )
            ),
            ElevatedButton.icon(onPressed: () async {
              await FirebaseFirestore.instance.collection('RestockingLog').add(
                {
                  'DateTime':DateTime.now(),
                  'RestockItems':itemQuantityMap
                }
              );
              itemQuantityMap.keys.forEach((element) async{
               await FirebaseFirestore.instance.collection('SnackStock').doc(element.toString()).update(
                  {
                    'Stock': snackStockMap[element.toString()]['Stock']+itemQuantityMap[element],
                  }
                );
                pushReplacement(context, HomePage());
              });
            }, icon: Icon(Icons.add), label: Text('Add Stock'))
          ],
        )
      ),
    );
  }
}
