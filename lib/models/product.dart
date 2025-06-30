class Product {
  final String? id;
  final String name;
  final String? description;
  final String? barcode;
  final double purchasePrice;
  final double sellingPrice;
  final String unit; // قطعة، كجم، لتر، علبة
  final int currentStock;
  final int minimumStock;
  final String? category;
  final String? supplierId;
  final DateTime? expiryDate;
  final String? batchNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  Product({
    this.id,
    required this.name,
    this.description,
    this.barcode,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.unit,
    required this.currentStock,
    required this.minimumStock,
    this.category,
    this.supplierId,
    this.expiryDate,
    this.batchNumber,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      barcode: json['barcode'],
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      sellingPrice: (json['selling_price'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'قطعة',
      currentStock: json['current_stock'] ?? 0,
      minimumStock: json['minimum_stock'] ?? 0,
      category: json['category'],
      supplierId: json['supplier_id'],
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : null,
      batchNumber: json['batch_number'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'barcode': barcode,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'unit': unit,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'category': category,
      'supplier_id': supplierId,
      'expiry_date': expiryDate?.toIso8601String(),
      'batch_number': batchNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? barcode,
    double? purchasePrice,
    double? sellingPrice,
    String? unit,
    int? currentStock,
    int? minimumStock,
    String? category,
    String? supplierId,
    DateTime? expiryDate,
    String? batchNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      category: category ?? this.category,
      supplierId: supplierId ?? this.supplierId,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  // حساب الربح لكل وحدة
  double get profitPerUnit => sellingPrice - purchasePrice;

  // حساب إجمالي قيمة المخزون
  double get totalStockValue => currentStock * purchasePrice;

  // التحقق من انخفاض المخزون
  bool get isLowStock => currentStock <= minimumStock;

  // التحقق من انتهاء الصلاحية قريباً (خلال 30 يوم)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  // التحقق من انتهاء الصلاحية
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }
}

