import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:snack_distribution/editItem.dart';
import 'package:snack_distribution/globals.dart';
import 'package:snack_distribution/itemRestock.dart';
import 'package:snack_distribution/newItem.dart';
import 'package:snack_distribution/ordersPage.dart';
import 'package:snack_distribution/restockingLog.dart';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  String selectedCategory = "All";
  Map snackStockMap = {};

  Future<void> initPlatformState() async {
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setAppId("069ff4a8-8365-4541-a3da-75ca09ef88c0");
// The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      print("Accepted permission: $accepted");
    });
    String externalUserId = 'admin'; // You will supply the external user id to the OneSignal SDK
    OneSignal.shared.setExternalUserId(externalUserId);
    await OneSignal.shared.sendTag("status", "admin");
  }

  @override
  void initState() {
    getData();
    initPlatformState();
    super.initState();
  }

  Future<void> getData() async
  {
    await Firebase.initializeApp();
    await getCollectionData('SnackStock', snackStockMap);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height*0.35,
              width: double.infinity,
              decoration: BoxDecoration(

              ),

              child: CachedNetworkImageBuilder(url: 'https://previews.123rf.com/images/everilda/everilda1706/everilda170600079/80763283-morning-breakfast-doodle-vector-pattern-sketch-objects-isolated-on-white-bread-butter-snack-food-mil.jpg',
                  builder: (image) {
                    return Image.file(image);
                  },)
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Text('Add New Item'),
                      onPressed: () => push(context, NewItem()),
                    ),
                    Divider(),
                    TextButton(
                      child: Text('Item Restock'),
                      onPressed: () => push(context, ItemRestock()),
                    ),
                    Divider(),
                    TextButton(
                      child: Text('Restocking Log'),
                      onPressed: () => push(context, RestockingLog()),
                    ),
                    Divider(),
                    TextButton(
                      child: Text('Orders'),
                      onPressed: () => push(context, OrdersPage()),
                    ),
                    Divider(),
                    // TextButton(
                    //   child: Text('Test'),
                    // onPressed: () async{
                    //     await sendNoti('New Order', 'Test');
                    // },
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('SnackStock').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            Map showItemsMap = {};
            List allCategories = [];
            allCategories.add('All');
            snackStockMap.keys.forEach((element) {
              if(!allCategories.contains(snackStockMap[element]['Category'])&&snackStockMap[element]['Status']=='Available')
              {
                allCategories.add(snackStockMap[element]['Category']);
              }
            });
            snapshot.data?.docs.forEach((element) {
              if(selectedCategory=='All')
              {
                showItemsMap.addEntries(
                    [
                      MapEntry(element.id, element.data())
                    ]
                );
              }
              else if(selectedCategory==snackStockMap[element.id]['Category'])
              {
                showItemsMap.addEntries(
                    [
                      MapEntry(element.id, element.data())
                    ]
                );
              }
            });
            if (!snapshot.hasData) return Center(child: new Text('There is no data available!'));
            else if(showItemsMap.isEmpty) return new Center(child: new Text('There is no data available!'));
            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: allCategories.map((e) {
                      return  GestureDetector(
                        child: chipDesign(e, selectedCategory != e?Colors.grey:Colors.blue, Colors.white),
                        onTap: () {
                          setState(() {
                            selectedCategory = e;
                          });
                        },
                      );
                    } ).toList(),
                  ),
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: Container(
                    child: ListView(
                      children: showItemsMap.keys.map((e) {
                        if(showItemsMap[e]['Status']=='Deleted')
                        {
                          return Container();
                        }
                        else
                        {
                          return  GestureDetector(
                            child: Container(
                                margin: EdgeInsets.all(5),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue.shade100,

                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.15,
                                      height: MediaQuery.of(context).size.width*0.15,
                                      margin: EdgeInsets.all(5),
                                      child: CachedNetworkImageBuilder(url: showItemsMap[e]['Photo'],
                                        builder: (image) {
                                          return Image.file(image);
                                        },)
                                    ),
                                    Column(
                                      children: [
                                        Text(showItemsMap[e]['Name'],style: TextStyle(fontWeight: FontWeight.bold),),
                                        Text(showItemsMap[e]['Description'].toString()),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(showItemsMap[e]['Stock'].toString()+' cpn',style: TextStyle(color: Colors.pink,fontWeight: FontWeight.bold),),
                                        Text(showItemsMap[e]['Price'].toString()+' MMKs',style: TextStyle(color: Colors.blue),),
                                      ],
                                    ),
                                  ],
                                )
                            ),
                            onLongPress: () {
                              showDialog(context: context, builder: (context) => AlertDialog(
                                title: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width*0.4,
                                      height: MediaQuery.of(context).size.width*0.4,
                                      child: CachedNetworkImageBuilder(url: showItemsMap[e]['Photo'],
                                        builder: (image) {
                                          return Image.file(image);
                                        },)
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: new TextEditingController(text: showItemsMap[e]['Name']),
                                      decoration: InputDecoration(
                                          labelText: 'Name',
                                          border: InputBorder.none
                                      ),
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: new TextEditingController(text: showItemsMap[e]['Category']),
                                      decoration: InputDecoration(
                                          labelText: 'Category',
                                          border: InputBorder.none
                                      ),
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: new TextEditingController(text: showItemsMap[e]['Price']),
                                      decoration: InputDecoration(
                                          labelText: 'Price',
                                          border: InputBorder.none
                                      ),
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: new TextEditingController(text: showItemsMap[e]['Stock'].toString()),
                                      decoration: InputDecoration(
                                          labelText: 'Current Stock',
                                          border: InputBorder.none
                                      ),
                                    ),
                                    TextField(
                                      readOnly: true,
                                      controller: new TextEditingController(text: showItemsMap[e]['Description']),
                                      decoration: InputDecoration(
                                          labelText: 'Description',
                                          border: InputBorder.none
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton.icon(onPressed: () {
                                    push(context, EditItem(e.toString()));
                                  }, icon: Icon(Icons.edit), label: Text('Edit')),
                                  TextButton.icon(onPressed: () async{
                                    await FirebaseFirestore.instance.collection('SnackStock').doc(e.toString()).update({
                                      'Status':'Deleted',
                                    });
                                  }, icon: Icon(Icons.delete,color: Colors.red,), label: Text('Delete',style: TextStyle(color: Colors.red),)),
                                ],
                              ),);
                            },
                          );
                        }
                      }
                      ).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
