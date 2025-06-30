class Purchase {
  final String? id;
  final String supplierId;
  final String supplierName;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final double finalAmount;
  final String paymentMethod; // نقدي، بطاقة، آجل
  final String status; // مكتملة، معلقة، ملغية
  final String? invoiceNumber;
  final String? notes;
  final DateTime purchaseDate;
  final DateTime? dueDate; // تاريخ الاستحقاق للدفع الآجل
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final List<PurchaseItem> items;

  Purchase({
    this.id,
    required this.supplierId,
    required this.supplierName,
    required this.totalAmount,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.finalAmount,
    required this.paymentMethod,
    this.status = 'مكتملة',
    this.invoiceNumber,
    this.notes,
    required this.purchaseDate,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.items = const [],
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      finalAmount: (json['final_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'نقدي',
      status: json['status'] ?? 'مكتملة',
      invoiceNumber: json['invoice_number'],
      notes: json['notes'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userId: json['user_id'],
      items: json['items'] != null 
          ? (json['items'] as List).map((item) => PurchaseItem.fromJson(item)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'status': status,
      'invoice_number': invoiceNumber,
      'notes': notes,
      'purchase_date': purchaseDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  Purchase copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    double? totalAmount,
    double? discountAmount,
    double? taxAmount,
    double? finalAmount,
    String? paymentMethod,
    String? status,
    String? invoiceNumber,
    String? notes,
    DateTime? purchaseDate,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    List<PurchaseItem>? items,
  }) {
    return Purchase(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      notes: notes ?? this.notes,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }

  // حساب عدد الأصناف
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // التحقق من تجاوز تاريخ الاستحقاق
  bool get isOverdue {
    if (dueDate == null || status != 'آجل') return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // حساب الأيام المتبقية للاستحقاق
  int get daysUntilDue {
    if (dueDate == null) return 0;
    return dueDate!.difference(DateTime.now()).inDays;
  }
}

class PurchaseItem {
  final String? id;
  final String purchaseId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime? expiryDate;
  final String? batchNumber;
  final String? notes;

  PurchaseItem({
    this.id,
    required this.purchaseId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.expiryDate,
    this.batchNumber,
    this.notes,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      purchaseId: json['purchase_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      expiryDate: json['expiry_date'] != null 
          ? DateTime.parse(json['expiry_date']) 
          : null,
      batchNumber: json['batch_number'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'expiry_date': expiryDate?.toIso8601String(),
      'batch_number': batchNumber,
      'notes': notes,
    };
  }

  PurchaseItem copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? expiryDate,
    String? batchNumber,
    String? notes,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      notes: notes ?? this.notes,
    );
  }
}

