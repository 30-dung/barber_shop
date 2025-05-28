import 'package:flutter/material.dart';
import 'package:barber_app/models/salon.dart';
import 'package:barber_app/services/api_service.dart';
import 'package:barber_app/utils/colors.dart';

class SelectSalonScreen extends StatefulWidget {
  const SelectSalonScreen({Key? key}) : super(key: key);

  @override
  State<SelectSalonScreen> createState() => _SelectSalonScreenState();
}

class _SelectSalonScreenState extends State<SelectSalonScreen> {
  final ApiService _apiService = ApiService();
  List<Salon> _salons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSalons();
  }

  Future<void> _loadSalons() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _salons = await _apiService.getSalons();
    } catch (e) {
      // Handle error, e.g., show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách salon: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Salon'),
        backgroundColor: AppColors.primaryDarkBlue,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _salons.isEmpty
              ? const Center(child: Text('Không có salon nào để hiển thị.'))
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _salons.length,
                itemBuilder: (context, index) {
                  final salon = _salons[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, salon); // Trả về salon đã chọn
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                salon.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 80,
                                      height: 80,
                                      color: AppColors.lightGrey,
                                      child: const Icon(
                                        Icons.store,
                                        size: 40,
                                        color: AppColors.secondaryGrey,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    salon.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDarkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    salon.address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.secondaryGrey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${salon.rating} (${salon.reviewCount} đánh giá)',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.secondaryGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.secondaryGrey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
