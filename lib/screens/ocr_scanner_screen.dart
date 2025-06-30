import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

import '../services/ocr_service.dart';
import '../services/auto_classification_service.dart';
import '../models/ocr_result.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/animated_widgets.dart';

class OCRScannerScreen extends ConsumerStatefulWidget {
  const OCRScannerScreen({super.key});

  @override
  ConsumerState<OCRScannerScreen> createState() => _OCRScannerScreenState();
}

class _OCRScannerScreenState extends ConsumerState<OCRScannerScreen>
    with TickerProviderStateMixin {
  File? _selectedImage;
  XFile? _selectedXFile; // للويب والموبايل
  OCRResult? _ocrResult;
  bool _isProcessing = false;
  String? _errorMessage;
  
  // التصنيف التلقائي
  String? _suggestedCategory;
  List<String> _categoryOptions = [];
  String _selectedTransactionType = 'expense'; // expense أو income

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        setState(() {
          _selectedXFile = image;
          _selectedImage = kIsWeb ? null : File(image.path);
          _ocrResult = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في اختيار الصورة: $e';
      });
    }
  }

  Future<void> _processImage() async {
    if (kIsWeb ? _selectedXFile == null : _selectedImage == null) return;

    // التحقق من الحدود أولاً
    final userNotifier = ref.read(userProvider.notifier);
    final canUse = await userNotifier.useOCR(context);
    
    if (!canUse) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      OCRResult result;
      if (kIsWeb && _selectedXFile != null) {
        // للويب - معالجة الخطأ بطريقة مختلفة
        throw Exception('OCR غير مدعوم في الويب حالياً. يرجى استخدام التطبيق على الهاتف.');
      } else if (_selectedImage != null) {
        // للموبايل - استخدام File
        result = await OCRService.extractTextFromImage(_selectedImage!);
      } else {
        throw Exception('لا توجد صورة محددة');
      }
      
      // التصنيف التلقائي للمعاملة
      final suggestedCategory = AutoClassificationService.classifyTransaction(
        description: result.rawText,
        type: _selectedTransactionType,
        merchantName: result.merchantName,
        amount: result.totalAmount,
      );
      
      final categoryOptions = AutoClassificationService.suggestCategories(
        description: result.rawText,
        type: _selectedTransactionType,
        merchantName: result.merchantName,
      );

      setState(() {
        _ocrResult = result;
        _suggestedCategory = suggestedCategory;
        _categoryOptions = categoryOptions;
        _isProcessing = false;
      });

      _showSuccessMessage();
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'خطأ في معالجة الصورة: $e';
      });
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('تم استخراج النص بنجاح!'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _resetAll() {
    setState(() {
      _selectedImage = null;
      _selectedXFile = null;
      _ocrResult = null;
      _errorMessage = null;
      _suggestedCategory = null;
      _categoryOptions.clear();
      _selectedTransactionType = 'expense';
    });
  }

  void _updateTransactionType(String newType) {
    setState(() {
      _selectedTransactionType = newType;
    });
    
    // إعادة حساب التصنيف عند تغيير النوع
    if (_ocrResult != null) {
      final suggestedCategory = AutoClassificationService.classifyTransaction(
        description: _ocrResult!.rawText,
        type: _selectedTransactionType,
        merchantName: _ocrResult!.merchantName,
        amount: _ocrResult!.totalAmount,
      );
      
      final categoryOptions = AutoClassificationService.suggestCategories(
        description: _ocrResult!.rawText,
        type: _selectedTransactionType,
        merchantName: _ocrResult!.merchantName,
      );

      setState(() {
        _suggestedCategory = suggestedCategory;
        _categoryOptions = categoryOptions;
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'اختر مصدر الصورة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.camera_alt,
                    label: 'الكاميرا',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildSourceOption(
                    icon: Icons.photo_library,
                    label: 'المعرض',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final ocrUsage = userState.currentPlan?.currentUsage['ocr_this_month'] ?? 0;
    final ocrLimit = userState.currentPlan?.getLimit('ocr_per_month') ?? 0;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('مسح الفواتير'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if ((kIsWeb ? _selectedXFile != null : _selectedImage != null) || _ocrResult != null)
            IconButton(
              icon: Icon(Icons.refresh_rounded),
              onPressed: _resetAll,
              tooltip: 'بدء من جديد',
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Usage indicator
          _buildUsageIndicator(),
          SizedBox(height: 20),
          
          // Main content
          if ((kIsWeb ? _selectedXFile == null : _selectedImage == null) && _ocrResult == null)
            _buildWelcomeSection()
          else if ((kIsWeb ? _selectedXFile != null : _selectedImage != null) && _ocrResult == null)
            _buildImagePreviewSection()
          else if (_ocrResult != null)
            _buildResultSection(),
          
          SizedBox(height: 20),
          
          // Error message
          if (_errorMessage != null)
            _buildErrorMessage(),
          
          SizedBox(height: 20),
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUsageIndicator() {
    final userState = ref.watch(userProvider);
    final ocrUsage = userState.currentPlan?.currentUsage['ocr_this_month'] ?? 0;
    final ocrLimit = userState.currentPlan?.getLimit('ocr_per_month') ?? 0;
    
    if (ocrLimit == -1) return SizedBox.shrink(); // Unlimited
    
    final percentage = ocrLimit > 0 ? (ocrUsage / ocrLimit) : 0.0;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'استخدام OCR هذا الشهر',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '$ocrUsage / $ocrLimit',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 0.8 ? AppTheme.warningColor : AppTheme.primaryColor,
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.document_scanner_rounded,
            size: 80,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 30),
        Text(
          'مسح الفواتير الذكي',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'التقط صورة لأي فاتورة وسنستخرج جميع البيانات تلقائياً',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textLightColor,
            height: 1.5,
          ),
        ),
        SizedBox(height: 30),
        _buildFeaturesList(),
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.language, 'text': 'يدعم العربية والإنجليزية'},
      {'icon': Icons.flash_on, 'text': 'استخراج سريع ودقيق'},
      {'icon': Icons.auto_awesome, 'text': 'تصنيف تلقائي ذكي للمعاملات'},
      {'icon': Icons.edit, 'text': 'إمكانية التعديل والمراجعة'},
      {'icon': Icons.save, 'text': 'حفظ تلقائي للبيانات'},
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  size: 20,
                  color: AppTheme.successColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  feature['text'] as String,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImagePreviewSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: kIsWeb && _selectedXFile != null
                ? FutureBuilder<Uint8List>(
                    future: _selectedXFile!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.error, size: 50),
                        );
                      } else {
                        return Container(
                          color: Colors.grey[300],
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  )
                : _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 50),
                      ),
          ),
        ),
        SizedBox(height: 20),
        if (_isProcessing)
          _buildProcessingIndicator()
        else
          Text(
            'الصورة جاهزة للمعالجة',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'جاري معالجة الصورة...',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يرجى الانتظار بينما نستخرج البيانات',
            style: TextStyle(
              color: AppTheme.textLightColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.successColor,
                size: 32,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تم استخراج البيانات بنجاح!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.successColor,
                      ),
                    ),
                    Text(
                      'مستوى الثقة: ${(_ocrResult!.confidence * 100).toInt()}%',
                      style: TextStyle(
                        color: AppTheme.textLightColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 20),
        
        // Extracted data
        _buildDataCard('اسم المحل', _ocrResult!.merchantName),
        _buildDataCard('المبلغ الإجمالي', '${_ocrResult!.totalAmount} جنيه'),
        if (_ocrResult!.taxAmount > 0)
          _buildDataCard('الضريبة', '${_ocrResult!.taxAmount} جنيه'),
        _buildDataCard('التاريخ', _ocrResult!.date?.toString().split(' ')[0] ?? 'غير محدد'),
        
        SizedBox(height: 20),
        
        // قسم التصنيف التلقائي
        _buildAutoClassificationSection(),
        
        SizedBox(height: 20),
        
        // Raw text
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'النص المستخرج:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _ocrResult!.rawText,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textLightColor,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoClassificationSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.1), AppTheme.primaryColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '🤖 التصنيف التلقائي الذكي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // نوع المعاملة
          Text(
            'نوع المعاملة:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            children: [
                             Expanded(
                 child: GestureDetector(
                   onTap: () => _updateTransactionType('expense'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedTransactionType == 'expense' 
                          ? AppTheme.warningColor 
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedTransactionType == 'expense' 
                            ? AppTheme.warningColor 
                            : AppTheme.borderColor,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_down,
                          color: _selectedTransactionType == 'expense' 
                              ? Colors.white 
                              : AppTheme.warningColor,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'مصروف',
                          style: TextStyle(
                            color: _selectedTransactionType == 'expense' 
                                ? Colors.white 
                                : AppTheme.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
                             Expanded(
                 child: GestureDetector(
                   onTap: () => _updateTransactionType('income'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedTransactionType == 'income' 
                          ? AppTheme.successColor 
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedTransactionType == 'income' 
                            ? AppTheme.successColor 
                            : AppTheme.borderColor,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: _selectedTransactionType == 'income' 
                              ? Colors.white 
                              : AppTheme.successColor,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'دخل',
                          style: TextStyle(
                            color: _selectedTransactionType == 'income' 
                                ? Colors.white 
                                : AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // التصنيف المقترح
          if (_suggestedCategory != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, color: AppTheme.successColor, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'التصنيف المقترح:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _suggestedCategory!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // اقتراحات أخرى
          if (_categoryOptions.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              'اقتراحات أخرى:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categoryOptions.take(4).map((category) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isProcessing) return SizedBox.shrink();
    
    if (kIsWeb ? _selectedXFile == null : _selectedImage == null) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _showImageSourceDialog,
          icon: Icon(Icons.camera_alt_rounded),
          label: Text('التقاط صورة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    
    if (_ocrResult == null) {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _processImage,
          icon: Icon(Icons.psychology_rounded),
          label: Text('معالجة الصورة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetAll,
            icon: Icon(Icons.refresh_rounded),
            label: Text('مسح جديد'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: حفظ البيانات
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حفظ البيانات!')),
              );
            },
            icon: Icon(Icons.save_rounded),
            label: Text('حفظ البيانات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
} 