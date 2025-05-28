import 'package:flutter/material.dart';
import 'package:barber_app/models/product.dart';
import 'package:barber_app/utils/colors.dart';

class CartScreen extends StatelessWidget {
  final List<Product> cartProducts;
  final Map<int, int> quantities;

  const CartScreen({
    Key? key,
    required this.cartProducts,
    required this.quantities,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    return '${amount.toInt().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND';
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (var product in cartProducts) {
      total += product.price * (quantities[product.id] ?? 1);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: AppColors.primaryDarkBlue,
      ),
      body:
          cartProducts.isEmpty
              ? const Center(child: Text('Giỏ hàng trống'))
              : ListView.builder(
                itemCount: cartProducts.length,
                itemBuilder: (context, index) {
                  final product = cartProducts[index];
                  final quantity = quantities[product.id] ?? 1;
                  return ListTile(
                    leading: Image.network(
                      product.imageUrl,
                      width: 50,
                      height: 50,
                    ),
                    title: Text(product.name),
                    subtitle: Text(
                      '${_formatCurrency(product.price.toDouble())} x $quantity',
                    ),
                    trailing: Text(
                      _formatCurrency(product.price * quantity.toDouble()),
                    ),
                  );
                },
              ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.primaryDarkBlue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tổng cộng:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              _formatCurrency(total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
