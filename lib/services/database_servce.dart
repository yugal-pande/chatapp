import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

class DatabaseService{
  final String? uid;
    DatabaseService({this.uid});

    //Reference for our collections on Firebase
    final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
    final CollectionReference groupCollection = FirebaseFirestore.instance.collection("groups");

    //Saving the user data
    Future savingUserData(String fullName, String email)async{
      return await userCollection.doc(uid).set({
        "fullName": fullName,
        "email": email,
        "groups": [],
        "profilePic": "",
        "uid": uid,
    });
    }

    //Getting user data
    Future gettingUserData(String email) async{
      QuerySnapshot snapshot = await userCollection.where("email", isEqualTo: email).get();
      return snapshot;
    }

    //Get user groups
    getUserGroups() async{
      return userCollection.doc(uid).snapshots();
    }

    //Creating a group
    Future createGroup(String userName, String id, String groupName) async{
      DocumentReference groupDocumentReference = await groupCollection.add({
        "groupName": groupName,
        "groupIcon": "",
        "admin": "${id}_$userName",
        "members": [],
        "groupId": "",
        "recentMessage": "",
        "recentMessageSender": "",
      });

      //Update the members
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"]),
        "groupId": groupDocumentReference.id,
      });

      DocumentReference userDocumentReference = userCollection.doc(uid);
      return await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
      });
    }

    //Getting the chats
    getChats(String groupId) async{
      return groupCollection.doc(groupId).collection("messages").orderBy("time").snapshots();
    }

    //Function to get group admin
    Future getGroupAdmin(String groupId) async{
      DocumentReference d = groupCollection.doc(groupId);
      DocumentSnapshot documentSnapshot = await d.get();
      return documentSnapshot['admin'];
    }

    //Getting group members
    getGroupMembers(groupId) async{
      return groupCollection.doc(groupId).snapshots();
    }

    //Search
    searchByName(String groupName){
      return groupCollection.where("groupName", isEqualTo: groupName).get();
    }

    //Function to check if a user is in a particular group or not
    Future <bool> isUserJoined(String groupName, String groupId, String userName)async{
      DocumentReference userDocumentReference = userCollection.doc(uid);
      DocumentSnapshot documentSnapshot = await userDocumentReference.get();

      List<dynamic> groups = documentSnapshot['groups'];
      if(groups.contains("${groupId}_$groupName")){
        return true;
      }
      else{
        return false;
      }
    }

    //Function to join or exit group
    Future toggleGroupJoin(String groupId, String userName, String groupName) async{
      DocumentReference userDocumentReference = userCollection.doc(uid);
      DocumentReference groupDocumentReference = groupCollection.doc(groupId);

      DocumentSnapshot documentSnapshot =await userDocumentReference.get();
      List<dynamic> groups = await documentSnapshot['groups'];

      if(groups.contains("${groupId}_$groupName")){
        await userDocumentReference.update({
          "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
        });
        await groupDocumentReference.update({
          "members": FieldValue.arrayRemove(["${uid}_$userName"])
        });
      }
      else{
        await userDocumentReference.update({
          "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
        });
        await groupDocumentReference.update({
          "members": FieldValue.arrayUnion(["${uid}_$userName"])
        });
      }
    }

    //Funtion to send the messages
    sendMessage(String groupId, Map<String, dynamic> chatMessageData)async{
      groupCollection.doc(groupId).collection("messages").add(chatMessageData);
      groupCollection.doc(groupId).update({
        "recentMessage": chatMessageData['message'],
        "recentMessageSender": chatMessageData['sender'],
        "recentMessageTime": chatMessageData['time'].toString(),
      });
    }

   late Rx<File?> _pickedImage;
  
  //Function to access gallery and pick an image
  void pickImage()async{
  final PickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
  if(PickedImage!=null){
    Get.snackbar('Profile Picture', "You have sussessfully selcted your profile picture!");
  }
  _pickedImage = Rx<File?>(File(PickedImage!.path));
  String downloadUrl = await _uploadToStorage(_pickedImage.value!);
  updateProfiePic(downloadUrl);
}

// Function to upload the picked image to Storage
Future<String> _uploadToStorage(File image) async{
      Reference ref = FirebaseStorage.instance.ref().child('profilePic').child(FirebaseAuth.instance.currentUser!.uid);

     UploadTask uploadTask = ref.putFile(image);
     TaskSnapshot snap = await uploadTask;
     String downloadUrl = await snap.ref.getDownloadURL();
     return downloadUrl;
    }

    //Function to update the profile photo
    Future updateProfiePic(String downloadUrl)async{
      DocumentReference userDocumentReference = userCollection.doc(uid);
      await userDocumentReference.update({
          "profilePic": downloadUrl
        });
    }
    //Function to get the profile photo URL to display
    Future<String> getProfilePicUrl()async{
      DocumentReference userDocumentReference = userCollection.doc(uid);
      DocumentSnapshot documentSnapshot = await userDocumentReference.get();
      return documentSnapshot['profilePic'];
    }

    //Future<bool> checkUsernameExists(String val)async{
      //DocumentReference userDocumentReference = userCollection.doc(uid);
      //DocumentSnapshot documentSnapshot = await userDocumentReference.get();
      //return documentSnapshot['fullName'].contains(val);
    //}
}


//Constants:
// var firebaseAuth = FirebaseAuth.instance;
// var firebaseStorage = FirebaseStorage.instance;
// var firestore = FirebaseFirestore.instance;
// var databaseService = DatabaseService().instance;