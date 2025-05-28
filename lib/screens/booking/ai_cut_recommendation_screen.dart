import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Cần thêm dependency này
import 'dart:io'; // Để làm việc với File
import 'package:barber_app/utils/colors.dart';

class AICutRecommendationScreen extends StatefulWidget {
  const AICutRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<AICutRecommendationScreen> createState() =>
      _AICutRecommendationScreenState();
}

class _AICutRecommendationScreenState extends State<AICutRecommendationScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  String _recommendation =
      "Hãy chụp ảnh hoặc chọn từ thư viện để nhận gợi ý kiểu tóc!";

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _recommendation = "Đang phân tích hình ảnh của bạn...";
        _analyzeImage(_image!); // Gọi hàm phân tích ảnh
      } else {
        _recommendation = "Không có hình ảnh nào được chọn.";
      }
    });
  }

  // Đây là nơi bạn sẽ tích hợp logic AI thực tế
  void _analyzeImage(File image) async {
    // --- START: Logic AI placeholder ---
    // Trong thực tế, bạn sẽ:
    // 1. Load mô hình ML (ví dụ: TensorFlow Lite model).
    // 2. Tiền xử lý ảnh (resize, normalize pixel values).
    // 3. Chạy inference trên mô hình để nhận diện khuôn mặt, phân tích đặc điểm.
    // 4. Dựa trên kết quả, đưa ra gợi ý kiểu tóc phù hợp.

    // Giả lập thời gian phân tích
    await Future.delayed(const Duration(seconds: 3));

    // Giả lập kết quả phân tích
    List<String> mockRecommendations = [
      "Khuôn mặt bạn phù hợp với kiểu tóc undercut kết hợp fade.",
      "Bạn nên thử kiểu tóc layer dài để tôn lên đường nét.",
      "Kiểu tóc xoăn nhẹ sẽ rất hợp với phong cách của bạn.",
      "Tóc buzz cut sẽ làm nổi bật xương quai hàm của bạn.",
      "Thử kiểu tóc bob ngắn để trông năng động và cá tính hơn.",
    ];

    setState(() {
      _recommendation =
          mockRecommendations[DateTime.now().second %
              mockRecommendations.length];
    });
    // --- END: Logic AI placeholder ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gợi ý kiểu tóc bằng AI',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDarkBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _recommendation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkBlue,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child:
                  _image == null
                      ? Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondaryGrey,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.image,
                          size: 80,
                          color: AppColors.secondaryGrey,
                        ),
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.8,
                          fit: BoxFit.cover,
                        ),
                      ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Chụp ảnh mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn ảnh từ thư viện'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Lưu ý: Để nhận được gợi ý chính xác nhất, vui lòng chụp ảnh khuôn mặt chính diện, đủ ánh sáng và không bị che khuất.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.secondaryGrey),
            ),
          ],
        ),
      ),
    );
  }
}
