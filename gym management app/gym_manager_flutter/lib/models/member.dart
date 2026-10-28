// lib/models/member.dart

class Member {
  final String id;
  String name;
  String phone;
  String email;
  String planId;
  DateTime joinDate;
  DateTime expiryDate;
  String status; // active, expired, paused
  String photoUrl;
  double amountPaid;
  double amountDue;
  String gender;
  int age;
  String address;
  List<PaymentRecord> payments;

  Member({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    required this.planId,
    required this.joinDate,
    required this.expiryDate,
    this.status = 'active',
    this.photoUrl = '',
    this.amountPaid = 0,
    this.amountDue = 0,
    this.gender = 'Male',
    this.age = 25,
    this.address = '',
    List<PaymentRecord>? payments,
  }) : payments = payments ?? [];

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isExpiringSoon =>
      expiryDate.difference(DateTime.now()).inDays <= 7 &&
      expiryDate.isAfter(DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'planId': planId,
        'joinDate': joinDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'status': status,
        'photoUrl': photoUrl,
        'amountPaid': amountPaid,
        'amountDue': amountDue,
        'gender': gender,
        'age': age,
        'address': address,
        'payments': payments.map((p) => p.toJson()).toList(),
      };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        email: json['email'] ?? '',
        planId: json['planId'],
        joinDate: DateTime.parse(json['joinDate']),
        expiryDate: DateTime.parse(json['expiryDate']),
        status: json['status'] ?? 'active',
        photoUrl: json['photoUrl'] ?? '',
        amountPaid: (json['amountPaid'] ?? 0).toDouble(),
        amountDue: (json['amountDue'] ?? 0).toDouble(),
        gender: json['gender'] ?? 'Male',
        age: json['age'] ?? 25,
        address: json['address'] ?? '',
        payments: (json['payments'] as List<dynamic>?)
                ?.map((p) => PaymentRecord.fromJson(p))
                .toList() ??
            [],
      );
}

class PaymentRecord {
  final String id;
  final double amount;
  final DateTime date;
  final String method;
  final String note;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.date,
    this.method = 'Cash',
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'method': method,
        'note': note,
      };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: json['id'],
        amount: (json['amount']).toDouble(),
        date: DateTime.parse(json['date']),
        method: json['method'] ?? 'Cash',
        note: json['note'] ?? '',
      );
}
