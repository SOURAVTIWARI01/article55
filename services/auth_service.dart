import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_voting_firebase/data/models/voter_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth changes
  Stream<User?> get user => _auth.authStateChanges();

  // Send OTP
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: onVerificationFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Sign in with OTP
  Future<UserCredential> signInWithOTP(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Register Voter
  Future<void> registerVoter(VoterModel voter) async {
    // Check if flat is already registered
    final flatQuery = await _firestore
        .collection('users')
        .where('blockNumber', isEqualTo: voter.blockNumber)
        .where('flatNumber', isEqualTo: voter.flatNumber)
        .get();

    if (flatQuery.docs.isNotEmpty) {
      throw Exception('This flat is already registered for voting.');
    }

    await _firestore.collection('users').doc(voter.uid).set(voter.toMap());
  }

  // Get current voter data
  Future<VoterModel?> getCurrentVoter() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    
    return VoterModel.fromMap(doc.data()!);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
