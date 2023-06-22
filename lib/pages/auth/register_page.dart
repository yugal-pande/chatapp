import 'package:chatapp/helper/helper_function.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:chatapp/pages/auth/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget> [
                const Text("Groupie", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
                const SizedBox(height: 10),
                const Text("Create your accont now to chat and explore!", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),),
                  Image.asset("assets/register.png"),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person,color: Theme.of(context).primaryColor,),
                    ),
                    onChanged: (val){
                      setState(() {
                        fullName = val;
                      });
                    },
                    validator: (val){
                      if(val!.isNotEmpty){
                        return null;
                      }
                      else{
                        return "Name cannot be empty";
                      }
                    },
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email,color: Theme.of(context).primaryColor,),
                    ),
                    onChanged: (val){
                      setState(() {
                        email = val;
                      });
                    },
                    validator: (val){
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val!) ? null : "Please Enter a valid email";
                    },
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    obscureText: true,
                    decoration: textInputDecoration.copyWith(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock,color: Theme.of(context).primaryColor,),
                    ),
                    validator: (val){
                      if(val!.length < 6){
                        return "Password must be atleast 6 characters long"; 
                      }
                      else{
                        return null;
                      }
                    },
                    onChanged: (val){
                      setState(() {
                        password = val;
                      });
                    },
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    obscureText: true,
                    decoration: textInputDecoration.copyWith(
                      labelText: "Confirm Password",
                      prefixIcon: Icon(Icons.lock,color: Theme.of(context).primaryColor,),
                    ),
                    validator: (val){
                      if(val!.length < 6){
                        return "Password must be atleast 6 characters"; 
                      }
                      else{
                        if(val != password){
                        return "The two passwords must be the same";
                      }
                      else{
                        return null;
                      }
                      }
                    },
                  ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                      ),
                      child: const Text("Register", style: TextStyle(color: Colors.white, fontSize: 16),),
                      onPressed: (){
                        register();
                      },
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      children: <TextSpan>[
                        TextSpan(
                          text: "Login Now",
                          style: const TextStyle(color: Colors.black, decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            nextScreen(context, const LoginPage());
                          }
                        ),
                      ],
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    )
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  register() async{
    if(formKey.currentState!.validate() && await checkUsernameExists(fullName)==true){
      setState(() {
        _isLoading = true;
      });
      await authService.registerUserWithEmailandPassword(fullName, email, password).then((value)async{
        if (value == true){
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(fullName);
          nextScreenReplace(context, const HomePage());
        }
        else{
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
    if(await checkUsernameExists(fullName)==false){
      showSnackbar(context, Colors.red, "Username already exists");
    }
  }
  Future<bool> checkUsernameExists(String val)async{
      final CollectionReference userCollection  = FirebaseFirestore.instance.collection("users");
      QuerySnapshot snapshot = await userCollection.where("fullName", isEqualTo: val).get();
      if(snapshot.docs.isEmpty){
        return true;
      }
      else{
        return false;
      }
    }
}
