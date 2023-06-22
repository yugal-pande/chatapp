import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/pages/home_page.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/database_servce.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/pages/auth/login_page.dart';
import 'package:chatapp/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  String userName;
  String email;
  ProfilePage({super.key, required this.email, required this.userName});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late String picURL = "";

  @override
  void initState() {
    getPicURL();
    super.initState();
  }

  getPicURL()async{
    DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getProfilePicUrl().then((url){
    setState(() {
      picURL = url;
    });
   });
  }

  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Profile",style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),),
      ),
      drawer: Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: <Widget>[
            Icon(Icons.account_circle, size: 150, color: Colors.grey[700]),
            SizedBox(height: 15,),
            Text(widget.userName, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 30,),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: (){
                nextScreen(context, const HomePage());
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: (){
              },
              selected: true,
              selectedColor: Theme.of(context).primaryColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.person),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async{
                showDialog(barrierDismissible: false, context: context, builder: (context){ // Barrier Dismissible True will not close the popup if we click anywhere outside it.
                  return AlertDialog(
                    title: const Text("Log Out?"),
                    content: const Text("Are you sure you want to Log Out?"),
                    actions: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.cancel, color: Colors.red,),
                      ),
                      IconButton(onPressed: () async{
                        await authService.SignOut();
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false);
                      },
                      icon: const Icon(Icons.done, color: Colors.green,),
                      ),
                    ],
                  );
                });
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "Log Out",
                style: TextStyle(color: Colors.black),
              ),
            )
        ],
      ),
     ),
     body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Stack(
            children: [
              //const CircleAvatar(
                //radius: 64,
                //backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                //backgroundColor: Colors.black,
              //),

              ClipOval(
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: picURL,
                  height: 100,
                  width: 100,
                  placeholder: (context, url) => CircularProgressIndicator(color: Theme.of(context).primaryColor),
                  errorWidget: (context, url, error) => const Icon(Icons.account_circle, size: 100, color: Colors.grey,),
                ),
              ),
              Positioned(bottom: -10,
              left: 50,
              child: IconButton(onPressed: () { 
                DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).pickImage();
                showSnackbar(context, Colors.green, "Profile Picture Updated Seuccessfully!");
                Future.delayed(const Duration(seconds: 5), () {
                  nextScreenReplace(context, ProfilePage(userName: widget.userName, email: widget.email,));
                });
                },
              icon: const Icon(Icons.add_a_photo),
              ),
              )
            ],
          ),

          //const Icon(
            //Icons.account_circle,
            //size: 200,
            //color: Colors.grey,
          //),

          const SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Full Name", style: TextStyle(fontSize: 17)),
              Text(widget.userName, style: const TextStyle(fontSize: 17)),
            ],
          ),
         const Divider(height: 20,),
         Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Email", style: TextStyle(fontSize: 17)),
              Text(widget.email, style: const TextStyle(fontSize: 17)),
            ],
          ),
        ],
      ),
     ),
    );
  }

  //Uint8List? _image;
  //void selectImage()async{
    //Uint8List img = await pickImage(ImageSource.gallery);
    //setState(() {
      //_image = img;
    //});
  //}

}
