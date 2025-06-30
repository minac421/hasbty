

class Customer {
  final String? id;
  final String userId;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final double balance; // الرصيد (موجب = له رصيد، سالب = مديون)
  final double creditLimit; // الحد الأقصى للدين
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    this.id,
    required this.userId,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.balance = 0.0,
    this.creditLimit = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String?,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'balance': balance,
      'credit_limit': creditLimit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    double? balance,
    double? creditLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isDebtor => balance < 0;
  bool get hasCredit => balance > 0;
  double get debtAmount => balance < 0 ? balance.abs() : 0.0;
  double get creditAmount => balance > 0 ? balance : 0.0;
  bool get isAtCreditLimit => balance.abs() >= creditLimit;
}


