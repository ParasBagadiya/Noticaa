import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/models/folder_model.dart';
import 'package:noticaa/models/note_model.dart';
import 'package:noticaa/providers/note_provider.dart';
import 'package:noticaa/providers/folder_provider.dart';
import 'package:noticaa/providers/category_provider.dart';
import 'package:noticaa/widgets/note_card.dart' as note_card;
import 'package:noticaa/services/animation_service.dart';
import 'package:noticaa/pages/note_editor_screen.dart';
import 'package:noticaa/pages/rich_text_editor_screen.dart';

class FolderContentsScreen extends StatelessWidget {
  final String folderId;

  const FolderContentsScreen({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    final folderProvider = Provider.of<FolderProvider>(context);
    final noteProvider = Provider.of<NoteProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final folder = folderProvider.getFolderById(folderId);
    final folderNotes = noteProvider.getNotesByFolder(folderId);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(folder.name),
            Text(
              '${folderNotes.length} ${folderNotes.length == 1 ? 'note' : 'notes'}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: folderNotes.isEmpty
          ? _buildEmptyFolderState(folder)
          : _buildNotesList(folderNotes, categoryProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNoteInFolder(context, folderId),
        tooltip: 'Create Note in Folder',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyFolderState(Folder folder) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimationService.emptyFolderAnimation1(size: 180),
            SizedBox(height: 20),
            Text(
              '${folder.name} is empty',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This folder does\'t have any notes yet.\nTap the + button to create your first note here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: folder.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: folder.color),
                  SizedBox(width: 8),
                  Text(
                    'Folder created: ${_formatDate(folder.createdAt)}',
                    style: TextStyle(color: folder.color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(
    List<NoteModel> notes,
    CategoryProvider categoryProvider,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final category = categoryProvider.getCategoryById(note.categoryId);
        return note_card.NoteCard(
          note: note,
          category: category,
          onMoveToFolder: (noteId) {
            // Handle moving notes if needed
          },
        );
      },
    );
  }

  void _createNoteInFolder(BuildContext context, String folderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Note'),
        content: Text('Choose editor type:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createPlainTextNote(context, folderId);
            },
            child: Text('Plain Text'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createRichTextNote(context, folderId);
            },
            child: Text('Rich Text'),
          ),
        ],
      ),
    );
  }

  void _createPlainTextNote(BuildContext context, String folderId) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    final newNote = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Note',
      content: 'Start writing...',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
      categoryId: 'default',
      folderId: folderId,
      formatType: 'plain',
    );
    noteProvider.addNote(newNote);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditorScreen(note: newNote)),
    );
  }

  void _createRichTextNote(BuildContext context, String folderId) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    final newNote = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Rich Text Note',
      content: 'Start writing with formatting...',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
      categoryId: 'default',
      folderId: folderId,
      formatType: 'rich',
    );
    noteProvider.addNote(newNote);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RichTextEditorScreen(note: newNote),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
