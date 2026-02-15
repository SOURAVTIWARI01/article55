import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:society_voting_firebase/data/models/candidate_model.dart';
import 'package:society_voting_firebase/services/candidate_service.dart';
import 'package:society_voting_firebase/services/voting_service.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Control Panel'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminCard(
            context,
            title: 'Candidate Management',
            subtitle: 'Approve or reject applications',
            icon: Icons.people_outline,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CandidateApprovalScreen())),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Election Reports',
            subtitle: 'Live results and CSV exports',
            icon: Icons.bar_chart,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveResultsScreen())),
          ),
          const SizedBox(height: 16),
          _buildAdminCard(
            context,
            title: 'Security Logs',
            subtitle: 'Monitor voting activity and flat duplicates',
            icon: Icons.security,
            onTap: () {}, // Future implementation
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: CircleAvatar(backgroundColor: Colors.red[50], child: Icon(icon, color: Colors.red[900])),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class CandidateApprovalScreen extends ConsumerWidget {
  const CandidateApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidateService = ref.read(Provider((ref) => CandidateService()));
    
    return Scaffold(
      appBar: AppBar(title: const Text('Approve Candidates'), backgroundColor: Colors.red[900], foregroundColor: Colors.white),
      body: StreamBuilder<List<CandidateModel>>(
        stream: FirebaseFirestore.instance.collection('candidates').snapshots().map((s) => s.docs.map((d) => CandidateModel.fromMap(d.data())).toList()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final candidates = snapshot.data!;
          
          return ListView.builder(
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final c = candidates[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(c.photoUrl)),
                  title: Text(c.name),
                  subtitle: Text('${c.post} • ${c.status.name.toUpperCase()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (c.status == CandidateStatus.pending) ...[
                        IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => candidateService.updateStatus(c.id, CandidateStatus.approved)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => candidateService.updateStatus(c.id, CandidateStatus.rejected)),
                      ],
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => candidateService.deleteCandidate(c.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LiveResultsScreen extends ConsumerWidget {
  const LiveResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Election Results')),
      body: StreamBuilder<List<CandidateModel>>(
        stream: ref.read(votingServiceProvider).getLiveResults(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final candidates = snapshot.data!;
          final posts = ['President', 'Secretary', 'Treasurer'];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: posts.map((post) {
              final postCandidates = candidates.where((c) => c.post == post).toList();
              final totalVotes = postCandidates.fold(0, (sum, c) => sum + c.votesUp);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...postCandidates.map((c) {
                    final percent = totalVotes == 0 ? 0.0 : (c.votesUp / totalVotes);
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(c.photoUrl)),
                          title: Text(c.name),
                          trailing: Text('${c.votesUp} Votes (${(percent * 100).toStringAsFixed(1)}%)'),
                        ),
                        LinearProgressIndicator(value: percent, minHeight: 8, borderRadius: BorderRadius.circular(4)),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                  const Divider(height: 48),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
