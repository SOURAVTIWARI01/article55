import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_voting_firebase/data/models/candidate_model.dart';

class CandidateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Submit candidate application
  Future<void> submitApplication({
    required CandidateModel candidate,
    required File photoFile,
  }) async {
    // 1. Check file size (10MB limit)
    final sizeInBytes = await photoFile.length();
    if (sizeInBytes > 10 * 1024 * 1024) {
      throw Exception('Photo size must be less than 10MB.');
    }

    // 2. Upload photo
    final photoRef = _storage.ref().child('candidate_profiles/${candidate.id}.jpg');
    await photoRef.putFile(photoFile);
    final photoUrl = await photoRef.getDownloadURL();

    // 3. Save to Firestore
    final updatedCandidate = CandidateModel(
      id: candidate.id,
      name: candidate.name,
      post: candidate.post,
      summary: candidate.summary,
      photoUrl: photoUrl,
      status: CandidateStatus.pending,
      createdAt: candidate.createdAt,
    );

    await _firestore
        .collection('candidates')
        .doc(candidate.id)
        .set(updatedCandidate.toMap());
  }

  // Admin: Approve candidate
  Future<void> updateStatus(String candidateId, CandidateStatus status) async {
    await _firestore
        .collection('candidates')
        .doc(candidateId)
        .update({'status': status.name});
  }

  // Admin: Delete candidate with reason (reason logged separately if needed)
  Future<void> deleteCandidate(String candidateId) async {
    await _firestore.collection('candidates').doc(candidateId).delete();
    await _storage.ref().child('candidate_profiles/$candidateId.jpg').delete();
  }
}
