import 'package:json_annotation/json_annotation.dart';

part 'role_model.g.dart'; // Changed to _model.g.dart for consistency

@JsonSerializable()
class Role {
  int? roleId;
  String roleName;
  String? description;

  Role({this.roleId, required this.roleName, this.description});

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
