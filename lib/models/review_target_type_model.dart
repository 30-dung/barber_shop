import 'package:json_annotation/json_annotation.dart';

enum ReviewTargetType {
  @JsonValue('STORE')
  STORE,
  @JsonValue('EMPLOYEE')
  EMPLOYEE,
  @JsonValue('SERVICE')
  SERVICE,
  @JsonValue('STORE_SERVICE')
  STORE_SERVICE,
}
