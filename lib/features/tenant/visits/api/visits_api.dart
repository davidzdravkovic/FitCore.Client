import 'package:fitcore_client/core/api/api_client.dart';
import 'package:fitcore_client/features/tenant/visits/models/create_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/models/record_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/models/reschedule_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/models/resolve_visit_request.dart';
import 'package:fitcore_client/features/tenant/visits/models/visit_response.dart';
import 'package:fitcore_client/features/tenant/visits/models/void_visit_request.dart';

class VisitsApi {
  VisitsApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<List<VisitResponse>> list({DateTime? from, DateTime? to}) {
    final params = <String, String>{};
    if (from != null) {
      params['from'] = from.toUtc().toIso8601String();
    }
    if (to != null) {
      params['to'] = to.toUtc().toIso8601String();
    }

    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    return _client.request<List<VisitResponse>>(
      '/api/visits$query',
      parse: (json) {
        final items = json as List<dynamic>? ?? const [];
        return items.map(VisitResponse.fromJson).toList();
      },
    );
  }

  Future<VisitResponse> create(CreateVisitRequest request) {
    return _client.request<VisitResponse>(
      '/api/visits',
      method: 'POST',
      data: request.toJson(),
      parse: VisitResponse.fromJson,
    );
  }

  Future<VisitResponse> record(RecordVisitRequest request) {
    return _client.request<VisitResponse>(
      '/api/visits/record',
      method: 'POST',
      data: request.toJson(),
      parse: VisitResponse.fromJson,
    );
  }

  Future<VisitResponse> resolve(String id, ResolveVisitRequest request) {
    return _client.request<VisitResponse>(
      '/api/visits/$id/resolve',
      method: 'POST',
      data: request.toJson(),
      parse: VisitResponse.fromJson,
    );
  }

  Future<VisitResponse> reschedule(String id, RescheduleVisitRequest request) {
    return _client.request<VisitResponse>(
      '/api/visits/$id/reschedule',
      method: 'POST',
      data: request.toJson(),
      parse: VisitResponse.fromJson,
    );
  }

  Future<VisitResponse> voidVisit(String id, VoidVisitRequest request) {
    return _client.request<VisitResponse>(
      '/api/visits/$id/void',
      method: 'POST',
      data: request.toJson(),
      parse: VisitResponse.fromJson,
    );
  }
}
