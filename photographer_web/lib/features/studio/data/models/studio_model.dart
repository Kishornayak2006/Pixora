class StudioModel {
  final int? id;
  final int? ownerId;

  final String studioName;
  final String phone;
  final String email;

  final String? description;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? logoUrl;

  final bool? isVerified;

  StudioModel({
    this.id,
    this.ownerId,
    required this.studioName,
    required this.phone,
    required this.email,
    this.description,
    this.address,
    this.city,
    this.state,
    this.country,
    this.logoUrl,
    this.isVerified,
  });

  factory StudioModel.fromJson(Map<String, dynamic> json) {
    return StudioModel(
      id: json["id"],
      ownerId: json["owner_id"],
      studioName: json["studio_name"],
      phone: json["phone"],
      email: json["email"],
      description: json["description"],
      address: json["address"],
      city: json["city"],
      state: json["state"],
      country: json["country"],
      logoUrl: json["logo_url"],
      isVerified: json["is_verified"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "studio_name": studioName,
      "phone": phone,
      "email": email,
      "description": description,
      "address": address,
      "city": city,
      "state": state,
      "country": country,
      "logo_url": logoUrl,
    };
  }
}