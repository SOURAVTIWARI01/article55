import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:society_voting_firebase/data/models/candidate_model.dart';
import 'package:society_voting_firebase/data/models/vote_model.dart';

class VotingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of approved candidates
  Stream<List<CandidateModel>> getApprovedCandidates() {
    return _firestore
        .collection('candidates')
        .where('status', isEqualTo: CandidateStatus.approved.name)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CandidateModel.fromMap(doc.data()))
            .toList());
  }

  // Cast vote with transaction
  Future<void> castVotes({
    required String voterId,
    required String flatId,
    required List<VoteModel> votes,
  }) async {
    return _firestore.runTransaction((transaction) async {
      // 1. Check if user already voted (redundancy check)
      final userDoc = await transaction.get(_firestore.collection('users').doc(voterId));
      if (userDoc.get('hasVoted') == true) {
        throw Exception('You have already cast your vote.');
      }

      // 2. Check flat uniqueness (Security mandate)
      final flatQuery = await _firestore
          .collection('votes')
          .where('flatId', isEqualTo: flatId)
          .limit(1)
          .get();

      if (flatQuery.docs.isNotEmpty) {
        throw Exception('A vote has already been submitted for this flat.');
      }

      // 3. Batch write votes
      for (var vote in votes) {
        final voteRef = _firestore.collection('votes').doc();
        transaction.set(voteRef, vote.toMap());

        // 4. Update candidate counts (Real-time update)
        final candidateRef = _firestore.collection('candidates').doc(vote.candidateId);
        if (vote.isUpvote) {
          transaction.update(candidateRef, {'votesUp': FieldValue.increment(1)});
        } else {
          transaction.update(candidateRef, {'votesDown': FieldValue.increment(1)});
        }
      }

      // 5. Mark user as voted
      transaction.update(_firestore.collection('users').doc(voterId), {'hasVoted': true});
    });
  }

  // Stream for live results
  Stream<List<CandidateModel>> getLiveResults() {
    return _firestore.collection('candidates').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => CandidateModel.fromMap(doc.data())).toList());
  }
}
