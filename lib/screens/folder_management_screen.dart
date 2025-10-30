import 'package:flutter/material.dart';
import 'package:noticaa/models/note_model.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/models/folder_model.dart';
import 'package:noticaa/providers/folder_provider.dart';
import 'package:noticaa/providers/note_provider.dart';
import 'package:noticaa/widgets/folder_card.dart' as folder_card;

class FolderManagementScreen extends StatefulWidget {
  const FolderManagementScreen({super.key});

  @override
  _FolderManagementScreenState createState() => _FolderManagementScreenState();
}

class _FolderManagementScreenState extends State<FolderManagementScreen> {
  final TextEditingController _folderNameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  void _createNewFolder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Create New Folder'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _folderNameController,
                  decoration: InputDecoration(
                    labelText: 'Folder Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Choose Color:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _folderNameController.clear();
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final folderName = _folderNameController.text.trim();
                  if (folderName.isNotEmpty) {
                    _createFolder(context, folderName, _selectedColor);
                    _folderNameController.clear();
                    Navigator.pop(context);
                  }
                },
                child: Text('Create'),
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
        content: Text('Folder "$name" created successfully!'),
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
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('Rename Folder'),
              onTap: () {
                Navigator.pop(context);
                _renameFolder(context, folder);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Folder'),
              onTap: () {
                Navigator.pop(context);
                _deleteFolder(context, folder);
              },
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
    final folderProvider = Provider.of<FolderProvider>(context);
    final noteProvider = Provider.of<NoteProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Folders'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _createNewFolder(context),
            tooltip: 'Create New Folder',
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: folderProvider.folders.length,
        itemBuilder: (context, index) {
          final folder = folderProvider.folders[index];
          final isSystemFolder =
              folder.id == 'inbox'; // Prevent editing system folders

          return folder_card.FolderCard(
            folder: folder,
            isSelected: false,
            onTap: () {
              // Navigate to folder contents
              noteProvider.setFolderFilter(folder.id);
              Navigator.pop(context);
            },
            onLongPress: isSystemFolder
                ? () {}
                : () => _showFolderOptions(context, folder),
          );
        },
      ),
    );
  }
}
