import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../../data/models/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool showVisit;
  const ReviewCard({super.key, required this.review, this.showVisit = true});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFF1F1F1),
              backgroundImage: review.user.avatar?.isNotEmpty == true
                  ? CachedNetworkImageProvider(review.user.avatar!)
                  : null,
              child: review.user.avatar?.isNotEmpty == true
                  ? null
                  : const Icon(Icons.person, color: AppColors.textGrey),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.user.name, style: const TextStyle(fontSize: 14)),
                  Text(
                    DateFormat('dd.MM.yyyy').format(review.createdAt.toLocal()),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textLightGrey,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  size: 13,
                  color: index < review.ratings.round()
                      ? AppColors.orangeAccent
                      : const Color(0xFFDDDDDD),
                ),
              ),
            ),
          ],
        ),
        if (showVisit && review.checkIn != null) ...[
          const SizedBox(height: 9),
          Wrap(
            spacing: 10,
            runSpacing: 5,
            children: [
              _meta(
                Icons.calendar_today_outlined,
                DateFormat(
                  'dd.MM.yyyy',
                ).format(review.checkIn!.checkedInAt.toLocal()),
              ),
              _meta(
                Icons.access_time,
                DateFormat(
                  'HH:mm',
                ).format(review.checkIn!.checkedInAt.toLocal()),
              ),
              if (review.dishName?.isNotEmpty == true)
                _meta(Icons.restaurant_menu, review.dishName!),
              _meta(
                Icons.people_outline,
                '${review.checkIn!.partySize} Personen',
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          review.reviewComment,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textGrey,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
  Widget _meta(IconData icon, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: AppColors.primary),
      const SizedBox(width: 4),
      Flexible(child: Text(value, style: const TextStyle(fontSize: 10))),
    ],
  );
}
