import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noticaa/providers/search_provider.dart';
import 'package:noticaa/services/animation_service.dart';

class SearchSuggestions extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;
  final VoidCallback onClearHistory;

  const SearchSuggestions({
    super.key,
    required this.onSuggestionTap,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<SearchProvider>(context);

    if (searchProvider.searchHistory.isEmpty) {
      return SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimationService.searchAnimation(size: 150),
              SizedBox(height: 20),
              Text(
                'Search your notes',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 70),
                child: Text(
                  'Type to find notes by title or content',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              TextButton(onPressed: onClearHistory, child: Text('Clear All')),
            ],
          ),
        ),
        Expanded(
          // Use Expanded for the list
          child: ListView.builder(
            itemCount: searchProvider.searchHistory.length,
            itemBuilder: (context, index) {
              final query = searchProvider.searchHistory[index];
              return ListTile(
                leading: Icon(Icons.history, color: Colors.grey),
                title: Text(query),
                onTap: () => onSuggestionTap(query),
                trailing: IconButton(
                  icon: Icon(Icons.close, size: 16),
                  onPressed: () {
                    Provider.of<SearchProvider>(
                      context,
                      listen: false,
                    ).removeFromHistory(query);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
