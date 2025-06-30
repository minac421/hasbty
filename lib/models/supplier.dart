class Supplier {
  final String? id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? notes;
  final String? paymentTerms; // شروط الدفع
  final double? creditLimit; // حد الائتمان
  final double currentBalance; // الرصيد الحالي
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  Supplier({
    this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.notes,
    this.paymentTerms,
    this.creditLimit,
    this.currentBalance = 0.0,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contactPerson: json['contact_person'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      notes: json['notes'],
      paymentTerms: json['payment_terms'],
      creditLimit: json['credit_limit']?.toDouble(),
      currentBalance: (json['current_balance'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'notes': notes,
      'payment_terms': paymentTerms,
      'credit_limit': creditLimit,
      'current_balance': currentBalance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? notes,
    String? paymentTerms,
    double? creditLimit,
    double? currentBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  // التحقق من تجاوز حد الائتمان
  bool get isCreditLimitExceeded {
    if (creditLimit == null) return false;
    return currentBalance > creditLimit!;
  }

  // حساب المبلغ المتاح للشراء
  double get availableCredit {
    if (creditLimit == null) return double.infinity;
    return creditLimit! - currentBalance;
  }
}

