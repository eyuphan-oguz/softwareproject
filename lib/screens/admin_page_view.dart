import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:softwareproject/product/constant/colors.dart';
import 'package:softwareproject/product/constant/icon.dart';
import 'package:softwareproject/product/constant/padding.dart';
import 'package:softwareproject/product/resources/content_method.dart';
import 'package:softwareproject/screens/update_page_view.dart';
 
class AdminPageView extends StatefulWidget {
  const AdminPageView({super.key});

  @override
  State<AdminPageView> createState() => _AdminPageViewState();
}
final FirebaseAuth _auth = FirebaseAuth.instance;

class _AdminPageViewState extends State<AdminPageView> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(

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

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                if(snapshot.data!.docs[index]["type"]=="Aksiyon"){
                  print(snapshot.data!.docs[index]["title"]);
                  
                }
                return Card(
              color: ProjectColor().redButtonColor,
              child: ListTile(
                title: Text(snapshot.data!.docs[index]["title"],style: TextStyle(color: Colors.white),),
                subtitle: Text(snapshot.data!.docs[index]["description"],style: TextStyle(color: Colors.white)),
                trailing: IconButton(icon: Icon(ProjectIcon().updateIcon,color: ProjectColor().blackButtonColor),onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context) =>  UpdatePageView(postId: snapshot.data!.docs[index]["uid"],)),);
                },),
                leading: IconButton(icon: Icon(ProjectIcon().deleteIcon,color: ProjectColor().blackButtonColor,),onPressed: (){
                  ContentMethod().deleteMovieForAdmin(snapshot.data!.docs[index]["uid"]);
                },)
            ));
              },
            );
          },
        ),
      ),
    ));
  }
}