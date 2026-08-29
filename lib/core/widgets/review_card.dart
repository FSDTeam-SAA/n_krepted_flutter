import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../../data/models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Stars & Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: review.user.avatar != null
                    ? CachedNetworkImageProvider(review.user.avatar!)
                    : const CachedNetworkImageProvider(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat(
                        'dd.MM.yyyy',
                      ).format(review.createdAt.toLocal()),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.ratings.floor()
                        ? Icons.star
                        : Icons.star_border,
                    size: 15,
                    color: AppColors.orangeAccent,
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Metadata Tag Row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMetaTag(
                Icons.calendar_today,
                DateFormat('dd.MM.yyyy').format(
                  (review.checkIn?.checkedInAt ?? review.createdAt).toLocal(),
                ),
              ),
              _buildMetaTag(
                Icons.access_time,
                '${DateFormat('HH:mm').format((review.checkIn?.checkedInAt ?? review.createdAt).toLocal())} Uhr',
              ),
              if (review.dishName != null)
                _buildMetaTag(Icons.restaurant_menu, review.dishName!),
              _buildMetaTag(
                Icons.people,
                '${review.checkIn?.partySize ?? 1} Personen',
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Comment Body + Optional Dish Photo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  review.reviewComment,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textBody,
                    height: 1.4,
                  ),
                ),
              ),
              if (review.dishImage != null) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: review.dishImage!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.primary),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
