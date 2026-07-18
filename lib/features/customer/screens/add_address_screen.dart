import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/user_model.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _city = 'الخرطوم'; // Default city
  String _area = '';
  String _street = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _phone = auth.currentUser?.phone ?? '';
  }

  void _saveAddress() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;
    formState.save();

    final auth = context.read<AuthProvider>();
    
    final newAddress = AddressModel(
      id: const Uuid().v4(),
      title: _title,
      city: _city,
      area: _area,
      street: _street,
      landmark: '', // Optional for now
      latitude: 15.5, // Mock lat
      longitude: 32.5, // Mock lng
      phone: _phone,
    );

    try {
      await auth.addSavedAddress(newAddress);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ العنوان بنجاح')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ العنوان: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة عنوان جديد'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'اسم العنوان (مثل: المنزل، العمل)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                onSaved: (val) => _title = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _city,
                decoration: const InputDecoration(
                  labelText: 'المدينة',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                onSaved: (val) => _city = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'المنطقة',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                onSaved: (val) => _area = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'الشارع / الوصف',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                onSaved: (val) => _street = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
                onSaved: (val) => _phone = val!,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('حفظ العنوان', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
