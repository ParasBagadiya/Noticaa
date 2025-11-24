// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/models/note_model.dart';
import 'package:noticaa/providers/note_provider.dart';
import 'package:noticaa/providers/category_provider.dart';
import 'package:noticaa/providers/folder_provider.dart';
import 'package:noticaa/widgets/note_card.dart' as note_card;

class PinnedNotesScreen extends StatefulWidget {
  const PinnedNotesScreen({super.key});

  @override
  State<PinnedNotesScreen> createState() => _PinnedNotesScreenState();
}

class _PinnedNotesScreenState extends State<PinnedNotesScreen> {
  String _sortBy = 'lastModified';
  String _filterCategory = 'all';
  String _filterFolder = 'all';

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final folderProvider = Provider.of<FolderProvider>(context);
    final theme = Theme.of(context);

    List<NoteModel> pinnedNotes = noteProvider.allPinnedNotes;

    // Apply filters
    if (_filterCategory != 'all') {
      pinnedNotes = pinnedNotes
          .where((note) => note.categoryId == _filterCategory)
          .toList();
    }

    if (_filterFolder != 'all') {
      pinnedNotes = pinnedNotes
          .where((note) => note.folderId == _filterFolder)
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'createdDate':
        pinnedNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'alphabetical':
        pinnedNotes.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'lastModified':
      default:
        pinnedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Pinned Notes',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:
                theme.appBarTheme.titleTextStyle?.color ??
                theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.onSurface,
        elevation: 0,
        iconTheme:
            theme.appBarTheme.iconTheme ??
            IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          // Filter & Sort Button
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: _showFilterDialog,
            tooltip: 'Filter & Sort',
          ),
        ],
      ),
      body: pinnedNotes.isEmpty
          ? _buildEmptyState(theme) // ✓ Pass theme to empty state
          : Column(
              children: [
                // Header with stats
                _buildHeader(
                  pinnedNotes.length,
                  theme,
                ), // ✓ Pass theme to header
                // Notes list
                Expanded(child: _buildNotesList(pinnedNotes, categoryProvider)),
              ],
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.push_pin_rounded,
              size: 50,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Pinned Notes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Pin important notes to keep them\nat the top of your lists',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_rounded),
            label: Text('Back to Notes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int noteCount, ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.push_pin_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$noteCount Pinned Note${noteCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Important notes at your fingertips',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(
    List<NoteModel> notes,
    CategoryProvider categoryProvider,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final category = categoryProvider.getCategoryById(note.categoryId);

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: note_card.NoteCard(
            note: note,
            category: category,
            onMoveToFolder: (noteId) {
              // Handle move to folder if needed
            },
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterSortDialog(
        sortBy: _sortBy,
        filterCategory: _filterCategory,
        filterFolder: _filterFolder,
        onApply: (sort, category, folder) {
          setState(() {
            _sortBy = sort;
            _filterCategory = category;
            _filterFolder = folder;
          });
        },
      ),
    );
  }
}

class FilterSortDialog extends StatefulWidget {
  final String sortBy;
  final String filterCategory;
  final String filterFolder;
  final Function(String, String, String) onApply;

  const FilterSortDialog({
    super.key,
    required this.sortBy,
    required this.filterCategory,
    required this.filterFolder,
    required this.onApply,
  });

  @override
  State<FilterSortDialog> createState() => _FilterSortDialogState();
}

class _FilterSortDialogState extends State<FilterSortDialog> {
  late String _selectedSort;
  late String _selectedCategory;
  late String _selectedFolder;

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.sortBy;
    _selectedCategory = widget.filterCategory;
    _selectedFolder = widget.filterFolder;
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final folderProvider = Provider.of<FolderProvider>(context);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.9, // ✓ Added max width constraint
          maxHeight:
              MediaQuery.of(context).size.height *
              0.8, // ✓ Added max height constraint
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.filter_list_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    // ✓ Added Expanded to prevent overflow
                    child: Text(
                      'Filter & Sort Pinned Notes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // ✓ Added overflow handling
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Content
              Expanded(
                // ✓ Added Expanded for scrollable content
                child: SingleChildScrollView(
                  // ✓ Wrapped in SingleChildScrollView
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sort Section
                      Text(
                        'Sort by:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8),
                      ..._buildSortOptions(theme),
                      SizedBox(height: 16),

                      // Category Filter
                      Text(
                        'Filter by Category:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8),
                      ..._buildCategoryOptions(categoryProvider, theme),
                      SizedBox(height: 16),

                      // Folder Filter
                      Text(
                        'Filter by Folder:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8),
                      ..._buildFolderOptions(folderProvider, theme),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSort = 'lastModified';
                          _selectedCategory = 'all';
                          _selectedFolder = 'all';
                        });
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          _selectedSort,
                          _selectedCategory,
                          _selectedFolder,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                      ),
                      child: Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSortOptions(ThemeData theme) {
    return [
      RadioListTile<String>(
        value: 'lastModified',
        groupValue: _selectedSort,
        onChanged: (value) {
          setState(() {
            _selectedSort = value!;
          });
        },
        title: Row(
          children: [
            Icon(Icons.update, size: 20, color: theme.colorScheme.primary),
            SizedBox(width: 8),
            Flexible(
              // ✓ Added Flexible to prevent text overflow
              child: Text(
                'Last Modified',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
      RadioListTile<String>(
        value: 'createdDate',
        groupValue: _selectedSort,
        onChanged: (value) {
          setState(() {
            _selectedSort = value!;
          });
        },
        title: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.deepPurple),
            SizedBox(width: 8),
            Flexible(
              // ✓ Added Flexible to prevent text overflow
              child: Text('Created Date', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
      RadioListTile<String>(
        value: 'alphabetical',
        groupValue: _selectedSort,
        onChanged: (value) {
          setState(() {
            _selectedSort = value!;
          });
        },
        title: Row(
          children: [
            Icon(Icons.sort_by_alpha, size: 20, color: Colors.deepPurple),
            SizedBox(width: 8),
            Flexible(
              // ✓ Added Flexible to prevent text overflow
              child: Text('Alphabetical', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    ];
  }

  List<Widget> _buildCategoryOptions(
    CategoryProvider categoryProvider,
    ThemeData theme,
  ) {
    return [
      _buildFilterOption(
        value: 'all',
        label: 'All Categories',
        groupValue: _selectedCategory,
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
        },
      ),
      ...categoryProvider.categories.map((category) {
        return _buildFilterOption(
          value: category.id,
          label: category.name,
          groupValue: _selectedCategory,
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        );
      }).toList(),
    ];
  }

  List<Widget> _buildFolderOptions(FolderProvider folderProvider, theme) {
    return [
      _buildFilterOption(
        value: 'all',
        label: 'All Folders',
        groupValue: _selectedFolder,
        onChanged: (value) {
          setState(() {
            _selectedFolder = value!;
          });
        },
      ),
      ...folderProvider.rootFolders.map((folder) {
        return _buildFilterOption(
          value: folder.id,
          label: folder.name,
          groupValue: _selectedFolder,
          onChanged: (value) {
            setState(() {
              _selectedFolder = value!;
            });
          },
        );
      }).toList(),
    ];
  }

  Widget _buildFilterOption({
    required String value,
    required String label,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    return RadioListTile<String>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Flexible(
        // ✓ Added Flexible to prevent text overflow
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
