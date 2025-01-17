import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/mappers/from_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_request_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_scope_query_request.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';

class ProofRequestFiltersMapper
    extends FromMapper<ProofRequestEntity, List<FilterEntity>> {
  final StacktraceManager _stacktraceManager;

  ProofRequestFiltersMapper(this._stacktraceManager);

  @override
  List<FilterEntity> mapFrom(ProofRequestEntity from) {
    ProofScopeQueryRequest query = from.scope.query;

    Map<String, dynamic>? context;
    try {
      context = from.context["@context"][0][query.type]["@context"];
    } catch (e) {
      _stacktraceManager.addError(
          "Error getting context from schema: ${query.type}\nSchema does not have a context, please check the schema is json-ld compliant");
      throw UnsupportedSchemaException(
        schema: query.type ?? "",
        errorMessage:
            "Schema does not have a context, please check the schema is json-ld compliant",
        error: e,
      );
    }

    List<FilterEntity> filters = [
      FilterEntity(
          name: 'credential.credentialSubject.type', value: query.type!),
      FilterEntity(
          operator: FilterOperator.equalsAnyInList,
          name: 'credential.@context',
          value: query.context!),
    ];
    if (query.allowedIssuers != null &&
        query.allowedIssuers is List &&
        query.allowedIssuers!.isNotEmpty) {
      if (query.allowedIssuers![0] != "*") {
        filters.add(FilterEntity(
            operator: FilterOperator.inList,
            name: 'issuer',
            value: query.allowedIssuers!));
      }
    }

    if (query.skipClaimRevocationCheck == null ||
        query.skipClaimRevocationCheck == false) {
      filters.add(FilterEntity(
          operator: FilterOperator.nonEqual,
          name: 'state',
          value: ClaimState.revoked.name));
    }

    if (query.credentialSubject != null) {
      Map<String, dynamic> request = query.credentialSubject!;
      request.forEach((key, map) {
        if (map != null && map is Map && map.isNotEmpty && context != null) {
          String type = getValueFromNestedString(context, key);
          map.forEach((operator, value) {
            if (type.contains("boolean")) {
              FilterEntity? booleanFilter =
                  _getBooleanFiltersByOperator(key, operator, value);
              if (booleanFilter != null) {
                filters.add(booleanFilter);
              }
            } else if (type.contains("string")) {
              if (operator == '\$in' || operator == '\$nin') {
                List<dynamic> values = List.from(value);
                List<String> stringList =
                    values.map((e) => e.toString()).toList();
                filters.addAll(_getFilterByOperator(key, operator, stringList));
              } else {
                filters.addAll(
                    _getFilterByOperator(key, operator, value.toString()));
              }
            } else if (type.contains("positiveInteger")) {
              // PositiveInteger is not supported by the filter 'cause this type
              // is stored as a string in the database. So we need to filter manually
              // this is why we don't add the filter here
            } else {
              filters.addAll(_getFilterByOperator(key, operator, value));
            }
          });
        }
      });
    }

    return filters;
  }

  ///
  String getValueFromNestedString(
      Map<String, dynamic> contextMap, String nestedKey) {
    List<String> keys = nestedKey.split('.');
    dynamic value = contextMap;
    for (String key in keys) {
      if (value is Map<String, dynamic> && value[key].containsKey("@context")) {
        value = value[key]["@context"];
      } else if (value is Map<String, dynamic> &&
          value[key].containsKey("@type")) {
        value = value[key]["@type"];
        break;
      } else {
        break;
      }
    }
    return value;
  }

  List<FilterEntity> _getFilterByOperator(field, operator, value) {
    switch (operator) {
      case '\$eq':
        return [
          FilterEntity(
              name: 'credential.credentialSubject.$field', value: value)
        ];
      case '\$lt':
        return [
          FilterEntity(
              operator: FilterOperator.lesser,
              name: 'credential.credentialSubject.$field',
              value: value)
        ];
      case '\$lte':
        return [
          FilterEntity(
              operator: FilterOperator.lesserEqual,
              name: 'credential.credentialSubject.$field',
              value: value)
        ];
      case '\$gt':
        return [
          FilterEntity(
              operator: FilterOperator.greater,
              name: 'credential.credentialSubject.$field',
              value: value)
        ];
      case '\$gte':
        return [
          FilterEntity(
              operator: FilterOperator.greaterEqual,
              name: 'credential.credentialSubject.$field',
              value: value)
        ];
      case '\$in':
        if (value is List) {
          return [
            FilterEntity(
                operator: FilterOperator.inList,
                name: 'credential.credentialSubject.$field',
                value: value)
          ];
        } else {
          return [
            FilterEntity(
                operator: FilterOperator.inList,
                name: 'credential.credentialSubject.$field',
                value: [value])
          ];
        }
      case '\$nin':
        return List.from(value)
            .map((item) => FilterEntity(
                name: 'credential.credentialSubject.$field',
                value: item,
                operator: FilterOperator.nonEqual))
            .toList();
      case '\$ne':
        return [
          FilterEntity(
            operator: FilterOperator.nonEqual,
            name: 'credential.credentialSubject.$field',
            value: value,
          )
        ];
      case '\$between':
        if (value is! List || value.isEmpty || value.length != 2) {
          _stacktraceManager.addError(
              "Value for \$between operator must be a list of two elements");
          throw OperatorException(
              errorMessage:
                  "Value for \$between operator must be a list of two elements");
        }

        //order the values if they are not ordered
        value.sort();

        return [
          FilterEntity(
            operator: FilterOperator.between,
            name: 'credential.credentialSubject.$field',
            value: value,
          )
        ];
      case '\$nonbetween':
        if (value is! List || value.isEmpty || value.length != 2) {
          _stacktraceManager.addError(
              "Value for \$nonbetween operator must be a list of two elements");
          throw OperatorException(
              errorMessage:
                  "Value for \$nonbetween operator must be a list of two elements");
        }

        //order the values if they are not ordered
        value.sort();

        return [
          FilterEntity(
            operator: FilterOperator.nonbetween,
            name: 'credential.credentialSubject.$field',
            value: value,
          )
        ];
      case '\$exists':
        bool? parsedValue = _parseValueToBool(value);
        if (parsedValue == null) {
          _stacktraceManager
              .addError("Value for \$exists operator must be a boolean");
          throw OperatorException(
              errorMessage: "Value for \$exists operator must be a boolean");
        }
        return [
          FilterEntity(
            operator: FilterOperator.exists,
            name: 'credential.credentialSubject.$field',
            value: parsedValue,
          )
        ];
      default:
        break;
    }

    return [];
  }

  static const trueValues = [true, "true", 1];
  static const falseValues = [false, "false", 0];

  bool? _parseValueToBool(dynamic value) {
    if (value is int) {
      return value == 1;
    } else if (value is String) {
      return value.toLowerCase() == "true";
    } else if (value is bool) {
      return value;
    }
    return null;
  }

  FilterEntity _createFilterEntity(
      String field, FilterOperator operator, dynamic value) {
    return FilterEntity(
        operator: operator,
        name: 'credential.credentialSubject.$field',
        value: value);
  }

  FilterEntity? _getBooleanFiltersByOperator(field, operator, value) {
    bool? parsedValue = _parseValueToBool(value);
    if (parsedValue == null) {
      return null;
    }

    if (operator == '\$eq') {
      return _createFilterEntity(
          field, FilterOperator.inList, parsedValue ? trueValues : falseValues);
    } else if (operator == '\$ne') {
      return _createFilterEntity(
          field, FilterOperator.inList, parsedValue ? falseValues : trueValues);
    } else if (operator == '\$exists') {
      return _createFilterEntity(field, FilterOperator.exists, parsedValue);
    }
    return null;
  }
}
