import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:softwareproject/product/constant/colors.dart';
import 'package:softwareproject/product/constant/icon.dart';
import 'package:softwareproject/product/resources/content_method.dart';
import 'package:softwareproject/screens/update_page_view.dart';

class ProfilePageView extends StatefulWidget {
  const ProfilePageView({super.key});

  @override
  State<ProfilePageView> createState() => _ProfilePageViewState();
}

class _ProfilePageViewState extends State<ProfilePageView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Yayınladıklarım"),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(_auth.currentUser!.uid) // oturum açmış kullanıcının uid'si
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: Colors.black,),
              );
            }
    
            print(snapshot.data.data());
            print(snapshot.data.data()["myPostList"]);
    
            List<dynamic> myPostList = snapshot.data.data()["myPostList"];
            return ListView.builder(
              itemCount: myPostList.length,
              itemBuilder: (context, index) {
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('content')
                      .doc(myPostList[index]) // myPostList içindeki ilan id'si
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      print("bura calisti");
                      return CircularProgressIndicator();
                    }
                    DocumentSnapshot advertisement = snapshot.data!;
                    print("simdi bura calisti");
                    print(advertisement['title']);
                    
                    return Card(
                      color: ProjectColor().redButtonColor,
                      child: ListTile(
                        title: Text(advertisement['title'],style: TextStyle(color: Colors.white),),
                        subtitle: Text(advertisement['description'],style: TextStyle(color: Colors.white)),
                        trailing: IconButton(icon: Icon(ProjectIcon().updateIcon,color: ProjectColor().blackButtonColor),onPressed: (){
                          Navigator.push(context,MaterialPageRoute(builder: (context) =>  UpdatePageView(postId: advertisement['uid'],)),);
                        },),
                        leading: IconButton(icon: Icon(ProjectIcon().deleteIcon,color: ProjectColor().blackButtonColor,),onPressed: (){
                          ContentMethod().removeContentUser(selectedContent: advertisement['uid']);
                        },)
                    ));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}