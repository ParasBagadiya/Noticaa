import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/models/note_model.dart';
import 'package:noticaa/models/folder_model.dart';
import 'package:noticaa/providers/note_provider.dart';
import 'package:noticaa/providers/category_provider.dart';
import 'package:noticaa/providers/theme_provider.dart';
import 'package:noticaa/providers/search_provider.dart';
import 'package:noticaa/providers/folder_provider.dart';

// Import widgets with aliases to avoid conflicts
import 'package:noticaa/widgets/note_card.dart' as note_card;
import 'package:noticaa/widgets/folder_card.dart' as folder_card;
import 'package:noticaa/widgets/search_bar.dart' as custom;
import 'package:noticaa/widgets/category_chip.dart';
import 'package:noticaa/widgets/search_suggestions.dart';
import 'package:noticaa/widgets/folder_selection_dialog.dart';

import 'package:noticaa/pages/note_editor_screen.dart';
import 'package:noticaa/pages/rich_text_editor_screen.dart';
import 'package:noticaa/screens/search_results_screen.dart';
import 'package:noticaa/services/animation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showFolders = false; // Toggle between folders and notes

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    if (query.isNotEmpty) {
      Provider.of<SearchProvider>(context, listen: false).addToHistory(query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  void _navigateToSearchResults(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(searchQuery: query),
        ),
      );
    }
  }

  void _useSuggestion(String query) {
    _searchController.text = query;
    _navigateToSearchResults(query);
  }

  void _showMoveToFolderDialog(String noteId, String currentFolderId) {
    showDialog(
      context: context,
      builder: (context) => FolderSelectionDialog(
        currentFolderId: currentFolderId,
        noteId: noteId,
        onFolderSelected: (newFolderId) {
          Provider.of<NoteProvider>(
            context,
            listen: false,
          ).moveNoteToFolder(noteId, newFolderId, context);
        },
      ),
    );
  }

  void _createNewFolder(BuildContext context) {
    final TextEditingController folderNameController = TextEditingController();
    Color selectedColor = Colors.blue;

    final List<Color> colorOptions = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.create_new_folder_rounded, color: Colors.blue),
                SizedBox(width: 8),
                Text('Create New Folder'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: folderNameController,
                  decoration: InputDecoration(
                    labelText: 'Folder Name',
                    hintText: 'Enter folder name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.folder_rounded),
                  ),
                  autofocus: true,
                ),
                SizedBox(height: 20),
                Text(
                  'Choose Folder Color:',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: selectedColor == color
                            ? Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final folderName = folderNameController.text.trim();
                  if (folderName.isNotEmpty) {
                    _createFolder(context, folderName, selectedColor);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Create Folder'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _createFolder(BuildContext context, String name, Color color) {
    final folderProvider = Provider.of<FolderProvider>(context, listen: false);

    final newFolder = Folder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
      noteCount: 0,
    );

    folderProvider.addFolder(newFolder);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Folder "$name" created successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFolderOptions(BuildContext context, Folder folder) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit_rounded, color: Colors.blue),
              title: Text('Rename Folder'),
              onTap: () {
                Navigator.pop(context);
                _renameFolder(context, folder);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: Colors.red),
              title: Text('Delete Folder'),
              onTap: () {
                Navigator.pop(context);
                _deleteFolder(context, folder);
              },
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${folder.noteCount} notes in this folder',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _renameFolder(BuildContext context, Folder folder) {
    final controller = TextEditingController(text: folder.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Folder'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Folder Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != folder.name) {
                _updateFolderName(context, folder, newName);
                Navigator.pop(context);
              }
            },
            child: Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _updateFolderName(BuildContext context, Folder folder, String newName) {
    final folderProvider = Provider.of<FolderProvider>(context, listen: false);

    final updatedFolder = folder.copyWith(name: newName);
    folderProvider.updateFolder(folder.id, updatedFolder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Folder renamed to "$newName"'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteFolder(BuildContext context, Folder folder) {
    final folderProvider = Provider.of<FolderProvider>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    // Check if folder has notes
    final folderNotes = noteProvider.getNotesByFolder(folder.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Folder'),
        content: Text(
          folderNotes.isNotEmpty
              ? 'Folder "${folder.name}" contains ${folderNotes.length} notes. What would you like to do with these notes?'
              : 'Are you sure you want to delete folder "${folder.name}"?',
        ),
        actions: [
          if (folderNotes.isNotEmpty) ...[
            TextButton(
              onPressed: () {
                // Move notes to inbox and delete folder
                _moveNotesAndDeleteFolder(context, folder, folderNotes);
                Navigator.pop(context);
              },
              child: Text('Move to Inbox & Delete'),
            ),
            TextButton(
              onPressed: () {
                // Delete folder with all notes
                _deleteFolderWithNotes(context, folder, folderNotes);
                Navigator.pop(context);
              },
              child: Text('Delete All', style: TextStyle(color: Colors.red)),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                folderProvider.deleteFolder(folder.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Folder "${folder.name}" deleted'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }

  void _moveNotesAndDeleteFolder(
    BuildContext context,
    Folder folder,
    List<NoteModel> notes,
  ) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final folderProvider = Provider.of<FolderProvider>(context, listen: false);

    // Move all notes to inbox
    for (final note in notes) {
      noteProvider.moveNoteToFolder(note.id, 'inbox', context);
    }

    // Delete folder
    folderProvider.deleteFolder(folder.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Moved ${notes.length} notes to Inbox and deleted folder',
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _deleteFolderWithNotes(
    BuildContext context,
    Folder folder,
    List<NoteModel> notes,
  ) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final folderProvider = Provider.of<FolderProvider>(context, listen: false);

    // Delete all notes in folder
    for (final note in notes) {
      noteProvider.deleteNote(note.id);
    }

    // Delete folder
    folderProvider.deleteFolder(folder.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted folder and ${notes.length} notes'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context);
    final folderProvider = Provider.of<FolderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? custom.CustomSearchBar(
                controller: _searchController,
                onClear: _clearSearch,
                onChanged: _handleSearch,
              )
            : Text(_showFolders ? 'Folders' : 'Notes'),
        actions: [
          // View Toggle Button
          IconButton(
            icon: Icon(
              _showFolders ? Icons.notes_rounded : Icons.folder_rounded,
            ),
            onPressed: () {
              setState(() {
                _showFolders = !_showFolders;
              });
            },
            tooltip: _showFolders ? 'Show Notes' : 'Show Folders',
          ),
          // Theme Toggle Button
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          if (_isSearching && _searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.arrow_forward_rounded),
              onPressed: () => _navigateToSearchResults(_searchController.text),
            ),
        ],
      ),
      body: _isSearching && _searchController.text.isEmpty
          ? SearchSuggestions(
              onSuggestionTap: _useSuggestion,
              onClearHistory: () {
                searchProvider.clearHistory();
              },
            )
          : _showFolders
          ? _buildFoldersView(folderProvider, noteProvider)
          : _buildNotesView(noteProvider, categoryProvider, folderProvider),
      floatingActionButton: _showFolders
          ? FloatingActionButton(
              onPressed: () => _createNewFolder(context),
              tooltip: 'Create New Folder',
              child: Icon(Icons.create_new_folder_rounded),
            )
          : FloatingActionButton(
              onPressed: () => _createNewNote(context),
              tooltip: 'Create New Note',
              child: Icon(Icons.add_rounded),
            ),
    );
  }

  Widget _buildFoldersView(
    FolderProvider folderProvider,
    NoteProvider noteProvider,
  ) {
    // Sync note counts when folders view is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final counts = noteProvider.getFolderNoteCounts();
      folderProvider.syncNoteCounts(counts);
    });

    if (folderProvider.rootFolders.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimationService.emptyFolderAnimation(size: 150),
          SizedBox(height: 20),
          Text(
            'No folders yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to create your first folder',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: folderProvider.rootFolders.length,
      itemBuilder: (context, index) {
        final folder = folderProvider.rootFolders[index];
        final isSelected = noteProvider.currentFolder == folder.id;

        return folder_card.FolderCard(
          folder: folder,
          isSelected: isSelected,
          onTap: () {
            noteProvider.setFolderFilter(folder.id);
            setState(() {
              _showFolders = false;
            });
          },
          onLongPress: () {
            _showFolderOptions(context, folder);
          },
        );
      },
    );
  }

  Widget _buildNotesView(
    NoteProvider noteProvider,
    CategoryProvider categoryProvider,
    FolderProvider folderProvider,
  ) {
    final currentFolder = folderProvider.getFolderById(
      noteProvider.currentFolder,
    );

    return Column(
      children: [
        // Current Folder Indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: currentFolder.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: currentFolder.color,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentFolder.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${currentFolder.noteCount} ${currentFolder.noteCount == 1 ? 'note' : 'notes'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (noteProvider.currentFolder != 'all')
                TextButton(
                  onPressed: () {
                    noteProvider.setFolderFilter('all');
                  },
                  child: Text('Show All'),
                ),
            ],
          ),
        ),

        // Category Chips
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.categories[index];
              return CategoryChip(
                category: category,
                isSelected: noteProvider.currentCategory == category.id,
                onTap: () {
                  noteProvider.setCategoryFilter(category.id);
                },
              );
            },
          ),
        ),
        Divider(height: 1),

        // Notes List
        Expanded(
          child: Consumer<NoteProvider>(
            builder: (context, noteProvider, child) {
              final notes = _isSearching && _searchController.text.isNotEmpty
                  ? noteProvider.searchNotes(_searchController.text)
                  : noteProvider.filteredNotes;

              if (notes.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimationService.emptyNotesAnimation(size: 200),
                    SizedBox(height: 20),
                    Text(
                      currentFolder.id == 'all'
                          ? 'No notes yet'
                          : 'No notes in this folder',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      currentFolder.id == 'all'
                          ? 'Tap + to create your first note'
                          : 'Create a new note or move existing notes here',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final category = categoryProvider.getCategoryById(
                    note.categoryId,
                  );
                  return note_card.NoteCard(
                    note: note,
                    category: category,
                    onMoveToFolder: (noteId) {
                      _showMoveToFolderDialog(noteId, note.folderId);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _createNewNote(BuildContext context) {
    // Show dialog to choose editor type
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Note'),
        content: Text('Choose editor type:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createPlainTextNote(context);
            },
            child: Text('Plain Text'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createRichTextNote(context);
            },
            child: Text('Rich Text'),
          ),
        ],
      ),
    );
  }

  void _createPlainTextNote(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    final newNote = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Note',
      content: 'Start writing...',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
      categoryId: noteProvider.currentCategory,
      folderId: noteProvider.currentFolder,
      formatType: 'plain',
    );
    noteProvider.addNote(newNote);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditorScreen(note: newNote)),
    );
  }

  void _createRichTextNote(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);

    final newNote = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Rich Text Note',
      content: 'Start writing with formatting...',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
      categoryId: noteProvider.currentCategory,
      folderId: noteProvider.currentFolder,
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
}
