// lib/models/gym_info.dart

class GymInfo {
  String name;
  String ownerName;
  String phone;
  String email;
  String address;
  String city;
  String tagline;
  String openTime;
  String closeTime;
  List<String> workingDays;
  String gstNumber;
  String website;
  String instagramHandle;

  GymInfo({
    this.name = 'PowerFit Gym',
    this.ownerName = 'Gym Owner',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.tagline = 'Train Hard. Stay Fit.',
    this.openTime = '06:00 AM',
    this.closeTime = '10:00 PM',
    List<String>? workingDays,
    this.gstNumber = '',
    this.website = '',
    this.instagramHandle = '',
  }) : workingDays = workingDays ??
            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'ownerName': ownerName,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'tagline': tagline,
        'openTime': openTime,
        'closeTime': closeTime,
        'workingDays': workingDays,
        'gstNumber': gstNumber,
        'website': website,
        'instagramHandle': instagramHandle,
      };

  factory GymInfo.fromJson(Map<String, dynamic> json) => GymInfo(
        name: json['name'] ?? 'PowerFit Gym',
        ownerName: json['ownerName'] ?? 'Gym Owner',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        tagline: json['tagline'] ?? 'Train Hard. Stay Fit.',
        openTime: json['openTime'] ?? '06:00 AM',
        closeTime: json['closeTime'] ?? '10:00 PM',
        workingDays: List<String>.from(json['workingDays'] ?? ['Mon','Tue','Wed','Thu','Fri','Sat']),
        gstNumber: json['gstNumber'] ?? '',
        website: json['website'] ?? '',
        instagramHandle: json['instagramHandle'] ?? '',
      );
}
