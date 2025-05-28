import 'package:flutter/material.dart';
import 'package:barber_app/utils/colors.dart';
import 'package:barber_app/widgets/home/quick_action_card.dart';
import 'package:barber_app/widgets/home/service_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with account info
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.secondaryWhite,
                              child: Icon(
                                Icons.person,
                                color: AppColors.primaryDarkBlue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Chưa có hàng thành viên',
                                  style: TextStyle(
                                    color: AppColors.secondaryWhite,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Đăng ký ngay',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white70,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.shopping_cart_outlined,
                                color: AppColors.secondaryWhite,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.secondaryWhite,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryWhite.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondaryWhite.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.visibility_off,
                            color: AppColors.secondaryWhite,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Tài khoản: ****',
                            style: TextStyle(
                              color: AppColors.secondaryWhite,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryWhite.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.remove_red_eye,
                                  color: AppColors.secondaryWhite,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.secondaryWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          QuickActionCard(
                            icon: Icons.card_giftcard,
                            label: 'Ưu đãi',
                            color: AppColors.accentBlue,
                          ),
                          QuickActionCard(
                            icon: Icons.verified_user,
                            label: 'Cam kết 30Shine',
                            color: AppColors.accentGreen,
                          ),
                          QuickActionCard(
                            icon: Icons.language,
                            label: 'Hệ thống Salon',
                            color: AppColors.primaryOrange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accentBlue.withOpacity(0.1),
                              AppColors.accentBlue.withOpacity(0.2),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                'https://via.placeholder.com/50',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'MỜI ANH ĐÁNH GIÁ CHẤT LƯỢNG',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                  const Text(
                                    'DỊCH VỤ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Phản hồi của anh sẽ giúp chúng em cải thiện chất lượng dịch vụ tốt hơn',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => const Icon(
                                        Icons.star,
                                        color: AppColors.accentAmber,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.thumb_up,
                              color: AppColors.accentBlue,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryDarkBlue,
                              AppColors.secondaryDarkBlue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryWhite,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '30SHINE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDarkBlue,
                                  ),
                                ),
                              ),
                            ),
                            const Positioned(
                              left: 16,
                              top: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ƯỚN NHUỘM THIẾT KẾ',
                                    style: TextStyle(
                                      color: AppColors.secondaryWhite,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'PHỤC HỒI CHUYÊN SÂU',
                                    style: TextStyle(
                                      color: AppColors.secondaryWhite,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'LIPID BOND 2025',
                                    style: TextStyle(
                                      color: AppColors.accentAmber,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(12),
                                ),
                                child: Container(
                                  width: 120,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.secondaryWhite.withOpacity(
                                          0.1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'DỊCH VỤ TÓC',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ServiceCard(
                              title: 'Cắt\ntóc',
                              imageUrl:
                                  'https://via.placeholder.com/100x80/FF6B6B/FFFFFF?text=Cut',
                              hasHotline: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ServiceCard(
                              title: 'Uốn\ngọn sóng',
                              imageUrl:
                                  'https://via.placeholder.com/100x80/4ECDC4/FFFFFF?text=Wave',
                              hasHotline: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ServiceCard(
                              title: 'Hotline\nmáu tóc',
                              imageUrl:
                                  'https://via.placeholder.com/100x80/45B7D1/FFFFFF?text=Color',
                              hasHotline: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
