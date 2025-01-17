import 'package:polygonid_flutter_sdk/common/mappers/mapper.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/display_type/display_type.dart';

class DisplayTypeMapper extends Mapper<Map<String, dynamic>, DisplayType> {
  @override
  DisplayType mapFrom(Map<String, dynamic> from) {
    return DisplayType.fromJson(from);
  }

  @override
  Map<String, dynamic> mapTo(DisplayType to) {
    final json = to.toJson();
    json['type'] = to.typeName;
    return json;
  }
}
