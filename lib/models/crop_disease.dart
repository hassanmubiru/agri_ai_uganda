class CropDisease {
  final String name;
  final double confidence;
  final String treatment;
  final String localRemedy;

  CropDisease({
    required this.name,
    required this.confidence,
    required this.treatment,
    required this.localRemedy,
  });

  // Helper to get dummy data based on name
  static CropDisease fromName(String name, double confidence) {
    String treatment = "Consult an expert.";
    String localRemedy = "Keep the field clean.";

    if (name.contains("Cassava Mosaic")) {
      treatment = "Use disease-free cuttings. Remove infected plants.";
      localRemedy = "Mix ash with water and spray (traditional method).";
    } else if (name.contains("Maize Streak")) {
      treatment = "Plant resistant varieties. Control leafhoppers.";
      localRemedy = "Intercrop with beans to repel pests.";
    } else if (name.contains("Aphids")) {
      treatment = "Apply neem oil or insecticidal soap.";
      localRemedy = "Spray with pepper and soap solution.";
    }

    return CropDisease(
      name: name,
      confidence: confidence,
      treatment: treatment,
      localRemedy: localRemedy,
    );
  }
}
