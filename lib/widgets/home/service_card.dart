import 'package:flutter/material.dart';
import 'package:barber_app/utils/colors.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool hasHotline;

  const ServiceCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.hasHotline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGrey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      hasHotline
                          ? [
                            AppColors.primaryDarkBlue,
                            AppColors.secondaryDarkBlue,
                          ]
                          : [AppColors.lightGrey, AppColors.secondaryGrey],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            if (hasHotline)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hotline',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDarkBlue,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.phone,
                        size: 8,
                        color: AppColors.primaryDarkBlue,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: hasHotline ? AppColors.secondaryWhite : Colors.black,
                ),
              ),
            ),
            if (title.contains('Uốn'))
              const Positioned(
                top: 8,
                left: 8,
                child: Icon(Icons.circle, color: Colors.red, size: 8),
              ),
          ],
        ),
      ),
    );
  }
}
