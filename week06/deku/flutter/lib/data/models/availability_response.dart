final class AvailabilityResponse {
  const AvailabilityResponse({required this.available});

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) {
    final value = json['available'];
    return AvailabilityResponse(
      available: value == true || value?.toString().toLowerCase() == 'true',
    );
  }

  final bool available;
}
