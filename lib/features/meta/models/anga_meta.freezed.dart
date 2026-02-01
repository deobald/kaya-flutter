// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anga_meta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AngaMeta {
  /// The metadata filename (not the full path)
  String get metaFilename => throw _privateConstructorUsedError;

  /// The full path to the metadata file
  String get path => throw _privateConstructorUsedError;

  /// The anga filename this metadata references
  String get angaFilename => throw _privateConstructorUsedError;

  /// Tags associated with the anga
  List<String> get tags => throw _privateConstructorUsedError;

  /// User's note about the anga
  String? get note => throw _privateConstructorUsedError;

  /// When this metadata was created (parsed from filename)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of AngaMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AngaMetaCopyWith<AngaMeta> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AngaMetaCopyWith<$Res> {
  factory $AngaMetaCopyWith(AngaMeta value, $Res Function(AngaMeta) then) =
      _$AngaMetaCopyWithImpl<$Res, AngaMeta>;
  @useResult
  $Res call({
    String metaFilename,
    String path,
    String angaFilename,
    List<String> tags,
    String? note,
    DateTime createdAt,
  });
}

/// @nodoc
class _$AngaMetaCopyWithImpl<$Res, $Val extends AngaMeta>
    implements $AngaMetaCopyWith<$Res> {
  _$AngaMetaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AngaMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metaFilename = null,
    Object? path = null,
    Object? angaFilename = null,
    Object? tags = null,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            metaFilename: null == metaFilename
                ? _value.metaFilename
                : metaFilename // ignore: cast_nullable_to_non_nullable
                      as String,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            angaFilename: null == angaFilename
                ? _value.angaFilename
                : angaFilename // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AngaMetaImplCopyWith<$Res>
    implements $AngaMetaCopyWith<$Res> {
  factory _$$AngaMetaImplCopyWith(
    _$AngaMetaImpl value,
    $Res Function(_$AngaMetaImpl) then,
  ) = __$$AngaMetaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String metaFilename,
    String path,
    String angaFilename,
    List<String> tags,
    String? note,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$AngaMetaImplCopyWithImpl<$Res>
    extends _$AngaMetaCopyWithImpl<$Res, _$AngaMetaImpl>
    implements _$$AngaMetaImplCopyWith<$Res> {
  __$$AngaMetaImplCopyWithImpl(
    _$AngaMetaImpl _value,
    $Res Function(_$AngaMetaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AngaMeta
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metaFilename = null,
    Object? path = null,
    Object? angaFilename = null,
    Object? tags = null,
    Object? note = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$AngaMetaImpl(
        metaFilename: null == metaFilename
            ? _value.metaFilename
            : metaFilename // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        angaFilename: null == angaFilename
            ? _value.angaFilename
            : angaFilename // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$AngaMetaImpl extends _AngaMeta {
  const _$AngaMetaImpl({
    required this.metaFilename,
    required this.path,
    required this.angaFilename,
    required final List<String> tags,
    this.note,
    required this.createdAt,
  }) : _tags = tags,
       super._();

  /// The metadata filename (not the full path)
  @override
  final String metaFilename;

  /// The full path to the metadata file
  @override
  final String path;

  /// The anga filename this metadata references
  @override
  final String angaFilename;

  /// Tags associated with the anga
  final List<String> _tags;

  /// Tags associated with the anga
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// User's note about the anga
  @override
  final String? note;

  /// When this metadata was created (parsed from filename)
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AngaMeta(metaFilename: $metaFilename, path: $path, angaFilename: $angaFilename, tags: $tags, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AngaMetaImpl &&
            (identical(other.metaFilename, metaFilename) ||
                other.metaFilename == metaFilename) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.angaFilename, angaFilename) ||
                other.angaFilename == angaFilename) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    metaFilename,
    path,
    angaFilename,
    const DeepCollectionEquality().hash(_tags),
    note,
    createdAt,
  );

  /// Create a copy of AngaMeta
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AngaMetaImplCopyWith<_$AngaMetaImpl> get copyWith =>
      __$$AngaMetaImplCopyWithImpl<_$AngaMetaImpl>(this, _$identity);
}

abstract class _AngaMeta extends AngaMeta {
  const factory _AngaMeta({
    required final String metaFilename,
    required final String path,
    required final String angaFilename,
    required final List<String> tags,
    final String? note,
    required final DateTime createdAt,
  }) = _$AngaMetaImpl;
  const _AngaMeta._() : super._();

  /// The metadata filename (not the full path)
  @override
  String get metaFilename;

  /// The full path to the metadata file
  @override
  String get path;

  /// The anga filename this metadata references
  @override
  String get angaFilename;

  /// Tags associated with the anga
  @override
  List<String> get tags;

  /// User's note about the anga
  @override
  String? get note;

  /// When this metadata was created (parsed from filename)
  @override
  DateTime get createdAt;

  /// Create a copy of AngaMeta
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AngaMetaImplCopyWith<_$AngaMetaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
