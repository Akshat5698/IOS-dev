/// Abstract base for every data model in the application.
///
/// Enforces a consistent contract: every model must expose an [id],
/// be constructable from JSON, and serialisable back to JSON.
abstract class BaseModel {
  /// The unique identifier for this entity.
  String get id;

  /// Serialise this model to a JSON-compatible map.
  ///
  /// Subclasses must implement this so that the result can be sent
  /// directly to Supabase insert/update calls.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '${runtimeType}(id: $id)';
}
