import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/auth_repository.dart';
import '../data/notes_repository.dart';
import '../models/note.dart';
import 'add_note_dialog.dart';

class NotesScreen extends StatelessWidget {
  final String? uid;
  final NotesRepository? notesRepository;
  final AuthRepository? authRepository;

  const NotesScreen({
    super.key,
    this.uid,
    this.notesRepository,
    this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    NotesRepository repo;
    try {
      repo = notesRepository ?? context.read<NotesRepository>();
    } catch (_) {
      repo = notesRepository ?? NotesRepository();
    }

    AuthRepository? auth;
    try {
      auth = authRepository ?? context.read<AuthRepository>();
    } catch (_) {
      auth = authRepository;
    }

    final effectiveUid = uid ?? auth?.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async => await auth?.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Note>>(
        stream: repo.watchNotes(effectiveUid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load notes.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data ?? [];
          if (notes.isEmpty) {
            return const Center(child: Text('No notes yet'));
          }
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Dismissible(
                key: Key(note.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  repo.deleteNote(effectiveUid, note.id);
                },
                child: ListTile(
                  title: Text(note.title),
                  subtitle: Text(note.body),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add note',
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (ctx) => const AddNoteDialog(),
          );
          if (result == null) return;

          String title = '';
          String body = '';

          if (result is (String, String)) {
            title = result.$1;
            body = result.$2;
          } else if (result is Map) {
            title = result['title']?.toString() ?? '';
            body = result['body']?.toString() ?? '';
          } else {
            try {
              title = (result as dynamic).title?.toString() ?? '';
              body = (result as dynamic).body?.toString() ?? '';
            } catch (_) {}
          }

          if (title.trim().isNotEmpty) {
            await repo.addNote(effectiveUid, title, body);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}