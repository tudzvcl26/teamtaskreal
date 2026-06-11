import 'package:riverpod/riverpod.dart';

// Provider để lưu trữ trạng thái loading toàn cục
final globalLoadingProvider = StateProvider<bool>((ref) => false);

// Provider để hiển thị error message
final errorMessageProvider = StateProvider<String?>((ref) => null);

// Provider để hiển thị success message
final successMessageProvider = StateProvider<String?>((ref) => null);

// Provider để quản lý filter chips (task status, priority)
final selectedTaskStatusProvider = StateProvider<String?>((ref) => null);

final selectedTaskPriorityProvider = StateProvider<String?>((ref) => null);

// Provider để quản lý search query
final taskSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider để quản lý selected group
final selectedGroupIdProvider = StateProvider<String?>((ref) => null);

// Computed provider: combine filters
final taskFiltersProvider = Provider<({
  String? status,
  String? priority,
  String searchQuery
})>((ref) {
  final status = ref.watch(selectedTaskStatusProvider);
  final priority = ref.watch(selectedTaskPriorityProvider);
  final searchQuery = ref.watch(taskSearchQueryProvider);

  return (status: status, priority: priority, searchQuery: searchQuery);
});
