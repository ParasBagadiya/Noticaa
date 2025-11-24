import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/models/note_model.dart';
import 'package:noticaa/providers/note_provider.dart';
import 'package:noticaa/providers/theme_provider.dart';

class RichTextEditorScreen extends StatefulWidget {
  final NoteModel note;

  const RichTextEditorScreen({super.key, required this.note});

  @override
  // ignore: library_private_types_in_public_api
  _RichTextEditorScreenState createState() => _RichTextEditorScreenState();
}

class _RichTextEditorScreenState extends State<RichTextEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  // Text formatting states
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  TextAlign _textAlign = TextAlign.left;
  bool _isBulletList = false;

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
      formatType: 'rich', // Mark as rich text
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

  void _toggleUnderline() {
    setState(() {
      _isUnderline = !_isUnderline;
    });
  }

  void _toggleBulletList() {
    setState(() {
      _isBulletList = !_isBulletList;
      if (_isBulletList) {
        // Add bullet to current line
        final text = _contentController.text;
        final selection = _contentController.selection;
        final lines = text.split('\n');
        final currentLine = _getCurrentLine(text, selection.baseOffset);

        if (currentLine >= 0 && currentLine < lines.length) {
          if (!lines[currentLine].startsWith('• ')) {
            lines[currentLine] = '• ${lines[currentLine]}';
            _contentController.text = lines.join('\n');
            _contentController.selection = TextSelection.collapsed(
              offset: selection.baseOffset + 2,
            );
          }
        }
      }
    });
  }

  int _getCurrentLine(String text, int position) {
    if (position < 0 || position > text.length) return 0;
    return text.substring(0, position).split('\n').length - 1;
  }

  void _setTextAlign(TextAlign align) {
    setState(() {
      _textAlign = align;
    });
  }

  void _insertText(String text) {
    final currentText = _contentController.text;
    final selection = _contentController.selection;

    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      text,
    );

    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: selection.start + text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Rich Text Editor'),
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
              } else if (value == 'clear_format') {
                setState(() {
                  _isBold = false;
                  _isItalic = false;
                  _isUnderline = false;
                  _textAlign = TextAlign.left;
                  _isBulletList = false;
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear_format',
                child: Row(
                  children: [
                    Icon(Icons.format_clear, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Clear Formatting'),
                  ],
                ),
              ),
              PopupMenuDivider(),
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
            height: 60,
            color: themeProvider.isDarkMode
                ? Colors.grey[800]
                : Colors.grey[100],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Text Style Buttons
                  _buildFormatButton(
                    icon: Icons.format_bold,
                    isActive: _isBold,
                    onPressed: _toggleBold,
                    tooltip: 'Bold',
                  ),
                  _buildFormatButton(
                    icon: Icons.format_italic,
                    isActive: _isItalic,
                    onPressed: _toggleItalic,
                    tooltip: 'Italic',
                  ),
                  _buildFormatButton(
                    icon: Icons.format_underline,
                    isActive: _isUnderline,
                    onPressed: _toggleUnderline,
                    tooltip: 'Underline',
                  ),

                  SizedBox(width: 8),
                  VerticalDivider(),
                  SizedBox(width: 8),

                  // Alignment Buttons
                  _buildFormatButton(
                    icon: Icons.format_align_left,
                    isActive: _textAlign == TextAlign.left,
                    onPressed: () => _setTextAlign(TextAlign.left),
                    tooltip: 'Align Left',
                  ),
                  _buildFormatButton(
                    icon: Icons.format_align_center,
                    isActive: _textAlign == TextAlign.center,
                    onPressed: () => _setTextAlign(TextAlign.center),
                    tooltip: 'Align Center',
                  ),
                  _buildFormatButton(
                    icon: Icons.format_align_right,
                    isActive: _textAlign == TextAlign.right,
                    onPressed: () => _setTextAlign(TextAlign.right),
                    tooltip: 'Align Right',
                  ),

                  SizedBox(width: 8),
                  VerticalDivider(),
                  SizedBox(width: 8),

                  // List Buttons
                  _buildFormatButton(
                    icon: Icons.format_list_bulleted,
                    isActive: _isBulletList,
                    onPressed: _toggleBulletList,
                    tooltip: 'Bullet List',
                  ),

                  SizedBox(width: 8),
                  VerticalDivider(),
                  SizedBox(width: 8),

                  // Quick Insert Buttons
                  _buildTextInsertButton(
                    text: '## ',
                    label: 'H2',
                    tooltip: 'Insert Heading',
                  ),
                  _buildTextInsertButton(
                    text: '**',
                    label: 'B',
                    tooltip: 'Insert Bold Text',
                  ),
                  _buildTextInsertButton(
                    text: '_',
                    label: 'I',
                    tooltip: 'Insert Italic Text',
                  ),
                ],
              ),
            ),
          ),

          // Editor Area
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Title Field
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Note Title',
                      hintStyle: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.grey,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Content Field with Rich Text Preview
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Start writing with rich text...',
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
                        fontSize: 16,
                        fontWeight: _isBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontStyle: _isItalic
                            ? FontStyle.italic
                            : FontStyle.normal,
                        decoration: _isUnderline
                            ? TextDecoration.underline
                            : TextDecoration.none,
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

  Widget _buildFormatButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: Icon(icon),
      color: isActive ? Colors.blue : Colors.grey,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  Widget _buildTextInsertButton({
    required String text,
    required String label,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () => _insertText(text),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size(0, 0),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
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
