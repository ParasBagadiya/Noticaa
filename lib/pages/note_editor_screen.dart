import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/models/note_model.dart';
import 'package:noticaa/providers/note_provider.dart';
import 'package:noticaa/providers/theme_provider.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel note;

  const NoteEditorScreen({super.key, required this.note});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isBold = false;
  bool _isItalic = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      return;
    }

    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled'
          : _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );

    await Provider.of<NoteProvider>(
      context,
      listen: false,
    ).updateNote(widget.note.id, updatedNote);
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveNote();
              Navigator.pop(context);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteNote(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Note'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Formatting Toolbar
          Container(
            height: 50,
            color: themeProvider.isDarkMode
                ? Colors.grey[800]
                : Colors.grey[100],
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.format_bold,
                    color: _isBold ? Colors.blue : Colors.grey,
                  ),
                  onPressed: _toggleBold,
                ),
                IconButton(
                  icon: Icon(
                    Icons.format_italic,
                    color: _isItalic ? Colors.blue : Colors.grey,
                  ),
                  onPressed: _toggleItalic,
                ),
                IconButton(
                  icon: Icon(Icons.format_list_bulleted),
                  onPressed: () {
                    // Add list functionality
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Title',
                      hintStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.grey,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Start writing...',
                        hintStyle: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white60
                              : Colors.grey,
                        ),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: TextStyle(
                        fontWeight: _isBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontStyle: _isItalic
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _saveNote();
          Navigator.pop(context);
        },
        child: Icon(Icons.save),
      ),
    );
  }

  void _deleteNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<NoteProvider>(
                context,
                listen: false,
              ).deleteNote(widget.note.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close editor
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
