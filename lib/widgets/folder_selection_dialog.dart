import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/providers/folder_provider.dart';

class FolderSelectionDialog extends StatelessWidget {
  final String currentFolderId;
  final String noteId;
  final ValueChanged<String> onFolderSelected;

  const FolderSelectionDialog({
    super.key,
    required this.currentFolderId,
    required this.noteId,
    required this.onFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
    final folderProvider = Provider.of<FolderProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_open, color: Colors.blue),
                SizedBox(width: 16),
                Text(
                  'Move to Folder',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Select a folder to move this note:',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 300,
              width: 300,
              child: ListView.builder(
                itemCount: folderProvider.folders.length,
                itemBuilder: (context, index) {
                  final folder = folderProvider.folders[index];
                  final isCurrentFolder = currentFolderId == folder.id;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    color: isCurrentFolder
                        ? Colors.blue.withValues(alpha: 0.1)
                        : null,
                    child: ListTile(
                      leading: Icon(Icons.folder, color: folder.color),
                      title: Text(folder.name),
                      subtitle: Text('${folder.noteCount} notes'),
                      trailing: isCurrentFolder
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, color: Colors.blue, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Current',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            )
                          : null,
                      onTap: () {
                        if (!isCurrentFolder) {
                          onFolderSelected(folder.id);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
