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


class EditItem extends StatefulWidget {

  final String itemID;
  const EditItem(this.itemID);

  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {

  Map snackStockMap = {};
  String snackId = '';
  List availableCategories = [];
  var snackImage;
  TextEditingController txtName = new TextEditingController(text: '');
  TextEditingController txtPrice = new TextEditingController(text: '0');
  TextEditingController txtDescription = new TextEditingController(text: '');
  TextEditingController txtQuantity = new TextEditingController(text: '0');
  TextEditingController txtNewCategory = new TextEditingController(text: '');
  String choosenCategory = '';
  String url ="";

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async
  {
    await getCollectionData('SnackStock', snackStockMap);
    setState(() {
      snackId = widget.itemID;
    });
    snackStockMap.keys.forEach((element) { 
      if(!availableCategories.contains(snackStockMap[element]['Category']))
        {
         setState(() {
           availableCategories.add(snackStockMap[element]['Category']);
         });
        }
    });
    setState(() {
      txtName.text = snackStockMap[snackId]['Name'];
      txtPrice.text = snackStockMap[snackId]['Price'];
      txtDescription.text = snackStockMap[snackId]['Description'];
      txtQuantity.text = snackStockMap[snackId]['Stock'].toString();
      choosenCategory = snackStockMap[snackId]['Category'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(snackStockMap[snackId]['Name']),
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
                child: snackImage==null?Container(
                  child: Image.network(snackStockMap[snackId]['Photo']),
                ):
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
                controller: txtQuantity,
                keyboardType: TextInputType.numberWithOptions(),
                decoration: InputDecoration(
                  label: Text('Stock'),
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
                if((txtNewCategory.text==''&&choosenCategory==''))
                  {
                    showAlertDialog(context, 'Missing Data!', Text('Please choose a image of the snack or Category'), []);
                  }
                else
                  {
                    showAlertDialog(context, 'Please Wait!', Text('Saving'), []);
                    DateTime dt = DateTime.now();
                    if(snackImage!=null)
                      {
                        url = await uploadImageCloud(snackImage, dt);
                      }
                    else{
                      setState(() {
                        url = snackStockMap[snackId]['Photo'];
                      });
                    }
                    // await FirebaseStorage.instance
                    //     .ref('SnacksImages/${dt.toString()}')
                    //     .putFile(snackImage);
                    await FirebaseFirestore.instance.collection('SnackStock').doc(snackId).update(  {
                      'ItemId':'Item '+(snackStockMap.keys.length + 1).toString(),
                      'Name':txtName.text,
                      'Price':txtPrice.text,
                      'Description':txtDescription.text,
                      'Category':txtNewCategory.text!=''?txtNewCategory.text:choosenCategory,
                      'Photo':url,
                      'Stock':int.parse(txtQuantity.text)
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
