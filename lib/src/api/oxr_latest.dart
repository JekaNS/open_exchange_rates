import 'dart:async';
import 'dart:convert';
import 'oxr_base.dart';
import 'package:http/http.dart' as http;

class Latest extends OxrBase {
  final String app_id;
  Latest(app_id) : app_id = app_id;

  Future<Map> Get(
      {String base,
      String symbols,
      bool prettyprint,
      bool show_alternative}) async {
    final http.Client client = http.Client();
    final _uri = latestTemplate.expand({
      'app_id': this.app_id,
      'base': base,
      'symbols': symbols,
      'prettyprint': prettyprint,
      'show_alternative': show_alternative,
    });
    // TODO: handle Error
    return await client
        .get(_uri)
        .then((res) => json.decode(res.body))
        .catchError((e) => print(e))
        .whenComplete(() => client.close());
  }
}
