import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/po_widgets.dart';

class BrowseMachinesPage extends StatefulWidget {
  const BrowseMachinesPage({super.key});

  @override
  State<BrowseMachinesPage> createState() => _BrowseMachinesPageState();
}

class _BrowseMachinesPageState extends State<BrowseMachinesPage> {
  static final _allMachineNames = _allMachines.map((m) => m['name']!).toSet();

  static const _allMachines = [
    {'name': 'Smith Machine', 'tag': 'MULTI'},
    {'name': 'Cable Machine', 'tag': 'MULTI'},
    {'name': 'Squat Rack', 'tag': 'MULTI'},
    {'name': 'Chest Press', 'tag': 'CHEST'},
    {'name': 'Incline Chest Press', 'tag': 'CHEST'},
    {'name': 'Chest Dip', 'tag': 'CHEST'},
    {'name': 'Pec Fly', 'tag': 'CHEST'},
    {'name': 'Pull-up Bar', 'tag': 'LATS'},
    {'name': 'Lat Pulldown', 'tag': 'LATS'},
    {'name': 'Leg Extension', 'tag': 'QUADRICEPS'},
    {'name': 'Leg Press', 'tag': 'QUADRICEPS'},
    {'name': 'Leg Curl', 'tag': 'HAMSTRINGS'},
    {'name': 'Hip Adduction', 'tag': 'ADDUCTORS'},
    {'name': 'Hip Thrust', 'tag': 'GLUTES'},
    {'name': 'Seated Cable Row', 'tag': 'UPPER BACK'},
    {'name': 'Shoulder Press', 'tag': 'SHOULDERS'},
    {'name': 'Bicep Curl Machine', 'tag': 'BICEPS'},
    {'name': 'Tricep Pushdown', 'tag': 'TRICEPS'},
    {'name': 'Calf Raise Machine', 'tag': 'CALVES'},
    {'name': 'Leg Raise', 'tag': 'ABDOMINALS'},
  ];

  final Set<String> _selectedMachines = {};
  final Set<String> _selectedMuscleGroups = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const _muscleGroups = [
    {
      'name': 'Abdominals',
      'tag': 'ABDOMINALS',
      'icon': Icons.accessibility_new,
    },
    {'name': 'Abductors', 'tag': 'ABDUCTORS', 'icon': Icons.accessibility_new},
    {'name': 'Adductors', 'tag': 'ADDUCTORS', 'icon': Icons.accessibility_new},
    {'name': 'Biceps', 'tag': 'BICEPS', 'icon': Icons.accessibility_new},
    {'name': 'Glutes', 'tag': 'GLUTES', 'icon': Icons.accessibility_new},
    {'name': 'Calves', 'tag': 'CALVES', 'icon': Icons.accessibility_new},
    {'name': 'Cardio', 'tag': 'CARDIO', 'icon': Icons.directions_run},
    {'name': 'Chest', 'tag': 'CHEST', 'icon': Icons.accessibility_new},
    {'name': 'Forearms', 'tag': 'FOREARMS', 'icon': Icons.accessibility_new},
    {'name': 'Hamstring', 'tag': 'HAMSTRING', 'icon': Icons.accessibility_new},
    {'name': 'Lats', 'tag': 'LATS', 'icon': Icons.accessibility_new},
    {
      'name': 'Lower Back',
      'tag': 'LOWER BACK',
      'icon': Icons.accessibility_new,
    },
    {'name': 'Neck', 'tag': 'NECK', 'icon': Icons.accessibility_new},
    {'name': 'Shoulders', 'tag': 'SHOULDERS', 'icon': Icons.accessibility_new},
    {'name': 'Traps', 'tag': 'TRAPS', 'icon': Icons.accessibility_new},
    {'name': 'Triceps', 'tag': 'TRICEPS', 'icon': Icons.accessibility_new},
    {
      'name': 'Upper Back',
      'tag': 'UPPER BACK',
      'icon': Icons.accessibility_new,
    },
    {
      'name': 'Quadriceps',
      'tag': 'QUADRICEPS',
      'icon': Icons.accessibility_new,
    },
  ];

  // Map machine tags to muscle groups
  static const _tagToMuscleGroup = {
    'MULTI': ['MULTI'],
    'CHEST': ['CHEST'],
    'LATS': ['LATS'],
    'QUADRICEPS': ['QUADRICEPS'],
    'HAMSTRINGS': ['HAMSTRING'],
    'ABDUCTORS': ['ABDUCTORS'],
    'ADDUCTORS': ['ADDUCTORS'],
    'GLUTES': ['GLUTES'],
    'UPPER BACK': ['UPPER BACK'],
    'LOWER BACK': ['LOWER BACK'],
    'NECK': ['NECK'],
    'SHOULDERS': ['SHOULDERS'],
    'TRAPS': ['TRAPS'],
    'BICEPS': ['BICEPS'],
    'FOREARMS': ['FOREARMS'],
    'TRICEPS': ['TRICEPS'],
    'CALVES': ['CALVES'],
    'ABDOMINALS': ['ABDOMINALS'],
    'CARDIO': ['CARDIO'],
  };

  @override
  void initState() {
    super.initState();
    // Load initial selections from equipment page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialSelections =
          GoRouterState.of(context).extra as List<String>?;
      if (initialSelections != null && mounted) {
        setState(() {
          // Only add machines that exist in our list
          _selectedMachines.addAll(
            initialSelections.where((name) => _allMachineNames.contains(name)),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredMachines {
    var machines = _allMachines;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      machines = machines
          .where(
            (m) =>
                m['name']!.toLowerCase().contains(query) ||
                m['tag']!.toLowerCase().contains(query),
          )
          .toList();
    }

    // Filter by muscle groups
    if (_selectedMuscleGroups.isNotEmpty) {
      machines = machines.where((m) {
        final machineTag = m['tag']!;
        // Multi-purpose machines should appear in every muscle filter.
        if (machineTag == 'MULTI') {
          return true;
        }
        final machineGroups = _tagToMuscleGroup[machineTag] ?? [];
        return machineGroups.any(
          (group) => _selectedMuscleGroups.contains(group),
        );
      }).toList();
    }

    return machines;
  }

  void _toggleMachine(String name) {
    setState(() {
      if (_selectedMachines.contains(name)) {
        _selectedMachines.remove(name);
      } else {
        _selectedMachines.add(name);
      }
    });
  }

  void _onDone() {
    context.pop(_selectedMachines.toList());
  }

  Future<void> _showMuscleGroupFilter() async {
    FocusManager.instance.primaryFocus?.unfocus();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MuscleGroupFilterSheet(
        selectedGroups: Set.from(_selectedMuscleGroups),
        muscleGroups: _muscleGroups,
        onApply: (selectedGroups) {
          setState(() {
            _selectedMuscleGroups.clear();
            _selectedMuscleGroups.addAll(selectedGroups);
          });
        },
      ),
    );

    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMachines = _filteredMachines;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Column(
            children: [
              Text(
                'Progressive Overload',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
              ),
              Text(
                'Choose Machines',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 10, right: 8),
                              child: Icon(Icons.search),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 42,
                              minHeight: 42,
                            ),
                            hintText: 'Search machines...',
                            hintStyle: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _showMuscleGroupFilter,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _selectedMuscleGroups.isEmpty
                              ? AppColors.surfaceContainer
                              : AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedMuscleGroups.isEmpty
                                ? AppColors.outline.withValues(alpha: 0.5)
                                : AppColors.primary,
                          ),
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: _selectedMuscleGroups.isEmpty
                              ? null
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredMachines.isEmpty
                      ? Center(
                          child: Text(
                            'No machines found',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: filteredMachines.length,
                          itemBuilder: (context, index) {
                            final machine = filteredMachines[index];
                            final name = machine['name']!;
                            final tag = machine['tag']!;
                            final isSelected = _selectedMachines.contains(name);

                            return _MachineCard(
                              name: name,
                              tag: tag,
                              selected: isSelected,
                              onTap: () => _toggleMachine(name),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Expanded(
                    //   child: OutlinedButton.icon(
                    //     style: OutlinedButton.styleFrom(
                    //       foregroundColor: AppColors.primary,
                    //       side: BorderSide(
                    //         color: AppColors.outline.withValues(alpha: 0.6),
                    //       ),
                    //       minimumSize: const Size.fromHeight(50),
                    //     ),
                    //     onPressed: () {
                    //       ScaffoldMessenger.of(context).showSnackBar(
                    //         const SnackBar(
                    //           content: Text('Custom machine input coming soon.'),
                    //         ),
                    //       );
                    //     },
                    //     icon: const Icon(Icons.add),
                    //     label: const Text('Custom'),
                    //   ),
                    // ),
                    // const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: NeonPrimaryButton(
                        label: _selectedMachines.isEmpty
                            ? 'Done'
                            : 'Done  ${_selectedMachines.length}',
                        expanded: false,
                        onPressed: _onDone,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MuscleGroupFilterSheet extends StatefulWidget {
  const _MuscleGroupFilterSheet({
    required this.selectedGroups,
    required this.muscleGroups,
    required this.onApply,
  });

  final Set<String> selectedGroups;
  final List<Map<String, dynamic>> muscleGroups;
  final Function(Set<String>) onApply;

  @override
  State<_MuscleGroupFilterSheet> createState() =>
      _MuscleGroupFilterSheetState();
}

class _MuscleGroupFilterSheetState extends State<_MuscleGroupFilterSheet> {
  late Set<String> _tempSelectedGroups;

  @override
  void initState() {
    super.initState();
    _tempSelectedGroups = Set.from(widget.selectedGroups);
  }

  void _toggleGroup(String tag) {
    setState(() {
      if (_tempSelectedGroups.contains(tag)) {
        _tempSelectedGroups.remove(tag);
      } else {
        _tempSelectedGroups.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempSelectedGroups.clear();
                        });
                      },
                      child: Text(
                        'Clear',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                    Text(
                      'Muscle Group',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onApply(_tempSelectedGroups);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Apply',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.muscleGroups.length,
                  itemBuilder: (context, index) {
                    final group = widget.muscleGroups[index];
                    final name = group['name'] as String;
                    final tag = group['tag'] as String;
                    final icon = group['icon'] as IconData;
                    final isSelected = _tempSelectedGroups.contains(tag);

                    return InkWell(
                      onTap: () => _toggleGroup(tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  const _MachineCard({
    required this.name,
    required this.tag,
    this.selected = false,
    required this.onTap,
  });

  final String name;
  final String tag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outline.withValues(alpha: 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 113,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0F10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.fitness_center,
                        size: 42,
                        color: Colors.white38,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(
                        selected ? Icons.check_circle : Icons.circle_outlined,
                        color: selected ? AppColors.primary : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    color: selected ? const Color(0xFF121415) : AppColors.text,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: selected ? Colors.black12 : AppColors.surfaceHighest,
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: selected
                          ? const Color(0xFF121415)
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
