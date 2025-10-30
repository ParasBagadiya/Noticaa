import 'package:flutter/material.dart';
import 'package:noticaa/models/folder_model.dart';
import 'package:noticaa/screens/folder_contents_screen.dart';

class FolderCard extends StatelessWidget {
  final Folder folder;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FolderCard({
    super.key,
    required this.folder,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4),
      color: isSelected
          ? folder.color.withOpacity(0.2)
          : Theme.of(context).cardColor,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FolderContentsScreen(folderId: folder.id),
            ),
          );
        },
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.folder, color: folder.color, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      folder.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${folder.noteCount} ${folder.noteCount == 1 ? 'note' : 'notes'}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
