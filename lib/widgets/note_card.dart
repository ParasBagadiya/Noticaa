import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/models/note_model.dart';
import 'package:noticaa/models/category_model.dart';
import 'package:noticaa/providers/note_provider.dart';
import 'package:noticaa/providers/folder_provider.dart';
import 'package:noticaa/pages/note_editor_screen.dart';
import 'package:noticaa/pages/rich_text_editor_screen.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final Category category;
  final Function(String)? onMoveToFolder;

  const NoteCard({
    super.key,
    required this.note,
    required this.category,
    this.onMoveToFolder,
  });

  @override
  Widget build(BuildContext context) {
    final folderProvider = Provider.of<FolderProvider>(context);
    final currentFolder = folderProvider.getFolderById(note.folderId);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: note.isPinned ? Colors.blue : Colors.grey,
          ),
          onPressed: () {
            Provider.of<NoteProvider>(
              context,
              listen: false,
            ).togglePin(note.id);
          },
        ),
        title: Text(
          note.title.isEmpty ? 'Untitled' : note.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: note.title.isEmpty ? FontStyle.italic : FontStyle.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.content.isNotEmpty)
              Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
            SizedBox(height: 4),
            // Use Wrap instead of Row to handle overflow gracefully
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                // Folder indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: currentFolder.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: currentFolder.color.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 12,
                        color: currentFolder.color,
                      ),
                      SizedBox(width: 2),
                      Text(
                        currentFolder.name.length > 8
                            ? '${currentFolder.name.substring(0, 8)}...'
                            : currentFolder.name,
                        style: TextStyle(
                          fontSize: 10,
                          color: currentFolder.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Format type indicator
                if (note.formatType == 'rich')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.text_format, size: 12, color: Colors.green),
                        SizedBox(width: 2),
                        Text(
                          'Rich',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Category indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: category.color.withOpacity(0.3)),
                  ),
                  child: Text(
                    category.name.length > 8
                        ? '${category.name.substring(0, 8)}...'
                        : category.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: category.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Date - always show
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    _formatDate(note.updatedAt),
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigate to appropriate editor based on format type
          if (note.formatType == 'rich') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RichTextEditorScreen(note: note),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteEditorScreen(note: note),
              ),
            );
          }
        },
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteDialog(context);
            } else if (value == 'move' && onMoveToFolder != null) {
              onMoveToFolder!(note.id);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'move',
              child: Row(
                children: [
                  Icon(Icons.folder, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Move to Folder'),
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
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteDialog(BuildContext context) {
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
              ).deleteNote(note.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
