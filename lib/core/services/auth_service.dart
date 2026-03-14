import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  // singleton instance
  final FirebaseAuth firebaseAuth=FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get currentUser => firebaseAuth.currentUser;  
   
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<User?> signIn({
    required String email,
    required String password,
  })async{
    try{
      UserCredential userCredential =
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if(user !=null && !user.emailVerified){
        await user.sendEmailVerification();
       
      }
      return user;
    }on FirebaseAuthException catch (e){
      print(e.message);
      return null;
    }
  }
  


  Future<User?> register({
    required String email,
    required String password,
    required String role
  }) async{
    try{
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user;
    if(user !=null){
      await firestore.collection("users").doc(user.uid).set({
        "email":email,
        "role":role
      });

      if(!user.emailVerified){
      await user.sendEmailVerification();
    }
    }
    
    return user;

    } on FirebaseAuthException catch (e){
      print(e.message);
      return null;
    }
    
  }
  Future<void> checkEmailVerified() async {

  User? user = FirebaseAuth.instance.currentUser;
  if(user==null) return;

  await user.reload();
  if (user.emailVerified) {
    print("Email verified");
  } else {
    print("Email not verified");
  }

}

  Future<void> signOut() async{
    try{
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e){
      print(e.message);
    }
  }

  Future<void> resetPassword({
    required String email
  }) async{
    try{
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e){
      print(e.message);
      
    }
  }

  Future<void> updateUsername({
    required String username
  }) async{
    try {
      await currentUser!.updateDisplayName(username );
    } on FirebaseAuthException catch (e){
      print(e.message);
      
    }
  }

  Future<String?> getUserRole(String uid) async{
    DocumentSnapshot doc= await firestore.collection("users").doc(uid).get();

    return doc["role"];
  }



}  