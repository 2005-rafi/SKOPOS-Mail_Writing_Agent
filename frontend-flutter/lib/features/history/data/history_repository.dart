import '../../../core/storage/history_storage_service.dart';
import '../domain/history_item.dart';

/// Repository for reading and managing local history items.
class HistoryRepository {
  HistoryRepository(this._storageService);

  final HistoryStorageService _storageService;

  Future<List<HistoryItem>> getHistory() async {
    final rawList = await _storageService.getHistory();
    return rawList.map((m) => HistoryItem.fromJson(m)).toList();
  }

  Future<void> deleteHistoryItem(String id) async {
    await _storageService.deleteHistoryItem(id);
  }

  Future<void> clearHistory() async {
    await _storageService.clearHistory();
  }
}

