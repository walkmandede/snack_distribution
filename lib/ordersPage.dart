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


class OrdersPage extends StatefulWidget {

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {

  Map ordersMap = {};
  Map snackStockMap = {};
  String showOrders = 'All';
  Map<String,List> myDailyOrdersMap  = {};

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async
  {
    await getCollectionData('SnackStock', snackStockMap);
    await getCollectionData('Orders', ordersMap);
    ordersMap.keys.forEach((element) {
      Timestamp ts = ordersMap[element]['DateTime'];
      String myOrderedDate = ts.toDate().toString().substring(0,10);
      List? dailyOrders = [];
      if(myDailyOrdersMap[myOrderedDate]==null)
      {
        dailyOrders.add(element);
      }
      else
      {
        dailyOrders = myDailyOrdersMap[myOrderedDate];
        dailyOrders?.add(element);
      }
      myDailyOrdersMap.addEntries(
          [
            MapEntry(myOrderedDate, dailyOrders!)
          ]
      );
    });
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        actions: [
          Switch(activeColor: Colors.pink,value: showOrders=='All'?true:false, onChanged: (value) {
            if(value==true)
            {
              setState(() {
                showOrders = 'All';
              });
            }
            else
            {
              setState(() {
                showOrders = 'Remaining';
              });
            }

          },)
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: myDailyOrdersMap.keys.map((tdy) {
              return ExpansionTile(
                title: Text(tdy),
                children: ordersMap.keys.map((e) {
                  Timestamp ts = ordersMap[e]['DateTime'];
                  var status = ordersMap[e]['Status'];
                  Map orderedItems = ordersMap[e]['OrderedItems'];
                  if(showOrders=='All')
                  {
                    return ts.toDate().toString().substring(0,10)!=tdy?Container():ExpansionTile(
                      title: Text(ts.toDate().toString().substring(0,16),style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                      trailing: Text(ordersMap[e]['TotalPrice']+'    MMKs',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                      subtitle: Text(ordersMap[e]['Phone']+'\n'+ordersMap[e]['Username'],style: TextStyle(color: Colors.pinkAccent,fontWeight: FontWeight.bold),),
                      leading: IconButton(
                        icon: Icon(status.toString()=='Delivered'?Icons.check_circle:Icons.check_circle_outline,color: status.toString()=='Delivered'?Colors.pinkAccent:Colors.grey,),
                        onPressed: () async{
                          showAlertDialog(context, 'Processing!', Text('Please Wait'), []);
                          if(status.toString()!='Delivered')
                          {
                            await FirebaseFirestore.instance.collection('Orders').doc(e.toString()).update({
                              'Status':'Delivered'
                            });
                          }
                          pushReplacement(context, HomePage());
                          push(context, OrdersPage());
                        },
                      ),
                      children: orderedItems.keys.map((e) {
                        return orderedItems[e].toString()=='0'?Container():
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                          ),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(snackStockMap[e]['Name']),
                              Text(orderedItems[e].toString())
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
                  else
                  {
                    if(ordersMap[e]['Status']=='Delivered')
                    {
                      return Container();
                    }
                    else
                    {
                      return ts.toDate().toString().substring(0,10)!=tdy?Container():ExpansionTile(
                        title: Text(ts.toDate().toString().substring(0,16),style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                        trailing: Text(ordersMap[e]['TotalPrice']+'    MMKs',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                        subtitle: Text(ordersMap[e]['Phone']+'\n'+ordersMap[e]['Username'],style: TextStyle(color: Colors.pinkAccent,fontWeight: FontWeight.bold),),
                        leading: IconButton(
                          icon: Icon(status.toString()=='Delivered'?Icons.check_circle:Icons.check_circle_outline,color: status.toString()=='Delivered'?Colors.pinkAccent:Colors.grey,),
                          onPressed: () async{
                            showAlertDialog(context, 'Processing!', Text('Please Wait'), []);
                            if(status.toString()!='Delivered')
                            {
                              await FirebaseFirestore.instance.collection('Orders').doc(e.toString()).update({
                                'Status':'Delivered'
                              });
                            }
                            pushReplacement(context, HomePage());
                            push(context, OrdersPage());
                          },
                        ),
                        children: orderedItems.keys.map((e) {
                          return orderedItems[e].toString()=='0'?Container():
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                            ),
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(snackStockMap[e]['Name']),
                                Text(orderedItems[e].toString())
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }
                  }
                }).toList(),
              );
            }).toList()
          ),
        )
      ),
    );
  }
}
