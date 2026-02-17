import 'package:flutter/material.dart'; // Fixed url_launcher crash
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/cart_service.dart';
import '../services/api_service.dart';
import '../models/cart_item_model.dart';


class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = CartService();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(Platform.isIOS ? 'My Selections' : 'Shopping Cart', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              cartService.clearCart();
            },
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: cartService,
        builder: (context, child) {
          if (cartService.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Cart is Empty',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start adding photos to see them here.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartService.items.length,
                  itemBuilder: (context, index) {
                    final item = cartService.items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.image.url, width: 60, height: 60, fit: BoxFit.cover),
                        ),
                        title: Text(item.variation.name, 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    subtitle: Platform.isIOS 
                                      ? (item.variation.name.toLowerCase().contains('custom') 
                                          ? const Text('Price on request', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13))
                                          : null)
                                      : Text('${item.variation.price} KWD', style: const TextStyle(color: Color(0xFFFF1744))),

                                    trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                          onPressed: () {
                            cartService.removeFromCart(item);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Checkout Bar (Moved from bottomNavigationBar to here)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!Platform.isIOS)
                      Text(
                        'Total: ${cartService.total} KWD',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ElevatedButton(
                      onPressed: () => _checkout(context, cartService),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        Platform.isIOS ? 'Request Quote' : 'Checkout',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              // Extra padding for Main Navigation Bar
              const SizedBox(height: 90),
            ],
          );
        },
      ),
    );
  }

  void _checkout(BuildContext context, CartService cartService) {
    showDialog(
      context: context,
      builder: (context) => CheckoutDialog(
        onConfirm: (name, email, phone, coupon) => _processPayment(context, cartService, name, email, phone, coupon),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, CartService cartService, String name, String email, String phone, String coupon) async {
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF))),
    );

    try {
      // Prepare Items
      final items = cartService.items.map((item) => {
        'product_id': 0, // Not needed if using variation_id as main ID
        'variation_id': int.parse(item.variation.id),
        'quantity': 1,
        'meta_data': [
          {
            'key': 'Image ID',
            'value': item.image.id,
            'display_key': 'Image ID',
            'display_value': item.image.id,
          },
          {
            'key': 'Image URL',
            'value': item.image.url,
            'display_key': 'Image Link',
            'display_value': item.image.url,
          },
          {
            'key': 'Image Title',
            'value': item.image.title,
            'display_key': 'Image Title',
            'display_value': item.image.title,
          },
        ]
      }).toList();

      final customerDetails = {
        'name': name,
        'email': email,
        'phone': phone,
      };

      // Call API
      final paymentUrl = await ApiService().createOrder(items, customerDetails, coupon: coupon);

      // Close Loading
      if (context.mounted) Navigator.pop(context);

      if (Platform.isIOS) {
        // Show Success Dialog for iOS (Request Quote flow)
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Inquiry Sent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: const Text(
                'Your selection has been sent! We will contact you soon with printing options and pricing.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(color: Color(0xFF00E5FF))),
                ),
              ],
            ),
          );
          cartService.clearCart();
        }
      } else {
        // Launch Payment URL for other platforms
        final uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
          cartService.clearCart();
        } else {
          throw 'Could not launch payment URL';
        }
      }
    } catch (e) {
      // Close Loading
      if (context.mounted) Navigator.pop(context);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class CheckoutDialog extends StatefulWidget {
  final Function(String name, String email, String phone, String coupon) onConfirm;

  const CheckoutDialog({super.key, required this.onConfirm});

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'App User');
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _couponController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Complete Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(_emailController, 'Email Address', Icons.email, isEmail: true),
              const SizedBox(height: 12),
              _buildField(_phoneController, 'Phone Number', Icons.phone, isPhone: true),
              const SizedBox(height: 12),
              _buildField(_couponController, 'Coupon Code (Optional)', Icons.local_offer, isOptional: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF)),
          onPressed: _isLoading ? null : () async {
            if (_formKey.currentState!.validate()) {
              setState(() => _isLoading = true);
              try {
                // Pass Data to Parent
                await widget.onConfirm('App User', _emailController.text, _phoneController.text, _couponController.text);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) setState(() => _isLoading = false);
              }
            }
          },
          child: _isLoading 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : Text(Platform.isIOS ? 'Send Request' : 'Pay Now', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool isEmail = false, bool isPhone = false, bool isOptional = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isEmail ? TextInputType.emailAddress : (isPhone ? TextInputType.phone : TextInputType.text),
      validator: (value) {
        if (isOptional) return null; // No validation for optional fields
        if (value == null || value.isEmpty) return 'Required';
        if (isEmail && !value.contains('@')) return 'Invalid Email';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: const Color(0xFF00E5FF)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF00E5FF))),
      ),
    );
  }
}
