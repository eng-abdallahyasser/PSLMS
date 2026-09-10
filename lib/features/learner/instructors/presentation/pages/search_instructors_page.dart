import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/learner/instructors/domain/entities/instructor_profile_entity.dart';
import 'package:lms/features/learner/instructors/presentation/cubit/instructor_cubit.dart';

class SearchInstructorsPage extends StatefulWidget {
  const SearchInstructorsPage({super.key});

  @override
  State<SearchInstructorsPage> createState() => _SearchInstructorsPageState();
}

class _SearchInstructorsPageState extends State<SearchInstructorsPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<InstructorProfileEntity>? _cachedResults;

  @override
  void initState() {
    super.initState();
    context.read<InstructorCubit>().searchInstructors(query: '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      context.read<InstructorCubit>().searchInstructors(query: value.trim());
    });
  }

  void _search() {
    final query = _searchController.text.trim();
    context.read<InstructorCubit>().searchInstructors(query: query);
  }

  Future<void> _onRefresh() async {
    final query = _searchController.text.trim();
    await context.read<InstructorCubit>().searchInstructors(query: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Instructors')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              label: 'Search',
              hint: 'Search by name...',
              controller: _searchController,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: _search),
              onChanged: _onQueryChanged,
              onFieldSubmitted: (_) => _search(),
            ),
          ),
          Expanded(
            child: BlocBuilder<InstructorCubit, InstructorState>(
              builder: (context, state) {
                return switch (state) {
                  InstructorsSearchLoaded(:final instructors) => _showResults(instructors),
                  InstructorInitial() => const Center(child: Text('Search for instructors above')),
                  InstructorsSearchLoading() => _cachedResults != null
                      ? _buildResults(_cachedResults!)
                      : const AppLoadingWidget(),
                  InstructorsSearchError(:final message) => _cachedResults != null
                      ? _buildResults(_cachedResults!)
                      : Center(child: Text(message)),
                  _ => _cachedResults != null
                      ? _buildResults(_cachedResults!)
                      : const Center(child: Text('Search for instructors above')),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _showResults(List results) {
    _cachedResults = results.cast<InstructorProfileEntity>();
    return _buildResults(_cachedResults!);
  }

  Widget _buildResults(List results) {
    if (results.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('No instructors found')),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final instructor = results[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(child: Text(instructor.fullName.isNotEmpty ? instructor.fullName[0].toUpperCase() : '?')),
              title: Text(instructor.fullName),
              subtitle: instructor.bio != null ? Text(instructor.bio!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/instructors/${instructor.id}'),
            ),
          );
        },
      ),
    );
  }
}
