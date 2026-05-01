import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketplace_app/core/models/user_model.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? get currentUser => firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user == null) return null;


      if (!user.emailVerified) {
        await firebaseAuth.signOut();
        return null;
      }


      return await getUser(user.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserModel?> register({
    required String userName,
    required String email,
    required String password,
    required String role,
    String? storeName,
    String? storeDescription,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;
      if (user == null) return null;


      await user.updateDisplayName(userName);


      UserModel newUser = UserModel(
        uid: user.uid,
        name: userName,
        email: email,
        role: role,
        storeName: role == 'vendor' ? storeName : null,
        storeDescription: role == 'vendor' ? storeDescription : null,
      );


      await firestore.collection("users").doc(user.uid).set(newUser.toMap());

      // Send verification email
      await user.sendEmailVerification();
      await firebaseAuth.signOut();

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("Registration failed. Please try again.");
    }
  }


  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
      await firestore.collection("users").doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception("Failed to fetch user data.");
    }
  }


  Future<bool> checkEmailVerified() async {
    User? user = firebaseAuth.currentUser;
    if (user == null) return false;
    await user.reload();
    return firebaseAuth.currentUser?.emailVerified ?? false;
  }


  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }


  Future<void> resetPassword({required String email}) async {
    try {
      // final QuerySnapshot userQuery = await firestore
      // .collection("users")
      // .where("email",isEqualTo: email)
      // .limit(1)
      // .get();
      //
      // if(userQuery.docs.isEmpty){
      //   throw Exception("No account found with this email");
      // }
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}