import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_study_notes/data/notes_repository.dart';
import 'package:lab05_study_notes/models/note.dart';

void main() {
  setUpAll(FakeFirebaseFirestore.new);

  test('Note.fromFirestore throws FormatException when title is not a string', () {
    expect(
      () => Note.fromFirestore('note-1', {'title': 12345, 'body': 'Sample body'}),
      throwsA(isA<FormatException>()),
    );
  });

  test('NotesRepository.addNote throws ArgumentError when title is over 100 chars', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = NotesRepository(firestore);
    final longTitle = 'a' * 101;

    expect(
      () => repo.addNote('user-1', longTitle, 'Test body'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
