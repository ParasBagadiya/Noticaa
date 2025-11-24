// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/models/note_model.dart';
import 'package:noticaa/providers/note_provider.dart';
import 'package:noticaa/providers/category_provider.dart';
import 'package:noticaa/providers/folder_provider.dart';
import 'package:noticaa/widgets/note_card.dart' as note_card;

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _sortBy = 'lastModified';
  String _filterCategory = 'all';
  String _filterFolder = 'all';

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final folderProvider = Provider.of<FolderProvider>(context);

    List<NoteModel> favoriteNotes = noteProvider.favoriteNotes;

    // Apply filters
    if (_filterCategory != 'all') {
      favoriteNotes = favoriteNotes
          .where((note) => note.categoryId == _filterCategory)
          .toList();
    }

    if (_filterFolder != 'all') {
      favoriteNotes = favoriteNotes
          .where((note) => note.folderId == _filterFolder)
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'createdDate':
        favoriteNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'alphabetical':
        favoriteNotes.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'lastModified':
      default:
        favoriteNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Notes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value.startsWith('sort_')) {
                  _sortBy = value.replaceFirst('sort_', '');
                } else if (value.startsWith('category_')) {
                  _filterCategory = value.replaceFirst('category_', '');
                } else if (value.startsWith('folder_')) {
                  _filterFolder = value.replaceFirst('folder_', '');
                }
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'header_sort',
                child: Text(
                  'Sort by',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuItem<String>(
                value: 'sort_lastModified',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'lastModified'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    SizedBox(width: 8),
                    Text('Last Modified'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'sort_createdDate',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'createdDate'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    SizedBox(width: 8),
                    Text('Created Date'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'sort_alphabetical',
                child: Row(
                  children: [
                    Icon(
                      _sortBy == 'alphabetical'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                    ),
                    SizedBox(width: 8),
                    Text('Alphabetical'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'header_category',
                child: Text(
                  'Filter by Category',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuItem<String>(
                value: 'category_all',
                child: Row(
                  children: [
                    Icon(
                      _filterCategory == 'all'
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    SizedBox(width: 8),
                    Text('All Categories'),
                  ],
                ),
              ),
              ...categoryProvider.categories.map(
                (category) => PopupMenuItem<String>(
                  value: 'category_${category.id}',
                  child: Row(
                    children: [
                      Icon(
                        _filterCategory == category.id
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                      ),
                      SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'header_folder',
                child: Text(
                  'Filter by Folder',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuItem<String>(
                value: 'folder_all',
                child: Row(
                  children: [
                    Icon(
                      _filterFolder == 'all'
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    SizedBox(width: 8),
                    Text('All Folders'),
                  ],
                ),
              ),
              ...folderProvider.rootFolders.map(
                (folder) => PopupMenuItem<String>(
                  value: 'folder_${folder.id}',
                  child: Row(
                    children: [
                      Icon(
                        _filterFolder == folder.id
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                      ),
                      SizedBox(width: 8),
                      Text(folder.name),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: favoriteNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorite notes yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap the favorite icon on any note to add it here',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Summary bar
                Container(
                  padding: EdgeInsets.all(12),
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${favoriteNotes.length} favorite note${favoriteNotes.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_filterCategory != 'all' || _filterFolder != 'all')
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filterCategory = 'all';
                              _filterFolder = 'all';
                            });
                          },
                          child: Text('Clear filters'),
                        ),
                    ],
                  ),
                ),
                // Notes list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: favoriteNotes.length,
                    itemBuilder: (context, index) {
                      final note = favoriteNotes[index];
                      final category = categoryProvider.getCategoryById(
                        note.categoryId,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: note_card.NoteCard(
                          note: note,
                          category: category,
                          onMoveToFolder: (noteId) {
                            // Handle move to folder if needed
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
