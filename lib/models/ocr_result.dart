class OCRResult {
  final String rawText;
  final String merchantName;
  final double totalAmount;
  final DateTime? date;
  final List<OCRItem> items;
  final double taxAmount;
  final double confidence;

  OCRResult({
    required this.rawText,
    required this.merchantName,
    required this.totalAmount,
    this.date,
    required this.items,
    required this.taxAmount,
    required this.confidence,
  });

  bool get isValid => confidence > 0.5 && totalAmount > 0;

  Map<String, dynamic> toJson() {
    return {
      'rawText': rawText,
      'merchantName': merchantName,
      'totalAmount': totalAmount,
      'date': date?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'taxAmount': taxAmount,
      'confidence': confidence,
    };
  }

  factory OCRResult.fromJson(Map<String, dynamic> json) {
    return OCRResult(
      rawText: json['rawText'] ?? '',
      merchantName: json['merchantName'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OCRItem.fromJson(item))
          .toList() ?? [],
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class OCRItem {
  final String name;
  final double price;
  final double quantity;
  final double total;

  OCRItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  factory OCRItem.fromJson(Map<String, dynamic> json) {
    return OCRItem(
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: (json['quantity'] ?? 1.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
    );
  }
} 