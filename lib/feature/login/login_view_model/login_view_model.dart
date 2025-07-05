import 'package:bot_toast/bot_toast.dart';
import 'package:di360_flutter/common/constants/local_storage_const.dart';
import 'package:di360_flutter/common/routes/route_list.dart';
import 'package:di360_flutter/core/http_service.dart';
import 'package:di360_flutter/data/local_storage.dart';
import 'package:di360_flutter/feature/login/model_class/login_res.dart';
import 'package:di360_flutter/services/navigation_services.dart';
import 'package:di360_flutter/utils/alert_diaglog.dart';
import 'package:di360_flutter/utils/loader.dart';
import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final HttpService _http = HttpService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  // String get userType => _variables['details']['type'];

  List<DropdownMenuItem<String>> get userTypeItems => [
        DropdownMenuItem<String>(
          value: 'PROFESSIONAL',
          child: Text('Dental Professional'),
        ),
        DropdownMenuItem<String>(
          value: 'SUPPLIER',
          child: Text('Dental Business Owner'),
        ),
        DropdownMenuItem<String>(
          value: 'PRACTICE',
          child: Text('Dental Practice Owner'),
        ),
      ];

  final Map<String, dynamic> _variables = {
    "details": {"emailOrPhone": "", "password": ""}
  };
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  // onTypeChange(value) {
  //   _variables['details']['type'] = value;
  //   notifyListeners();
  // }

  submit(BuildContext context) async {
    _variables['details']['emailOrPhone'] = emailController.text;
    _variables['details']['password'] = passController.text;
    if (Map.from(_variables['details']).containsValue("")) {
      BotToast.showSimpleNotification(title: "Please fill all the details");
      return "";
    }
    Loaders.circularShowLoader(context);
    try {
      var res = await _http.mutation(loginSchema, _variables);
      if (res.isNotEmpty) {
        if (res['login_api']['status'] == 'ACTIVE' ||
            res['login_api']['status'] == 'UNBLOCKED') {
          final result = LogInData.fromJson(res);
          await LocalStorage.setStringVal(
              LocalStorageConst.name, result.loginApi?.name ?? '');
          await LocalStorage.setStringVal(
              LocalStorageConst.userId, result.loginApi?.id ?? '');
          await LocalStorage.setStringVal(
              LocalStorageConst.token, result.loginApi?.accessToken ?? '');
          await LocalStorage.setStringVal(
              LocalStorageConst.type, result.loginApi?.type ?? '');
          await LocalStorage.setStringVal(
              LocalStorageConst.profilePic,
              result.loginApi?.logo?.url ??
                  result.loginApi?.profileImage?.url ??
                  '');
          await LocalStorage.setBoolValue(LocalStorageConst.isAuth, true);
          _http.setToken(result.loginApi?.accessToken ?? '');
          navigationService.pushNamedAndRemoveUntil(RouteList.dashBoard);
        }
      } else {
        scaffoldMessenger(
            'Either it is Invalid credentials or you have not verified your email.');
        Loaders.circularHideLoader(context);
      }
    } catch (e) {
      scaffoldMessenger('$e');
      Loaders.circularHideLoader(context);
    }
    notifyListeners();
  }

  getUserDetails() async {
    final userId = await LocalStorage.getStringVal(LocalStorageConst.userId);
    final type = await LocalStorage.getStringVal(LocalStorageConst.type);
    var res = await _http.query(
        type == 'SUPPLIER'
            ? getSupplier
            : type == 'PRACTICE'
                ? getPractice
                : type == 'PROFESSIONAL'
                    ? getProfessional
                    : '',
        variables: {"id": userId});
    if (res != null) {
      await LocalStorage.setStringVal(
          LocalStorageConst.profilePic,
          type == 'SUPPLIER'
              ? res['dental_suppliers_by_pk']['profile_image']
              : type == 'PRACTICE'
                  ? res['dental_practices_by_pk']['profile_image']
                  : type == 'PROFESSIONAL'
                      ? res['dental_professionals_by_pk']['profile_image']
                      : '');
    } else {}
    notifyListeners();
  }
}

String get loginSchema =>
    """mutation loginApi(\$details: LoginInput!) { login_api(details: \$details) {   
id   accessToken  
 refreshToken   
 name  
  email   phone   logo   
  status  
   message  
   profile_completed  
    profile_image  
  type   
  address   
  directory_category_id   
  profession_type  
   second_hand   
   business_name   
  abn_number  
   gender  
    sell_products  
   dashboard_permissions   
   plan_id   payment_status  
   subscription_id   }}
""";

final String getSupplier = '''
    query getSupplier(\$id: uuid!) {
      dental_suppliers_by_pk(id: \$id) {
        id
        name
        email
        phone
        type
        subsciption_plan_id
        present_subscription_id
        profile_image
      }
    }
  ''';

final String getPractice = '''
    query getPractice(\$id: uuid!) {
      dental_practices_by_pk(id: \$id) {
        id
        name
        email
        phone
        type
        subsciption_plan_id
        present_subscription_id
        profile_image
      }
    }
  ''';

final String getProfessional = '''
    query getProfessional(\$id: uuid!){
    dental_professionals_by_pk(id:\$id){
        id
        email
        name
        phone
        first_name
        last_name
        type
        subsciption_plan_id
        present_subscription_id
        profile_image
 }
}
  ''';
