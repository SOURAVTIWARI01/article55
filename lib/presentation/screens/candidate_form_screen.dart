import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:society_voting_firebase/data/models/candidate_model.dart';
import 'package:society_voting_firebase/services/candidate_service.dart';
import 'package:uuid/uuid.dart';

final candidateServiceProvider = Provider((ref) => CandidateService());

class CandidateFormScreen extends ConsumerStatefulWidget {
  const CandidateFormScreen({super.key});

  @override
  ConsumerState<CandidateFormScreen> createState() => _CandidateFormScreenState();
}

class _CandidateFormScreenState extends ConsumerState<CandidateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _summaryController = TextEditingController();
  
  String _selectedPost = 'President';
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _posts = ['President', 'Secretary', 'Treasurer'];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      setState(() => _isLoading = true);
      try {
        final candidate = CandidateModel(
          id: const Uuid().v4(),
          name: _nameController.text,
          post: _selectedPost,
          summary: _summaryController.text,
          photoUrl: '', // Uploaded by service
          createdAt: DateTime.now(),
        );

        await ref.read(candidateServiceProvider).submitApplication(
          candidate: candidate,
          photoFile: _imageFile!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application submitted for admin approval!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a profile photo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Application'),
        backgroundColor: const Color(0xFF0B3C5D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apply for Office Bearer',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0B3C5D)),
              ),
              const SizedBox(height: 8),
              const Text('Submit your candidature for the 2026 Society Elections.'),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null 
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                      : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? 'Enter full name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPost,
                decoration: const InputDecoration(
                  labelText: 'Post Applying For',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                items: _posts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => setState(() => _selectedPost = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _summaryController,
                maxLines: 5,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Brief Summary / Vision (Max 300 words)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Enter summary';
                  if (v.split(' ').length > 300) return 'Summary must be < 300 words';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B3C5D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Candidature', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
