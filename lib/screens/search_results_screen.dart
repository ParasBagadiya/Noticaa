import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/providers/note_provider.dart';
import 'package:noticaa/providers/category_provider.dart';
import 'package:noticaa/widgets/note_card.dart';

class SearchResultsScreen extends StatelessWidget {
  final String searchQuery;

  const SearchResultsScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final searchResults = noteProvider.searchNotes(searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Summary
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search: "$searchQuery"',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Chip(
                  label: Text('${searchResults.length} found'),
                  backgroundColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // Search Results
          Expanded(
            child: searchResults.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final note = searchResults[index];
                      final category = categoryProvider.getCategoryById(
                        note.categoryId,
                      );
                      return NoteCard(note: note, category: category);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No notes found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text('Try different keywords', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
