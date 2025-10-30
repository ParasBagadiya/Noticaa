import 'package:flutter/material.dart';
import 'package:noticaa/models/folder_model.dart';
import 'package:noticaa/services/storage_service.dart';

class FolderProvider with ChangeNotifier {
  List<Folder> _folders = [];
  final StorageService _storageService = StorageService();

  List<Folder> get folders => _folders;
  List<Folder> get rootFolders =>
      _folders.where((folder) => folder.parentId == null).toList();

  FolderProvider() {
    loadFolders();
  }

  Future<void> loadFolders() async {
    final loadedFolders = await _storageService.loadFolders();
    if (loadedFolders.isEmpty) {
      _loadDefaultFolders();
    } else {
      _folders = loadedFolders;
      notifyListeners();
    }
  }

  void _loadDefaultFolders() {
    _folders = [
      Folder(
        id: 'inbox',
        name: 'Inbox',
        color: Colors.blue,
        createdAt: DateTime.now(),
        noteCount: 0,
      ),
      Folder(
        id: 'personal',
        name: 'Personal',
        color: Colors.green,
        createdAt: DateTime.now(),
        noteCount: 0,
      ),
      Folder(
        id: 'work',
        name: 'Work',
        color: Colors.orange,
        createdAt: DateTime.now(),
        noteCount: 0,
      ),
      Folder(
        id: 'ideas',
        name: 'Ideas',
        color: Colors.purple,
        createdAt: DateTime.now(),
        noteCount: 0,
      ),
    ];
    _saveFolders();
    notifyListeners();
  }

  Future<void> _saveFolders() async {
    await _storageService.saveFolders(_folders);
  }

  Folder getFolderById(String id) {
    try {
      return _folders.firstWhere((folder) => folder.id == id);
    } catch (e) {
      // Fallback to inbox folder if the requested folder doesn't exist
      return _folders.firstWhere((folder) => folder.id == 'inbox');
    }
  }

  void addFolder(Folder folder) {
    _folders.add(folder);
    _saveFolders();
    notifyListeners();
  }

  void updateFolder(String id, Folder updatedFolder) {
    final index = _folders.indexWhere((folder) => folder.id == id);
    if (index != -1) {
      _folders[index] = updatedFolder;
      _saveFolders();
      notifyListeners();
    }
  }

  void deleteFolder(String id) {
    _folders.removeWhere((folder) => folder.id == id);
    _saveFolders();
    notifyListeners();
  }

  // Sync note counts with actual notes
  void syncNoteCounts(Map<String, int> folderNoteCounts) {
    for (final folder in _folders) {
      final count = folderNoteCounts[folder.id] ?? 0;
      final index = _folders.indexWhere((f) => f.id == folder.id);
      if (index != -1) {
        _folders[index] = _folders[index].copyWith(noteCount: count);
      }
    }
    _saveFolders();
    notifyListeners();
  }

  // Update note count for a specific folder
  void updateNoteCount(String folderId, int count) {
    final index = _folders.indexWhere((folder) => folder.id == folderId);
    if (index != -1) {
      _folders[index] = _folders[index].copyWith(noteCount: count);
      _saveFolders();
      notifyListeners();
    }
  }
}
