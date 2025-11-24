// ignore_for_file: deprecated_member_use

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
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: note.isPinned
              ? Border.all(color: Colors.amber, width: 2)
              : null,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: _buildPinButton(context),
          title: Row(
            children: [
              if (note.isPinned)
                Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin, size: 12, color: Colors.amber),
                      SizedBox(width: 2),
                      Text(
                        'Pinned',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Text(
                  note.title.isEmpty ? 'Untitled' : note.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontStyle: note.title.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.content.isNotEmpty)
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13),
                ),
              SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _buildFolderIndicator(currentFolder),
                  if (note.formatType == 'rich') _buildRichTextIndicator(),
                  _buildCategoryIndicator(),
                  if (note.isFavorite) _buildFavoriteIndicator(),
                  _buildDateIndicator(),
                ],
              ),
            ],
          ),
          trailing: _buildMoreButton(context),
          onTap: () {
            _navigateToEditor(context);
          },
        ),
      ),
    );
  }

  Widget _buildPinButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<NoteProvider>(context, listen: false).togglePin(note.id);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: note.isPinned
              ? Colors.amber.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
          color: note.isPinned ? Colors.amber : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFolderIndicator(dynamic folder) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: folder.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: folder.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 12, color: folder.color),
          SizedBox(width: 2),
          Text(
            folder.name.length > 8
                ? '${folder.name.substring(0, 8)}...'
                : folder.name,
            style: TextStyle(
              fontSize: 10,
              color: folder.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichTextIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
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
    );
  }
  
  Widget _buildCategoryIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: category.color.withValues(alpha: 0.3)),
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
    );
  }

  Widget _buildFavoriteIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, size: 12, color: Colors.red),
          SizedBox(width: 2),
          Text(
            'Favorite',
            style: TextStyle(
              fontSize: 10,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(
        _formatDate(note.updatedAt),
        style: TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey, size: 20),
      onSelected: (value) => _handleMenuSelection(value, context),
      itemBuilder: (context) => [
        // PopupMenuItem(
        //   value: 'pin',
        //   child: Row(
        //     children: [
        //       Icon(
        //         note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
        //         color: Colors.amber,
        //       ),
        //       SizedBox(width: 8),
        //       Text(note.isPinned ? 'Unpin Note' : 'Pin Note'),
        //     ],
        //   ),
        // ),
        PopupMenuItem(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                note.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text(note.isFavorite ? 'Remove Favorite' : 'Add to Favorites'),
            ],
          ),
        ),
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
    );
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'pin':
        Provider.of<NoteProvider>(context, listen: false).togglePin(note.id);
        break;
      case 'favorite':
        Provider.of<NoteProvider>(
          context,
          listen: false,
        ).toggleFavorite(note.id);
        break;
      case 'move':
        if (onMoveToFolder != null) onMoveToFolder!(note.id);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  void _navigateToEditor(BuildContext context) {
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
        MaterialPageRoute(builder: (context) => NoteEditorScreen(note: note)),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
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
