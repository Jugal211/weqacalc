import 'package:flutter/material.dart';
// import 'package:weqacalc/widgets/settings.dart';
import 'package:weqacalc/utils/calculator_grid.dart';
import 'package:weqacalc/models/calculator_item.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:flutter/material.dart';
// import '../models/calculator_item.dart';
// import '../data/calculator_data.dart';

Future<void> incrementUsage(String calcName) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'usage_$calcName';
  final count = prefs.getInt(key) ?? 0;
  prefs.setInt(key, count + 1);
}

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> {
  late List<String> categories;
  late List<String> allTags;
  late TextEditingController _searchController;

  String selectedCategory = 'All';
  String selectedTag = 'All';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Build unique category and tag lists (sorted alphabetically)
    final categorySet = <String>{};
    final tagSet = <String>{};

    for (var calc in allCalculators) {
      categorySet.add(calc.category);
      tagSet.addAll(calc.tags);
    }

    categories = ['All', ...categorySet.toList()..sort()];
    allTags = ['All', ...tagSet.toList()..sort()];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Optimized filtering logic with early returns
  List<CalculatorItem> get filteredCalculators {
    if (selectedCategory == 'All' &&
        selectedTag == 'All' &&
        searchQuery.isEmpty) {
      return allCalculators;
    }

    return allCalculators.where((calc) {
      // Category filter
      if (selectedCategory != 'All' && calc.category != selectedCategory) {
        return false;
      }

      // Tag filter
      if (selectedTag != 'All' && !calc.tags.contains(selectedTag)) {
        return false;
      }

      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = calc.title.toLowerCase().contains(query);
        final matchesSubtitle = calc.subtitle.toLowerCase().contains(query);
        final matchesCategory = calc.category.toLowerCase().contains(query);

        return matchesTitle || matchesSubtitle || matchesCategory;
      }

      return true;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = 'All';
      selectedTag = 'All';
      searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = filteredCalculators;
    final hasActiveFilters =
        selectedCategory != 'All' ||
        selectedTag != 'All' ||
        searchQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calculators',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all filters',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar with better styling
          _buildSearchBar(),

          // Filter Section
          _buildFilterSection(),

          // Results count
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${filteredList.length} calculator${filteredList.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // Grid of Calculators
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.95,
                      end: 1.0,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: filteredList.isEmpty
                  ? _buildEmptyState()
                  : _buildCalculatorGrid(filteredList),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search calculators...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) async {
          setState(() => searchQuery = value);
          if (value.length > 2) {
            await FirebaseAnalytics.instance.logEvent(
              name: 'search',
              parameters: {'query': value},
            );
          }
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        _buildChipSection(
          title: "Categories",
          items: categories,
          selected: selectedCategory,
          onSelected: (value) => setState(() {
            selectedCategory = value;
            // Reset tag filter when category changes
            if (value != 'All') selectedTag = 'All';
          }),
        ),
        _buildChipSection(
          title: "Tags",
          items: allTags,
          selected: selectedTag,
          onSelected: (value) => setState(() => selectedTag = value),
        ),
      ],
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                title == "Categories" ? Icons.category : Icons.label,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selected;

                return FilterChip(
                  label: Text(item),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  selected: isSelected,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Colors.grey[100],
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[300]!,
                      width: isSelected ? 0 : 1,
                    ),
                  ),
                  elevation: isSelected ? 2 : 0,
                  pressElevation: 4,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  onSelected: (_) async {
                    onSelected(item);

                    await FirebaseAnalytics.instance.logEvent(
                      name: 'filter_applied',
                      parameters: {
                        'filter_type': title.toLowerCase(),
                        'filter_value': item,
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calculate_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No calculators found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorGrid(List<CalculatorItem> items) {
    return GridView.builder(
      key: ValueKey('$selectedCategory-$selectedTag-$searchQuery'),
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _CalculatorCard(
          item: items[index],
          delay: Duration(milliseconds: index * 50),
        );
      },
    );
  }
}

// Optimized Calculator Card with Hero animation
class _CalculatorCard extends StatefulWidget {
  final CalculatorItem item;
  final Duration delay;

  const _CalculatorCard({required this.item, this.delay = Duration.zero});

  @override
  State<_CalculatorCard> createState() => _CalculatorCardState();
}

class _CalculatorCardState extends State<_CalculatorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Entrance animation
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Hero(
        tag: 'calculator_${widget.item.title}',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              // Track which calculator was opened
              await FirebaseAnalytics.instance.logEvent(
                name: 'open_calculator',
                parameters: {
                  'calculator_name': widget.item.title,
                  'category': widget.item.category,
                  'tags': widget.item.tags.join(','),
                },
              );
              incrementUsage(widget.item.title);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => widget.item.route),
              );
            },
            onTapDown: (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            onTapCancel: () {
              setState(() => _isPressed = false);
              _controller.reverse();
            },
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.item.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.item.gradient.first.withOpacity(0.3),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: Offset(0, _isPressed ? 2 : 4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.item.icon,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.item.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
