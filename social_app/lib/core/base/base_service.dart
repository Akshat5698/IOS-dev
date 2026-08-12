import 'base_model.dart';
import 'base_repository.dart';

/// Abstract service that provides a domain-level API over a [BaseRepository].
///
/// Concrete services (AuthService, FeedService, …) extend this class and
/// gain standard CRUD for free via [repository].  They can layer on
/// domain-specific methods (e.g. `fetchFeed`, `sendMessage`) without
/// duplicating Supabase query logic.
///
/// ```
///            UI  →  Controller  →  Service  →  Repository  →  Supabase
/// ```
abstract class BaseService<T extends BaseModel> {
  /// The repository this service delegates persistence to.
  BaseRepository<T> get repository;

  // ── Standard CRUD (delegates to repository) ─────────────────────────────

  /// Fetch every record of type [T].
  Future<List<T>> fetchAll({
    String orderBy = 'created_at',
    bool ascending = false,
    int? limit,
  }) {
    return repository.fetchAll(
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
    );
  }

  /// Fetch a single record by [id], or `null` if not found.
  Future<T?> fetchById(String id) {
    return repository.fetchById(id);
  }

  /// Create a new record from [data] and return the created model.
  Future<T> create(Map<String, dynamic> data) {
    return repository.create(data);
  }

  /// Update the record identified by [id] with [data].
  Future<T> update(String id, Map<String, dynamic> data) {
    return repository.update(id, data);
  }

  /// Delete the record identified by [id].
  Future<void> delete(String id) {
    return repository.delete(id);
  }
}
