class ResultModel {
  final String classification;
  final String confidence;
  final String severity;

  ResultModel({
    required this.classification,
    required this.confidence,
    required this.severity,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      classification: json["classification"],
      confidence: json["confidence_score"],
      severity: json["severity"],
    );
  }
}