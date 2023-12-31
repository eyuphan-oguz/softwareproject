import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:softwareproject/product/constant/colors.dart';
import 'package:softwareproject/product/constant/padding.dart';
import 'package:softwareproject/product/widgets/content_widget.dart';
import 'package:softwareproject/screens/profile_page_view.dart';

import '../product/widgets/category_menu_widget.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
List<String> contentList = [];


  Future<List<String>> getContent(User? user) async {
  List<String> favoriteContent = [];

  await FirebaseFirestore.instance
    .collection('users')
    .doc(user?.uid)
    .get()
    .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        favoriteContent = List<String>.from(documentSnapshot.get('myContentList'));
        contentList=favoriteContent;
      }
  });

  return favoriteContent;
}



  @override
  Widget build(BuildContext context) {
    setState(() {
      getContent(FirebaseAuth.instance.currentUser);
    });

    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      appBar:  AppBar(
        actions: [
          IconButton(onPressed: (){
             showModalBottomSheet<void>(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            context: context,
            builder: (BuildContext context) {
              return CategoryMenu(size: size); });
            },icon: Icon(Icons.menu),)
          
        ],
        centerTitle: false,
          backgroundColor: ProjectColor().homePageAppbarColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon:Icon(Icons.person,color: Colors.white,), onPressed: () { 
                Navigator.push(context,MaterialPageRoute(builder: (context) =>  ProfilePageView()),);
               },),
               Text("N",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 25),),
            ],
          ),
        ),
      body: Padding(
        padding: ProjectPadding().mainPadding,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('content').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Bir hata oluştu');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator.adaptive();
            }

            return SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: [
                  
                  Container(                 
                    decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
         ),
    ],
  ),
                    width: size.width*0.7,height: size.height*0.45,child: Card(
                    elevation: 0.0,
                    child: Image.network('https://image.tmdb.org/t/p/original/pIkRyD18kl4FhoCNQuWxWu5cBLM.jpg',fit: BoxFit.cover,)),),
                  Container(
                    width: size.width*1,
                    height: size.height*0.2,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        if(snapshot.data!.docs[index]["type"]=="Aksiyon"){
                          print(snapshot.data!.docs[index]["title"]);
                        }
                        return Container(
                            color: Colors.transparent,
                            width: size.width*0.3,
                            height: size.height*0.2,
                            child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: _showModalBottomSheetShapeBorder(),
                                      builder: (BuildContext context) {
                                        var imdb = snapshot.data!.docs[index]["imdb"];
                                        var actor =
                                            snapshot.data!.docs[index]["imdb"];
                                        return BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 0.9, sigmaY: 0.9),
                                            child: ContentWidget(
                                                size: size,
                                                snapshot: snapshot,
                                                index: index, favoriteContent: contentList));
                                      });
                                },
                                child: Image.network(
                                    snapshot.data!.docs[index]["contentImageUrl"])));
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ));
  }

  ShapeBorder _showModalBottomSheetShapeBorder(){
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
      topRight: Radius.circular(20),
      topLeft: Radius.circular(20)),
  );}


}
