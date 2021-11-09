import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:snack_distribution/globals.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snack_distribution/homePage.dart';


class NewItem extends StatefulWidget {

  @override
  _NewItemState createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {

  Map snackStockMap = {};
  List availableCategories = [];
  var snackImage;
  TextEditingController txtName = new TextEditingController(text: '');
  TextEditingController txtPrice = new TextEditingController(text: '0');
  TextEditingController txtDescription = new TextEditingController(text: '');
  TextEditingController txtQuantity = new TextEditingController(text: '0');
  TextEditingController txtNewCategory = new TextEditingController(text: '');
  String choosenCategory = '';

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async
  {
    await getCollectionData('SnackStock', snackStockMap);
    snackStockMap.keys.forEach((element) { 
      if(!availableCategories.contains(snackStockMap[element]['Category']))
        {
         setState(() {
           availableCategories.add(snackStockMap[element]['Category']);
         });
        }
    });
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Item Adding'),
      ),

      body: Container(
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width*0.3,
                height: MediaQuery.of(context).size.width*0.3,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                child: snackImage==null?Icon(Icons.image):
                Container(
                  child: Image.file(snackImage),
                ),
              ),
              ElevatedButton(onPressed: () async {
                final ImagePicker _picker = ImagePicker();
                final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                setState(() {
                  snackImage = File(image!.path);
                });
                print(snackImage);
              }, child: Text('Choose Image')),
              ExpansionTile(title: Text('Category'),
                children: [
                  Wrap(
                    children: availableCategories.map((e) =>
                        GestureDetector(
                          child: chipDesign(e, choosenCategory!=e?Colors.grey:Colors.blue, Colors.white),
                          onTap: () {
                            setState(() {
                              choosenCategory = e;
                            });
                          },
                        )
                    ).toList()
                  ),
                ],),
              ExpansionTile(title: Text('Add New Category'),
                trailing: Icon(Icons.add),
                children: [
                  TextField(
                    controller: txtNewCategory,
                    decoration: InputDecoration(
                      label: Text('New Category'),
                    ),
                  ),
                ],),
              Divider(),
              TextField(
                controller: txtName,
                decoration: InputDecoration(
                  label: Text('Name'),
                ),
              ),
              TextField(
                controller: txtPrice,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  label: Text('Price'),
                ),
              ),
              TextField(
                controller: txtDescription,
                maxLines: null,
                decoration: InputDecoration(
                  label: Text('Description'),
                ),
              ),
              ElevatedButton(onPressed: () async{
                if(snackImage==null||(txtNewCategory.text==''&&choosenCategory==''))
                  {
                    showAlertDialog(context, 'Missing Data!', Text('Please choose a image of the snack or Category'), []);
                  }
                else
                  {
                    showAlertDialog(context, 'Please Wait!', Text('Saving'), []);
                    DateTime dt = DateTime.now();
                    String url = await uploadImageCloud(snackImage, dt);
                    // await FirebaseStorage.instance
                    //     .ref('SnacksImages/${dt.toString()}')
                    //     .putFile(snackImage);
                    await FirebaseFirestore.instance.collection('SnackStock').add(  {
                      'ItemId':'Item '+(snackStockMap.keys.length + 1).toString(),
                      'Name':txtName.text,
                      'Price':txtPrice.text,
                      'Description':txtDescription.text,
                      'Category':txtNewCategory.text!=''?txtNewCategory.text:choosenCategory,
                      'Photo':url,
                      'Stock':0,
                      'Status':'Available',
                    });
                    pop(context);
                    pushReplacement(context, HomePage());
                  }
              }, child: Text('Add'))
            ],
          ),
        )
      ),
    );
  }
}
