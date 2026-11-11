import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NotesRepository {
  final FirebaseFirestore _firestore;

  NotesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference> _notes(String uid) =>
      _firestore.collection('users').doc(uid).collection('notes');

  Stream<List<Note>> watchNotes(String uid) {
    return _notes(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> addNote({
    required String uid,
    required String title,
    required String body,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty || trimmedTitle.length > 100) {
      throw ArgumentError('Title must be between 1 and 100 characters');
    }

    final note = Note(
      id: '',
      title: trimmedTitle,
      body: body.trim(),
    );

    await _notes(uid).add(note.toFirestore());
  }

  Future<void> deleteNote({
    required String uid,
    required String noteId,
  }) async {
    await _notes(uid).doc(noteId).delete();
  }
}
