// lib/models/plan.dart

class Plan {
  final String id;
  String name;
  double price;
  int durationDays;
  String description;
  List<String> features;
  bool isActive;
  String color; // hex color string

  Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    this.description = '',
    List<String>? features,
    this.isActive = true,
    this.color = '#FF6B35',
  }) : features = features ?? [];

  String get durationLabel {
    if (durationDays == 30) return '1 Month';
    if (durationDays == 90) return '3 Months';
    if (durationDays == 180) return '6 Months';
    if (durationDays == 365) return '1 Year';
    return '$durationDays Days';
  }

  double get pricePerDay => price / durationDays;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'durationDays': durationDays,
        'description': description,
        'features': features,
        'isActive': isActive,
        'color': color,
      };

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json['id'],
        name: json['name'],
        price: (json['price']).toDouble(),
        durationDays: json['durationDays'],
        description: json['description'] ?? '',
        features: List<String>.from(json['features'] ?? []),
        isActive: json['isActive'] ?? true,
        color: json['color'] ?? '#FF6B35',
      );

  static List<Plan> defaultPlans() => [
        Plan(
          id: 'plan_monthly',
          name: 'Monthly',
          price: 1500,
          durationDays: 30,
          description: 'Full gym access for 1 month',
          features: ['Gym Access', 'Locker', 'Basic Training'],
          color: '#4CAF50',
        ),
        Plan(
          id: 'plan_quarterly',
          name: 'Quarterly',
          price: 3999,
          durationDays: 90,
          description: 'Full gym access for 3 months',
          features: ['Gym Access', 'Locker', 'Diet Plan', 'Personal Trainer'],
          color: '#2196F3',
        ),
        Plan(
          id: 'plan_halfyearly',
          name: 'Half Yearly',
          price: 6999,
          durationDays: 180,
          description: 'Full gym access for 6 months',
          features: [
            'Gym Access',
            'Locker',
            'Diet Plan',
            'Personal Trainer',
            'Body Assessment'
          ],
          color: '#FF9800',
        ),
        Plan(
          id: 'plan_yearly',
          name: 'Annual',
          price: 11999,
          durationDays: 365,
          description: 'Full gym access for 1 year',
          features: [
            'Gym Access',
            'Locker',
            'Diet Plan',
            'Personal Trainer',
            'Body Assessment',
            'Priority Support'
          ],
          color: '#9C27B0',
        ),
      ];
}
