import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uri/uri.dart';

import '../oxr.dart';

class Oxr {
  static const defaultApiEndpoint = 'https://openexchangerates.org';
  final dateFormatter = DateFormat('yyyy-MM-dd');

  String apiKey;
  String endpoint;
  Map<String, String> headers = {};

  QueryParams getParams({String? base, String? symbols, bool prettyPrint = true, bool showAlternative = false, bool showInactive = false}) =>
      QueryParams(base: base, symbols: symbols, prettyPrint: prettyPrint, showAlternative: showAlternative);

  Oxr(this.apiKey, {this.endpoint = defaultApiEndpoint}) {
    headers = {
      'Authorization': 'Token $apiKey',
      'User-Agent': 'oxr-sdk-dart/$version',
      'Content-Type': 'application/json',
    };
  }
  Future<Rates?> getLatest({String? base, String? symbols, bool prettyPrint = true, bool showAlternative = false}) async {
    Rates? latest;
    var uri = UriTemplate('$endpoint/api/latest.json{?base,symbols,prettyprint,show_alternative}')
        .expand(getParams(base: base, symbols: symbols, prettyPrint: prettyPrint, showAlternative: showAlternative).toJson());
    var response = await _get(uri);
    if (response.statusCode == HttpStatus.ok) {
      latest = Rates.fromJson(jsonDecode(response.body));
    }
    return latest;
  }

  Future<Rates?> getHistorical(DateTime date, {String? base, String? symbols, bool prettyPrint = true, bool showAlternative = false}) async {
    Rates? historical;
    var uri = UriTemplate('$endpoint/api/historical/${dateFormatter.format(date)}.json{?base,symbols,prettyprint,show_alternative}')
        .expand(getParams(base: base, symbols: symbols, prettyPrint: prettyPrint, showAlternative: showAlternative).toJson());
    var response = await _get(uri);
    if (response.statusCode == HttpStatus.ok) {
      historical = Rates.fromJson(jsonDecode(response.body));
    }
    return historical;
  }

  Future<Map<String, String>?> getCurrencies({bool prettyPrint = true, bool showAlternative = false, bool showInactive = false}) async {
    Map<String, String>? currencies;
    var uri = UriTemplate('$endpoint/api/currencies.json{?prettyprint,show_alternative,show_inactive}')
        .expand(getParams(prettyPrint: prettyPrint, showAlternative: showAlternative, showInactive: showInactive).toJson());
    var response = await _get(uri);
    if (response.statusCode == HttpStatus.ok) {
      currencies = jsonDecode(response.body).map<String, String>((key, value) => MapEntry<String, String>(key, value));
    }
    return currencies;
  }

  Future<http.Response> _get(String url) async {
    http.Response response = await http.get(Uri.parse(url), headers: headers);
    return response;
  }
}
