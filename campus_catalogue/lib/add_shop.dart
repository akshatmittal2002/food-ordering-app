import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/rendering/box.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campus_catalogue/add_item.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<void> add_to_database(collection, data, {id = 0}) async {
  // print(data);
  // return;
  try {
    if (id == 0) {
      await db.collection(collection).add(data);
    } else {
      await db.collection(collection).doc(id).set(data);
    }
  } catch (err) {
    throw Exception(err);
  }
}

Future<void> edit_shop_db(shop) async {
  List menu = shop['menu'];
  shop['menu'] = [];
  for (int i = 0; i < menu.length; i++) {
    menu[i].remove('unselected_categories');
    if (menu[i].containsKey('id')) {
      String id = menu[i]['id'];
      shop['menu'].add(id);
      menu[i].remove('id');
      await db.collection('items').doc(id).set(menu[i]);
    } else {
      DocumentReference docref = await db.collection('items').add(menu[i]);
      await shop['menu'].add(docref.id);
    }
  }
  if (shop.containsKey('id')) {
    String id = shop['id'];
    shop.remove['id'];
    await db.collection('shops').doc(id).set(shop);
  } else {
    await db.collection('shops').add(shop);
  }
}

class EditShop extends StatefulWidget {
  Map shop;
  EditShop({super.key, required this.shop});

  @override
  State<EditShop> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShop> {
  @override
  Widget build(BuildContext context) {
    print(widget.shop);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Shop'),
      ),
      body: Column(
        children: [
          // to add: id,name,owner name,phone,payment id,menu,open time,close time,location,images
          const Align(alignment: Alignment.topLeft, child: Text('Shop Name')),
          TextFormField(),
          const Align(alignment: Alignment.topLeft, child: Text('Shop Type')),
          // DropdownButton(items: [
          //   DropdownMenuItem(child: Text('abc')),
          //   DropdownMenuItem(child: Text('abc')),
          //   DropdownMenuItem(child: Text('abc')),
          //   ], onChanged: null),

          ElevatedButton(
              child: const Text('Add Menu'),
              onPressed: () =>
                  {edit_menu(menu: widget.shop['menu'], context: context)}),
          ElevatedButton(
            child: const Text("Done"),
            onPressed: () {
              // widget.shop.remove('categories');
              // widget.shop.remove('unselected_categories');
              // widget.shop['categories'] = widget.shop['categories'].toList();
              // widget.shop['unselected_categories'] = widget.shop['unselected_categories'].toList();
              edit_shop_db(widget.shop);
              Navigator.pop(context);
            },
          )
          // onPressed: () => add_to_database('shops', {'name': 'hello'})),
        ],
      ),
    );
  }
}

// void edit_shop({String id = ""}) async {
//   // List<Model> list=[];
//   Map<String, dynamic> shop = {};
//   print("hello");
//   var data = await db.collection("shops").get();
//   for (int i = 0; i < data.docs.length; i++) {
//     va xx = data.docs[0].data() as Map;
//     print(shop.runtimeType);
//     // shop.putIfAbsent(key, () => null)
//   }
//   print(shop);
// }

void test(Map<String, dynamic> shop) {
  shop.clear();
}

void edit_shop({String id = "", required BuildContext context}) async {
  Map<String, dynamic> shop = {'menu': []};
  Map<String, dynamic> menu = {};
  shop['menu'].add(menu);

  if (id != '') {
    var data = await db.collection("shops").doc(id).get();
    shop = data.data()!;
  }

  print(shop['menu'].runtimeType);

  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => EditShop(
              shop: shop,
            )),
  );
}