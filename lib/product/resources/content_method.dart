

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:softwareproject/model/content_model.dart';

class ContentMethod{
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  FirebaseAuth auth=FirebaseAuth.instance;



    Future<String> createContent({
      required String title,
      required String description,
      required List<String> actors,
      required String director,
      required String maturityLevel,
      required String type,
      required String imdb,
      required String releaseDate,
      required String contentImageUrl
      })async{

    String res="Some error occurred";

    try{
      if(
        title.isNotEmpty && 
        description.isNotEmpty && 
        actors.isNotEmpty && 
        director.isNotEmpty && 
        maturityLevel.isNotEmpty &&
        type.isNotEmpty &&
        imdb.isNotEmpty &&
        releaseDate.isNotEmpty &&
        contentImageUrl.isNotEmpty
        ){
          final DocumentReference ref = _firestore.collection("content").doc();
          ContentModel contentModel=ContentModel(uid: ref.id.toString(),authorId: auth.currentUser!.uid, title: title, description: description, actors: actors, contentImageUrl: contentImageUrl, director: director, imdb: imdb, maturityLevel: maturityLevel, releaseDate: releaseDate, type: type, );
          await _firestore.collection("content").doc(ref.id.toString()).set(contentModel.toJson());
          
          await _firestore.collection("users").doc(auth.currentUser!.uid.toString()).update({"myPostList":FieldValue.arrayUnion([ref.id.toString()])});
          res = "success";
        }else{
          res = "Lütfen tüm alanları doldurunuz.";
        }
    }catch(err){
      res=err.toString();
    }
    
    return res;


  }

   Future<String> favoriteContent({required String postId, required String userId,required  List<String> likes} ) async {
    String res = "Some error occurred";

    try {
        if (likes.contains(postId)){
         await _firestore.collection('users').doc(userId).update({
          'myContentList': FieldValue.arrayRemove([postId])
        });
        }else{
          await _firestore.collection('users').doc(userId).update({
          'myContentList': FieldValue.arrayUnion([postId])
        });
        }
        // if the likes list contains the user uid, we need to remove it
        
      
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  
Future<String> updateContent({
  required String contentId,
  required String title,
  required String description,
  required List<String> actors,
  required String director,
  required String maturityLevel,
  required String type,
  required String imdb,
  required String releaseDate,
  required String contentImageUrl,
}) async {
  String res = "Some error occurred";

  try {
    if (title.isNotEmpty &&
        description.isNotEmpty &&
        actors.isNotEmpty &&
        director.isNotEmpty &&
        maturityLevel.isNotEmpty &&
        type.isNotEmpty &&
        imdb.isNotEmpty &&
        releaseDate.isNotEmpty &&
        contentImageUrl.isNotEmpty) {
      ContentModel updatedContent = ContentModel(
        uid: contentId,
        authorId: auth.currentUser!.uid,
        title: title,
        description: description,
        actors: actors,
        contentImageUrl: contentImageUrl,
        director: director,
        imdb: imdb,
        maturityLevel: maturityLevel,
        releaseDate: releaseDate,
        type: type,
      );

      await _firestore
          .collection("content")
          .doc(contentId)
          .update(updatedContent.toJson());

      res = "success";
    } else {
      res = "Lütfen tüm alanları doldurunuz.";
    }
  } catch (err) {
    res = err.toString();
  }

  return res;
}



Future<void> removeContentUser({required String selectedContent}) async {
  User currentUser = await FirebaseAuth.instance.currentUser!;
  String userId = currentUser.uid;

  // Kullanıcının myPostList'inde ilgili içeriğin ID'sini sil
  await _firestore.collection("users").doc(userId).update({
    "myPostList": FieldValue.arrayRemove([selectedContent])
  });

  // Tüm kullanıcıları kontrol et
  QuerySnapshot querySnapshot = await _firestore.collection("users").get();

  for (DocumentSnapshot userDoc in querySnapshot.docs) {
  Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

  if (userData != null) {
    List<dynamic>? myContentList = userData['myContentList'] as List<dynamic>?;

    if (myContentList != null && myContentList.contains(selectedContent)) {
      myContentList.remove(selectedContent);

      // Kullanıcının myContentList'ini güncelle
      await userDoc.reference.update({'myContentList': myContentList});
    }
  }
}

  // İçeriği sil
  await _firestore.collection("content").doc(selectedContent).delete();
}


void deleteMovieForAdmin(String movieId) {
  FirebaseFirestore.instance.collection('content').doc(movieId).delete().then((_) {
    // Film belgesini sildikten sonra kullanıcı belgelerini güncelle

    FirebaseFirestore.instance.collection('users').get().then((querySnapshot) {
      querySnapshot.docs.forEach((userDoc) {
        // Kullanıcının myPostList'inde ilgili film ID'sini sil
        List<String> myPostList = List.from(userDoc.data()['myPostList']);
        if (myPostList.contains(movieId)) {
          myPostList.remove(movieId);
          userDoc.reference.update({'myPostList': myPostList});
        }

        // Kullanıcının myContentList'inde ilgili film ID'sini sil
        List<String> myContentList = List.from(userDoc.data()['myContentList']);
        if (myContentList.contains(movieId)) {
          myContentList.remove(movieId);
          userDoc.reference.update({'myContentList': myContentList});
        }
      });
    });
  }).catchError((error) {
    print("Film silinirken bir hata oluştu: $error");
  });
}
  



}