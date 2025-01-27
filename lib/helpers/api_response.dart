class ApiResponse {
  final bool status;
  final dynamic output;
  final List<String> errors;
  final Map<String, dynamic> validations;

  ApiResponse({
    required this.status,
    required this.output,
    required this.errors,
    required this.validations,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] as bool,
      output: json['output'],
      errors: List<String>.from(json['errors'] ?? []),
      validations: Map<String, dynamic>.from(json['validations'] ?? {}),
    );
  }
}