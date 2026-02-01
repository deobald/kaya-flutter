// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anga.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Anga {
  /// The filename (not the full path)
  String get filename => throw _privateConstructorUsedError;

  /// The full path to the file
  String get path => throw _privateConstructorUsedError;

  /// The type of anga
  AngaType get type => throw _privateConstructorUsedError;

  /// When this anga was created (parsed from filename)
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Cached content for display (optional)
  String? get content => throw _privateConstructorUsedError;

  /// For bookmarks: the URL
  String? get url => throw _privateConstructorUsedError;

  /// File size in bytes (optional)
  int? get fileSize => throw _privateConstructorUsedError;

  /// Create a copy of Anga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AngaCopyWith<Anga> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AngaCopyWith<$Res> {
  factory $AngaCopyWith(Anga value, $Res Function(Anga) then) =
      _$AngaCopyWithImpl<$Res, Anga>;
  @useResult
  $Res call({
    String filename,
    String path,
    AngaType type,
    DateTime createdAt,
    String? content,
    String? url,
    int? fileSize,
  });
}

/// @nodoc
class _$AngaCopyWithImpl<$Res, $Val extends Anga>
    implements $AngaCopyWith<$Res> {
  _$AngaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Anga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filename = null,
    Object? path = null,
    Object? type = null,
    Object? createdAt = null,
    Object? content = freezed,
    Object? url = freezed,
    Object? fileSize = freezed,
  }) {
    return _then(
      _value.copyWith(
            filename: null == filename
                ? _value.filename
                : filename // ignore: cast_nullable_to_non_nullable
                      as String,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as AngaType,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AngaImplCopyWith<$Res> implements $AngaCopyWith<$Res> {
  factory _$$AngaImplCopyWith(
    _$AngaImpl value,
    $Res Function(_$AngaImpl) then,
  ) = __$$AngaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String filename,
    String path,
    AngaType type,
    DateTime createdAt,
    String? content,
    String? url,
    int? fileSize,
  });
}

/// @nodoc
class __$$AngaImplCopyWithImpl<$Res>
    extends _$AngaCopyWithImpl<$Res, _$AngaImpl>
    implements _$$AngaImplCopyWith<$Res> {
  __$$AngaImplCopyWithImpl(_$AngaImpl _value, $Res Function(_$AngaImpl) _then)
    : super(_value, _then);

  /// Create a copy of Anga
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filename = null,
    Object? path = null,
    Object? type = null,
    Object? createdAt = null,
    Object? content = freezed,
    Object? url = freezed,
    Object? fileSize = freezed,
  }) {
    return _then(
      _$AngaImpl(
        filename: null == filename
            ? _value.filename
            : filename // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as AngaType,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

class _$AngaImpl extends _Anga {
  const _$AngaImpl({
    required this.filename,
    required this.path,
    required this.type,
    required this.createdAt,
    this.content,
    this.url,
    this.fileSize,
  }) : super._();

  /// The filename (not the full path)
  @override
  final String filename;

  /// The full path to the file
  @override
  final String path;

  /// The type of anga
  @override
  final AngaType type;

  /// When this anga was created (parsed from filename)
  @override
  final DateTime createdAt;

  /// Cached content for display (optional)
  @override
  final String? content;

  /// For bookmarks: the URL
  @override
  final String? url;

  /// File size in bytes (optional)
  @override
  final int? fileSize;

  @override
  String toString() {
    return 'Anga(filename: $filename, path: $path, type: $type, createdAt: $createdAt, content: $content, url: $url, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AngaImpl &&
            (identical(other.filename, filename) ||
                other.filename == filename) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    filename,
    path,
    type,
    createdAt,
    content,
    url,
    fileSize,
  );

  /// Create a copy of Anga
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AngaImplCopyWith<_$AngaImpl> get copyWith =>
      __$$AngaImplCopyWithImpl<_$AngaImpl>(this, _$identity);
}

abstract class _Anga extends Anga {
  const factory _Anga({
    required final String filename,
    required final String path,
    required final AngaType type,
    required final DateTime createdAt,
    final String? content,
    final String? url,
    final int? fileSize,
  }) = _$AngaImpl;
  const _Anga._() : super._();

  /// The filename (not the full path)
  @override
  String get filename;

  /// The full path to the file
  @override
  String get path;

  /// The type of anga
  @override
  AngaType get type;

  /// When this anga was created (parsed from filename)
  @override
  DateTime get createdAt;

  /// Cached content for display (optional)
  @override
  String? get content;

  /// For bookmarks: the URL
  @override
  String? get url;

  /// File size in bytes (optional)
  @override
  int? get fileSize;

  /// Create a copy of Anga
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AngaImplCopyWith<_$AngaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
