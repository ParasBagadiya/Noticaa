import 'package:flutter/material.dart';
import 'package:noticaa/models/note_model.dart';
import 'package:noticaa/services/animation_service.dart';
import 'package:noticaa/services/storage_service.dart';

class NoteProvider with ChangeNotifier {
  List<NoteModel> _notes = [];
  final StorageService _storageService = StorageService();
  String _currentCategory = 'default';
  String _currentFolder = 'inbox';

  List<NoteModel> get notes => _notes;
  String get currentCategory => _currentCategory;
  String get currentFolder => _currentFolder;

  List<NoteModel> get filteredNotes {
    // Filter by folder first
    List<NoteModel> folderNotes = _currentFolder == 'all'
        ? _notes
        : _notes.where((note) => note.folderId == _currentFolder).toList();

    // Then filter by category
    if (_currentCategory == 'default') {
      return folderNotes;
    }
    return folderNotes
        .where((note) => note.categoryId == _currentCategory)
        .toList();
  }

  // Pinned notes getters
  List<NoteModel> get pinnedNotes =>
      filteredNotes.where((note) => note.isPinned).toList();

  List<NoteModel> get unpinnedNotes =>
      filteredNotes.where((note) => !note.isPinned).toList();

  // Get all pinned notes (across all folders)
  List<NoteModel> get allPinnedNotes =>
      _notes.where((note) => note.isPinned).toList();

  // Favorite notes getter
  List<NoteModel> get favoriteNotes =>
      _notes.where((note) => note.isFavorite).toList();

  // Get notes by folder
  List<NoteModel> getNotesByFolder(String folderId) {
    return _notes.where((note) => note.folderId == folderId).toList();
  }

  // Get folder note counts
  Map<String, int> getFolderNoteCounts() {
    final Map<String, int> counts = {};
    for (final note in _notes) {
      counts[note.folderId] = (counts[note.folderId] ?? 0) + 1;
    }
    return counts;
  }

  // Get sorted notes (pinned first, then by date)
  List<NoteModel> get sortedNotes {
    final pinned = pinnedNotes;
    final unpinned = unpinnedNotes;

    // Sort pinned notes by update date (newest first)
    pinned.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    // Sort unpinned notes by update date (newest first)
    unpinned.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return [...pinned, ...unpinned];
  }

  NoteProvider() {
    loadNotes();
  }

  Future<void> loadNotes() async {
    _notes = await _storageService.loadNotes();
    notifyListeners();
  }

  Future<void> addNote(NoteModel note) async {
    _notes.insert(0, note);
    await _storageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> updateNote(String id, NoteModel updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = updatedNote;
      await _storageService.saveNotes(_notes);
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _storageService.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> togglePin(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isPinned: !_notes[index].isPinned,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveNotes(_notes);
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(
        isFavorite: !_notes[index].isFavorite,
        updatedAt: DateTime.now(),
      );
      await _storageService.saveNotes(_notes);
      notifyListeners();
    }
  }

  // Move note to different folder with feedback
  Future<void> moveNoteToFolder(
    String noteId,
    String folderId,
    BuildContext context,
  ) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(folderId: folderId);
      await _storageService.saveNotes(_notes);
      notifyListeners();

      // Show success animation
      final currentContext = context;
      if (currentContext.mounted) {
        _showMoveSuccessMessage(context, folderId);
      }
    }
  }

  void _showMoveSuccessMessage(BuildContext context, String folderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            AnimationService.successAnimation(size: 30),
            SizedBox(width: 12),
            Expanded(child: Text('Note moved successfully!')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Optional: Navigate to the folder
          },
        ),
      ),
    );
  }

  // Category filter method
  void setCategoryFilter(String categoryId) {
    _currentCategory = categoryId;
    notifyListeners();
  }

  // Folder filter method
  void setFolderFilter(String folderId) {
    _currentFolder = folderId;
    notifyListeners();
  }

  List<NoteModel> searchNotes(String query) {
    if (query.isEmpty) return filteredNotes;

    final searchTerms = query.toLowerCase().split(' ');

    return filteredNotes.where((note) {
      final title = note.title.toLowerCase();
      final content = note.content.toLowerCase();

      return searchTerms.every(
        (term) => title.contains(term) || content.contains(term),
      );
    }).toList();
  }

  // Search within specific folder
  List<NoteModel> searchInFolder(String folderId, String query) {
    List<NoteModel> folderNotes = _notes
        .where((note) => note.folderId == folderId)
        .toList();

    if (query.isEmpty) return folderNotes;

    final searchTerms = query.toLowerCase().split(' ');

    return folderNotes.where((note) {
      final title = note.title.toLowerCase();
      final content = note.content.toLowerCase();

      return searchTerms.every(
        (term) => title.contains(term) || content.contains(term),
      );
    }).toList();
  }
}
