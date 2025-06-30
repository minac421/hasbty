import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/sale.dart';
import '../models/purchase.dart';
import '../models/product.dart';
import '../providers/sales_provider.dart';
import '../providers/purchases_provider.dart';
import '../providers/products_provider.dart';
import '../providers/user_provider.dart';
import '../services/feature_manager_service.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _recognizedText = '';
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _transactionType = 'sale'; // Default to sale
  Product? _selectedProduct;

  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'طعام ومشروبات';
  String _paymentMethod = 'نقدي';
  
  final List<String> _categories = [
    'طعام ومشروبات',
    'مواصلات',
    'تسوق',
    'فواتير',
    'ترفيه',
    'صحة',
    'تعليم',
    'أخرى',
  ];
  
  final List<String> _paymentMethods = [
    'نقدي',
    'بطاقة ائتمان',
    'محفظة إلكترونية',
    'تحويل بنكي',
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Set current date
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {});
    }
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also auto-stop mechanisms that will trigger the callback
  /// after a period of silence.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform's speech recognition engine has recognized words.
  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
      // Attempt to parse recognized words into fields
      _parseVoiceInput(_lastWords);
    });
  }

  void _parseVoiceInput(String text) {
    // Simple parsing logic for demonstration
    // Example: "500 جنيه على أحمد لايجار شقة"
    // This part would need more sophisticated NLP for real-world use
    final amountMatch = RegExp(r'\d+').firstMatch(text);
    if (amountMatch != null) {
      _amountController.text = amountMatch.group(0)!;
    }
    // You can add more logic here to extract category, name, etc.
  }

  Future<void> _pickImageAndRecognizeText() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final InputImage inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      _recognizedText = recognizedText.text;
      // You can parse _recognizedText to fill transaction fields
      _notesController.text = _recognizedText; // For now, put all recognized text into notes
      setState(() {});
      textRecognizer.close();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('إضافة مصروف'),
        backgroundColor: AppTheme.cardColor,
        foregroundColor: AppTheme.textDarkColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // المبلغ
              _buildAmountSection(),
              
              const SizedBox(height: 24),
              
              // الوصف
              _buildDescriptionSection(),
              
              const SizedBox(height: 24),
              
              // التصنيف
              _buildCategorySection(),
              
              const SizedBox(height: 24),
              
              // طريقة الدفع
              _buildPaymentMethodSection(),
              
              const SizedBox(height: 32),
              
              // زر الحفظ
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المبلغ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                fontSize: 24,
                color: AppTheme.textLightColor,
              ),
              prefixText: 'EGP ',
              prefixStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDarkColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'من فضلك أدخل المبلغ';
              }
              if (double.tryParse(value) == null) {
                return 'من فضلك أدخل رقم صحيح';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الوصف',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 12),
                     TextFormField(
             controller: _notesController,
             decoration: InputDecoration(
              hintText: 'اكتب وصف المصروف...',
              hintStyle: TextStyle(color: AppTheme.textLightColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.backgroundColor,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'من فضلك أدخل وصف المصروف';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التصنيف',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = category == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textDarkColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'طريقة الدفع',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _paymentMethods.map((method) {
              final isSelected = method == _paymentMethod;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _paymentMethod = method),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getPaymentIcon(method),
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textLightColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          method,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textDarkColor,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: const Text(
        'حفظ المصروف',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'نقدي':
        return Icons.payments_outlined;
      case 'بطاقة ائتمان':
        return Icons.credit_card_outlined;
      case 'محفظة إلكترونية':
        return Icons.account_balance_wallet_outlined;
      case 'تحويل بنكي':
        return Icons.account_balance_outlined;
      default:
        return Icons.payment_outlined;
    }
  }
  
  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // التحقق من حدود المستخدم
    final userPlan = ref.read(userPlanProvider);
    final sales = ref.read(salesProvider);
    
    // حساب عدد المبيعات في الشهر الحالي
    final now = DateTime.now();
    final currentMonthSales = sales.where((sale) {
      return sale.saleDate.year == now.year && sale.saleDate.month == now.month;
    }).length;
    
    // التحقق من الحدود
    final canProceed = FeatureManagerService.limitGate(
      context,
      userPlan,
      'sales_this_month',
      currentMonthSales,
    );
    
    if (!canProceed) return;
    
    // إنشاء المعاملة
    final amount = double.parse(_amountController.text);
    final description = _notesController.text.trim();
    
    final sale = Sale(
      userId: 'demo-user',
      customerId: null,
      customerName: 'مصروف شخصي',
      totalAmount: amount,
      discountAmount: 0,
      taxAmount: 0,
      finalAmount: amount,
      paymentMethod: _paymentMethod,
      status: 'مكتملة',
      notes: '$_selectedCategory - $description',
      saleDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: [
        SaleItem(
          saleId: '',
          productId: 'expense-item',
          productName: description,
          quantity: 1,
          unitPrice: amount,
          totalPrice: amount,
          purchasePrice: amount,
        ),
      ],
    );
    
    // حفظ المعاملة
    ref.read(salesProvider.notifier).addSale(sale);
    
    // إظهار رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ المصروف بنجاح! 💰'),
        backgroundColor: AppTheme.successColor,
        duration: Duration(seconds: 2),
      ),
    );
    
    // العودة للشاشة السابقة
    Navigator.of(context).pop();
  }
}


