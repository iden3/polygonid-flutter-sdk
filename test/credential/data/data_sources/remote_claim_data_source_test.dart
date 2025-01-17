import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/remote_claim_data_source.dart';

import 'remote_claim_data_source_test.mocks.dart';

// Data
const url = "theUrl";
const issuer = "theIssuer";
const identifier = "theIdentifier";
Response response = Response("body", 200);
Response errorResponse = Response("body", 444);

final exception = Exception();

// Dependencies
MockClient client = MockClient();
MockStacktraceManager stacktraceStreamManager = MockStacktraceManager();

// Tested instance
RemoteClaimDataSource dataSource = RemoteClaimDataSource(
  client,
  stacktraceStreamManager,
);

@GenerateMocks([
  Client,
  StacktraceManager,
])
void main() {}
