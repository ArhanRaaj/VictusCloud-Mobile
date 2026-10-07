import 'package:json_annotation/json_annotation.dart';

part 'websocket_auth.g.dart';

@JsonSerializable()
class WebsocketAuth {
  final String token;
  final String socket;

  WebsocketAuth({
    required this.token,
    required this.socket,
  });

  factory WebsocketAuth.fromJson(Map<String, dynamic> json) =>
      _$WebsocketAuthFromJson(json);

  Map<String, dynamic> toJson() => _$WebsocketAuthToJson(this);
}
