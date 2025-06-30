class Sale {
  final String? id;
  final String? customerId;
  final String customerName;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final double finalAmount;
  final String paymentMethod; // نقدي، بطاقة، آجل
  final String status; // مكتملة، معلقة، ملغية
  final String? notes;
  final DateTime saleDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final List<SaleItem> items;

  Sale({
    this.id,
    this.customerId,
    required this.customerName,
    required this.totalAmount,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.finalAmount,
    required this.paymentMethod,
    this.status = 'مكتملة',
    this.notes,
    required this.saleDate,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.items = const [],
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      finalAmount: (json['final_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'نقدي',
      status: json['status'] ?? 'مكتملة',
      notes: json['notes'],
      saleDate: DateTime.parse(json['sale_date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      items: json['items'] != null 
          ? (json['items'] as List).map((item) => SaleItem.fromJson(item)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'status': status,
      'notes': notes,
      'sale_date': saleDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  Sale copyWith({
    String? id,
    String? customerId,
    String? customerName,
    double? totalAmount,
    double? discountAmount,
    double? taxAmount,
    double? finalAmount,
    String? paymentMethod,
    String? status,
    String? notes,
    DateTime? saleDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    List<SaleItem>? items,
  }) {
    return Sale(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      saleDate: saleDate ?? this.saleDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }

  // حساب إجمالي الربح
  double get totalProfit {
    return items.fold(0.0, (sum, item) => sum + item.profit);
  }

  // حساب عدد الأصناف
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}

class SaleItem {
  final String? id;
  final String saleId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double purchasePrice; // لحساب الربح
  final String? notes;

  SaleItem({
    this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.purchasePrice,
    this.notes,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'],
      saleId: json['sale_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      purchasePrice: (json['purchase_price'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'purchase_price': purchasePrice,
      'notes': notes,
    };
  }

  SaleItem copyWith({
    String? id,
    String? saleId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    double? purchasePrice,
    String? notes,
  }) {
    return SaleItem(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      notes: notes ?? this.notes,
    );
  }

  // حساب الربح لهذا العنصر
  double get profit => (unitPrice - purchasePrice) * quantity;

  // حساب نسبة الربح
  double get profitMargin {
    if (unitPrice == 0) return 0;
    return ((unitPrice - purchasePrice) / unitPrice) * 100;
  }
}

