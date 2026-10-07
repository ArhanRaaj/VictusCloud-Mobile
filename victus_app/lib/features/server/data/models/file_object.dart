import 'package:json_annotation/json_annotation.dart';

part 'file_object.g.dart';

@JsonSerializable(createToJson: true)
class FileObject {
  final String name;
  final String mode;
  final String modifiedAt;
  final int size;
  final bool isFile;
  final bool isSymlink;
  final bool isEditable;
  final String mimeType;

  FileObject({
    required this.name,
    required this.mode,
    required this.modifiedAt,
    required this.size,
    required this.isFile,
    required this.isSymlink,
    required this.isEditable,
    required this.mimeType,
  });

  factory FileObject.fromJson(Map<String, dynamic> json) => _$FileObjectFromJson(json);
  Map<String, dynamic> toJson() => _$FileObjectToJson(this);
}
