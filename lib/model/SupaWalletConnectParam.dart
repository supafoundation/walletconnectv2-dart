import 'package:json_annotation/json_annotation.dart';
part 'SupaWalletConnectParam.g.dart';

@JsonSerializable(anyMap: true, explicitToJson: true)
class SupaWalletConnectParam {

  SupaWalletConnectParam(this.projectId, this.name, this.description, this.url, this.icons);

  String projectId;
  String name;
  String description;
  String url;
  List<String> icons;
}