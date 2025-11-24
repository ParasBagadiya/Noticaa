import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:noticaa/models/note_model.dart';
import 'package:noticaa/models/folder_model.dart';

class StorageService {
  static const String _notesKey = 'notes_data';
  static const String _foldersKey = 'folders_data';


  Future<List<NoteModel>> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notesString = prefs.getString(_notesKey);

      if (notesString == null || notesString.isEmpty) return [];

      final List<dynamic> notesList = json.decode(notesString);
      return notesList.map((item) => NoteModel.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error loading notes: $e');
      return [];
    }
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> notesMapList = notes
          .map((note) => note.toMap())
          .toList();
      await prefs.setString(_notesKey, json.encode(notesMapList));
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }

  Future<List<Folder>> loadFolders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? foldersString = prefs.getString(_foldersKey);

      if (foldersString == null || foldersString.isEmpty) return [];

      final List<dynamic> foldersList = json.decode(foldersString);
      return foldersList.map((item) => Folder.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error loading folders: $e');
      return [];
    }
  }

  Future<void> saveFolders(List<Folder> folders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> foldersMapList = folders
          .map((folder) => folder.toMap())
          .toList();
      await prefs.setString(_foldersKey, json.encode(foldersMapList));
    } catch (e) {
      debugPrint('Error saving folders: $e');
    }
  }
}
