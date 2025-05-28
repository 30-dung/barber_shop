import 'package:flutter/material.dart';
import 'package:barber_app/models/service.dart';
import 'package:barber_app/utils/colors.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Service> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      setState(() {
        services = [
          Service(
            id: 1,
            name: 'Cắt tóc nam',
            description: 'Cắt tóc theo phong cách hiện đại',
            price: 50000,
            duration: 30,
            imageUrl: '',
          ),
          Service(
            id: 2,
            name: 'Gội đầu massage',
            description: 'Gội đầu thư giãn với tinh dầu thảo mộc',
            price: 30000,
            duration: 20,
            imageUrl: '',
          ),
          Service(
            id: 3,
            name: 'Nhuộm tóc',
            description: 'Nhuộm tóc màu thời trang',
            price: 200000,
            duration: 120,
            imageUrl: '',
          ),
          Service(
            id: 4,
            name: 'Uốn tóc',
            description: 'Uốn tóc xoăn tự nhiên',
            price: 150000,
            duration: 90,
            imageUrl: '',
          ),
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dịch vụ')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryOrange,
                        child: Icon(
                          Icons.content_cut,
                          color: AppColors.secondaryWhite,
                        ),
                      ),
                      title: Text(
                        service.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.description),
                          const SizedBox(height: 4),
                          Text(
                            '${service.price.toStringAsFixed(0)}đ - ${service.duration} phút',
                            style: const TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/booking');
                        },
                        child: const Text('Đặt lịch'),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
