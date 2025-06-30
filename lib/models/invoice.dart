class Invoice {
  final String? id;
  final String userId;
  final String type; // 'sale' أو 'purchase'
  final String? customerId;
  final String? customerName;
  final String? supplierId;
  final String? supplierName;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final double subtotal;
  final double? discount;
  final double? tax;
  final double totalAmount;
  final String status; // 'paid', 'pending', 'overdue', 'cancelled'
  final String paymentMethod;
  final String? notes;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceItem> items;

  Invoice({
    this.id,
    required this.userId,
    required this.type,
    this.customerId,
    this.customerName,
    this.supplierId,
    this.supplierName,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.subtotal,
    this.discount,
    this.tax,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.notes,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  Invoice copyWith({
    String? id,
    String? userId,
    String? type,
    String? customerId,
    String? customerName,
    String? supplierId,
    String? supplierName,
    String? invoiceNumber,
    DateTime? invoiceDate,
    double? subtotal,
    double? discount,
    double? tax,
    double? totalAmount,
    String? status,
    String? paymentMethod,
    String? notes,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  // Getters للراحة
  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue' || (dueDate != null && DateTime.now().isAfter(dueDate!));
  bool get isSale => type == 'sale';
  bool get isPurchase => type == 'purchase';
  
  double get discountAmount => discount ?? 0.0;
  double get taxAmount => tax ?? 0.0;
  double get finalAmount => subtotal - discountAmount + taxAmount;
  
  String get displayTitle => isSale ? 'فاتورة بيع' : 'فاتورة شراء';
  String get clientName => isSale ? (customerName ?? 'عميل نقدي') : (supplierName ?? 'مورد غير محدد');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'customer_id': customerId,
      'customer_name': customerName,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total_amount': totalAmount,
      'status': status,
      'payment_method': paymentMethod,
      'notes': notes,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      invoiceNumber: json['invoice_number'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: json['discount'] != null ? (json['discount'] as num).toDouble() : null,
      tax: json['tax'] != null ? (json['tax'] as num).toDouble() : null,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'],
      paymentMethod: json['payment_method'],
      notes: json['notes'],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
    );
  }
}

class InvoiceItem {
  final String? id;
  final String invoiceId;
  final String? productId;
  final String itemName;
  final String? description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    this.productId,
    required this.itemName,
    this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    String? productId,
    String? itemName,
    String? description,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'item_name': itemName,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'],
      invoiceId: json['invoice_id'],
      productId: json['product_id'],
      itemName: json['item_name'],
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }
} 