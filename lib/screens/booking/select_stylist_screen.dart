import 'package:flutter/material.dart';
import 'package:barber_app/models/stylist.dart';
import 'package:barber_app/utils/colors.dart';

class SelectStylistScreen extends StatefulWidget {
  final String? salonId; // Có thể truyền salonId để lọc stylist

  const SelectStylistScreen({Key? key, this.salonId}) : super(key: key);

  @override
  State<SelectStylistScreen> createState() => _SelectStylistScreenState();
}

class _SelectStylistScreenState extends State<SelectStylistScreen> {
  // Dữ liệu stylist giả lập. Trong thực tế, bạn sẽ fetch từ API.
  List<Stylist> _availableStylists = [
    Stylist(
      id: 's1',
      name: 'Nguyễn Văn A',
      imageUrl: 'https://via.placeholder.com/150/0000FF/808080?text=StylistA',
      bio: 'Chuyên gia tạo mẫu tóc nam hiện đại.',
      salonId: 'salon1',
    ),
    Stylist(
      id: 's2',
      name: 'Trần Thị B',
      imageUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=StylistB',
      bio: 'Tay kéo vàng trong làng cắt tóc nữ.',
      salonId: 'salon1',
    ),
    Stylist(
      id: 's3',
      name: 'Lê Văn C',
      imageUrl: 'https://via.placeholder.com/150/008000/FFFFFF?text=StylistC',
      bio: 'Chuyên tạo kiểu tóc bồng bềnh và uốn.',
      salonId: 'salon2',
    ),
    Stylist(
      id: 's4',
      name: 'Phạm Thị D',
      imageUrl: 'https://via.placeholder.com/150/FFFF00/000000?text=StylistD',
      bio: 'Tư vấn kiểu tóc hợp khuôn mặt và phong cách.',
      salonId: 'salon2',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Lọc stylist nếu có salonId được truyền vào
    if (widget.salonId != null) {
      _availableStylists =
          _availableStylists.where((s) => s.salonId == widget.salonId).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chọn Stylist',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.secondaryWhite,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.secondaryWhite,
      body:
          _availableStylists.isEmpty
              ? const Center(
                child: Text(
                  'Không có stylist nào tại salon này hoặc chưa chọn salon.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _availableStylists.length,
                itemBuilder: (context, index) {
                  final stylist = _availableStylists[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(
                          context,
                          stylist,
                        ); // Trả về stylist đã chọn
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  stylist.imageUrl != null
                                      ? NetworkImage(stylist.imageUrl!)
                                      : null,
                              child:
                                  stylist.imageUrl == null
                                      ? const Icon(Icons.person, size: 30)
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stylist.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDarkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (stylist.bio != null)
                                    Text(
                                      stylist.bio!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.secondaryGrey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
