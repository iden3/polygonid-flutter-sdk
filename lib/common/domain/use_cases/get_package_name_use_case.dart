import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';

@singleton
class GetPackageNameUseCase extends FutureUseCase<void, String> {
  final PackageInfo _packageInfo;

  GetPackageNameUseCase(this._packageInfo);

  @override
  Future<String> execute({dynamic param}) async {
    return _packageInfo.packageName;
  }
}
