import 'dart:convert';

class GenerationListResponse { 
  final int count;
  final String? next;
  final String? previous;
  final List<GenerationItem> results;

  GenerationListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  //Metodo para recibir directamente el response.body (String)
  factory GenerationListResponse.fromRawJson(String str) => 
  GenerationListResponse.fromJson(json.decode(str));

  //Metodo para recibir el Map ya decodificado
  factory GenerationListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List? ?? [];
    List<GenerationItem> resultsList = list.map((item) =>
    GenerationItem.fromJson(item)).toList();

    return GenerationListResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: resultsList,
    );
  } 
}

class GenerationItem {
  final String name;
  final String url;

  GenerationItem({
    required this.name,
    required this.url,
  });

  factory GenerationItem.fromRawJson(String str) =>
  GenerationItem.fromJson(json.decode(str));

  factory GenerationItem.fromJson(Map<String, dynamic> json) {
    return GenerationItem(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }

  //En caso de querer mandarlo a nuestro backend, podemos convertirlo a json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
    };
  }

  //Extraer el Id de la generacion directamente desde la URL
  int get id {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    return int.parse(segments.last);
  }

}