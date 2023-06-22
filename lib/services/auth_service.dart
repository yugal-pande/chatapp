import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/services/database_servce.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

//Sign in function
Future loginWithUserWithEmailandPassword(String email, String password) async{
  try{
    User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;

    if(user!=null){
      return true;
    }
  }
  on FirebaseAuthException catch(e){
    return e.message;
  }
} 

//Register User Function
Future registerUserWithEmailandPassword(String fullName, String email, String password) async{
  try{
    User user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;

    if(user!=null){
      //Call our database service to update the user data
      await DatabaseService(uid: user.uid).savingUserData(fullName, email);
      return true;
    }
  }
  on FirebaseAuthException catch(e){
    return e.message;
  }
}

//Log Out Function
Future SignOut() async{
  try{
    await HelperFunctions.saveUserLoggedInStatus(false);
    await HelperFunctions.saveUserEmailSF("");
    await HelperFunctions.saveUserNameSF("");
    await firebaseAuth.signOut(); 
  }catch (e){
    return null;
  }
}
}
