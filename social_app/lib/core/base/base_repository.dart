import 'base_model.dart';

/// Generic repository interface.
abstract class BaseRepository<T extends BaseModel> {
  String get tableName;
  T fromJson(Map<String, dynamic> json);

  Future<List<T>> fetchAll({
    String orderBy = 'created_at',
    bool ascending = false,
    int? limit,
  });

  Future<T?> fetchById(String id);
  Future<List<T>> fetchWhere(Map<String, dynamic> filters);
  Future<T> create(Map<String, dynamic> data);
  Future<T> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}
