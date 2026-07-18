import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/product_model.dart';
import 'package:uuid/uuid.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  String _name = '';
  String _description = '';
  String _category = 'وجبات رئيسية';
  double _price = 0.0;
  double? _discountPrice;
  int _stockQuantity = 0;
  int _lowStockThreshold = 5;
  int _prepTime = 15;
  bool _isAvailable = true;
  bool _isFeatured = false;
  bool _allowCustomerNotes = true;
  
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  List<ProductOptionGroup> _optionGroups = [];
  List<ProductAddOn> _addOns = [];

  final List<String> _categories = ['وجبات رئيسية', 'مشويات', 'سندوتشات', 'بيتزا', 'إضافات', 'المشروبات'];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showAddOptionGroupDialog() {
    String groupName = '';
    bool isRequired = true;
    List<ProductOption> tempOptions = [];
    final uuid = const Uuid();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('إضافة مجموعة خيارات (مثال: الحجم)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'اسم المجموعة (مثال: اختر الحجم)'),
                      onChanged: (v) => groupName = v,
                    ),
                    SwitchListTile(
                      title: const Text('إجباري؟ (يجب أن يختار العميل)'),
                      value: isRequired,
                      onChanged: (v) => setDialogState(() => isRequired = v),
                    ),
                    const Divider(),
                    const Text('الخيارات:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...tempOptions.map((opt) => ListTile(
                      title: Text(opt.name),
                      subtitle: Text('+ ${opt.extraPrice} ج.س'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setDialogState(() => tempOptions.remove(opt)),
                      ),
                    )),
                    ElevatedButton.icon(
                      onPressed: () {
                        String optName = '';
                        double optPrice = 0.0;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('خيار جديد'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(decoration: const InputDecoration(labelText: 'اسم الخيار (مثال: كبير)'), onChanged: (v) => optName = v),
                                TextField(decoration: const InputDecoration(labelText: 'السعر الإضافي'), keyboardType: TextInputType.number, onChanged: (v) => optPrice = double.tryParse(v) ?? 0.0),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                              ElevatedButton(
                                onPressed: () {
                                  if (optName.isNotEmpty) {
                                    setDialogState(() {
                                      tempOptions.add(ProductOption(id: uuid.v4(), name: optName, extraPrice: optPrice));
                                    });
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('إضافة'),
                              )
                            ],
                          )
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة خيار'),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    if (groupName.isNotEmpty && tempOptions.isNotEmpty) {
                      setState(() {
                        _optionGroups.add(ProductOptionGroup(
                          id: uuid.v4(),
                          name: groupName,
                          isRequired: isRequired,
                          options: tempOptions,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('حفظ المجموعة'),
                )
              ],
            );
          }
        );
      }
    );
  }

  void _showAddAddOnDialog() {
    String addOnName = '';
    double addOnPrice = 0.0;
    final uuid = const Uuid();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('إضافة ملحق (مثال: كاتشب)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: const InputDecoration(labelText: 'اسم الملحق'), onChanged: (v) => addOnName = v),
              TextField(decoration: const InputDecoration(labelText: 'السعر الإضافي'), keyboardType: TextInputType.number, onChanged: (v) => addOnPrice = double.tryParse(v) ?? 0.0),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (addOnName.isNotEmpty) {
                  setState(() {
                    _addOns.add(ProductAddOn(id: uuid.v4(), name: addOnName, price: addOnPrice));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('إضافة'),
            )
          ],
        );
      }
    );
  }

  void _saveProduct() async {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState?.save();

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;
    
    final String storeId = 'store_${user.id}';

    final product = ProductModel(
      id: _uuid.v4(),
      storeId: storeId,
      name: _name,
      description: _description,
      image: _imageFile?.path ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=400',
      category: _category,
      price: _price,
      discountPrice: _discountPrice,
      stockQuantity: _stockQuantity,
      lowStockThreshold: _lowStockThreshold,
      preparationTimeMinutes: _prepTime,
      isAvailable: _isAvailable,
      isFeatured: _isFeatured,
      allowCustomerNotes: _allowCustomerNotes,
      optionGroups: _optionGroups,
      addOns: _addOns,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<ProductProvider>().addProduct(product).then((_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ المنتج بنجاح')));
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('إضافة منتج جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('معلومات المنتج الأساسية'),
              _buildCard(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'اسم المنتج *', border: OutlineInputBorder()),
                      validator: (v) => v == null || v.isEmpty ? 'الرجاء إدخال اسم المنتج' : null,
                      onSaved: (v) => _name = v!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'وصف المنتج *', border: OutlineInputBorder()),
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty ? 'الرجاء إدخال وصف المنتج' : null,
                      onSaved: (v) => _description = v!,
                    ),
                  ],
                ),
              ),

              _buildSectionHeader('السعر والمخزون'),
              _buildCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'السعر الأساسي *', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'الرجاء إدخال السعر';
                              if (double.tryParse(v) == null || double.parse(v) <= 0) return 'السعر يجب أن يكون أكبر من صفر';
                              return null;
                            },
                            onSaved: (v) => _price = double.parse(v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'سعر بعد الخصم (اختياري)', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            onSaved: (v) {
                              if (v != null && v.isNotEmpty) {
                                _discountPrice = double.tryParse(v);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'الكمية في المخزون *', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'الرجاء إدخال الكمية' : null,
                            onSaved: (v) => _stockQuantity = int.parse(v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'تنبيه انخفاض المخزون', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            initialValue: '5',
                            onSaved: (v) => _lowStockThreshold = int.parse(v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _buildSectionHeader('الصورة والتصنيف'),
              _buildCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'تصنيف المنتج *', border: OutlineInputBorder()),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _category = v!),
                      onSaved: (v) => _category = v!,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, fit: BoxFit.cover))
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('صورة المنتج', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              _buildSectionHeader('الخيارات والإضافات'),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مجموعات الخيارات الحالية: ${_optionGroups.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._optionGroups.map((group) => Card(
                      color: AppColors.backgroundLight,
                      child: ListTile(
                        title: Text('${group.name} (${group.isRequired ? 'إجباري' : 'اختياري'})'),
                        subtitle: Text('${group.options.length} خيارات'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => _optionGroups.remove(group)),
                        ),
                      ),
                    )),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _showAddOptionGroupDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة مجموعة خيارات (مثال: الحجم)'),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                    Text('الإضافات الحالية: ${_addOns.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _addOns.map((addon) => Chip(
                        label: Text('${addon.name} (+${addon.price} ج.س)'),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() => _addOns.remove(addon)),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _showAddAddOnDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة ملحق (مثال: جبنة)'),
                    ),
                  ],
                ),
              ),

              _buildSectionHeader('الإعدادات'),
              _buildCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('المنتج متاح'),
                      value: _isAvailable,
                      onChanged: (v) => setState(() => _isAvailable = v),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('منتج مميز'),
                      value: _isFeatured,
                      onChanged: (v) => setState(() => _isFeatured = v),
                      activeColor: AppColors.primaryColor,
                    ),
                    SwitchListTile(
                      title: const Text('السماح بملاحظات العميل'),
                      value: _allowCustomerNotes,
                      onChanged: (v) => setState(() => _allowCustomerNotes = v),
                      activeColor: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('حفظ المنتج', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('إلغاء', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
