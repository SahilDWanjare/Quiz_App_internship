import 'package:flutter/material.dart';
import '../../domain/entity/subscription_plan.dart';

// --- Professional Palette ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color labelText = Color(0xFF8A9099);
  static const Color gold = Color(0xFFD4AF37);
  static const Color bronze = Color(0xFFCD7F32);
  // Silver plan now uses green shade
  static const Color silver = Color(0xFF2E7D32); // Green shade
  static const Color silverLight = Color(0xFF4CAF50); // Lighter green
}

class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final bool isIndia;
  final VoidCallback onTap;

  const PlanCard({
    Key? key,
    required this.plan,
    required this. isSelected,
    required this. isIndia,
    required this.onTap,
  }) : super(key: key);

  Color _getTierColor(String tier) {
    switch (tier. toUpperCase()) {
      case 'FREE':
        return AppColors.secondaryText;
      case 'BRONZE':
        return AppColors.bronze;
      case 'SILVER':
        return AppColors.silver; // Now green
      case 'GOLD':
        return AppColors.gold;
      default:
        return AppColors.accentTeal;
    }
  }

  Color _getTierBackgroundColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'FREE':
        return AppColors.secondaryText. withOpacity(0.08);
      case 'BRONZE':
        return AppColors.bronze.withOpacity(0.08);
      case 'SILVER':
        return const Color(0xFFE8F5E9); // Light green background
      case 'GOLD':
        return AppColors.gold.withOpacity(0.08);
      default:
        return AppColors.accentTeal.withOpacity(0.08);
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier.toUpperCase()) {
      case 'FREE':
        return Icons.card_giftcard_rounded;
      case 'BRONZE':
        return Icons.workspace_premium_outlined;
      case 'SILVER':
        return Icons.workspace_premium_rounded;
      case 'GOLD':
        return Icons.diamond_rounded;
      default:
        return Icons.card_membership_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(plan. tier);
    final tierBgColor = _getTierBackgroundColor(plan.tier);
    final price = plan.getDisplayPrice(isIndia);
    final isFree = plan.priceINR == 0;
    final isSilver = plan.tier. toUpperCase() == 'SILVER';
    final hasBadge = plan.isPopular || plan.isBestValue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? tierBgColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? tierColor : AppColors. silverBorder,
            width:  isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: tierColor.withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row - Plan Info & Badges/Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Icon and Plan Info
                Expanded(
                  child: Row(
                    crossAxisAlignment:  CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSilver
                              ? const Color(0xFFC8E6C9) // Light green
                              : tierColor. withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTierIcon(plan.tier),
                          color: tierColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(height:  4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSilver
                                        ?  tierColor
                                        : tierColor.withOpacity(0.15),
                                    borderRadius:  BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    plan.tier,
                                    style: TextStyle(
                                      fontSize:  10,
                                      fontWeight: FontWeight.w700,
                                      color: isSilver ? Colors.white :  tierColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  plan. durationText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.labelText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right side - Badge and Price (stacked vertically)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Badge (if any)
                    if (hasBadge) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: plan.isPopular
                              ? AppColors.accentTeal
                              : AppColors.silver, // Green for best value
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: (plan.isPopular
                                  ? AppColors.accentTeal
                                  : AppColors. silver)
                                  .withOpacity(0.3),
                              blurRadius:  6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child:  Text(
                          plan.isPopular ? 'POPULAR' :  'BEST VALUE',
                          style: const TextStyle(
                            fontSize:  9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Space between badge and price
                    ],
                    // Price
                    Text(
                      price,
                      style:  TextStyle(
                        fontSize:  26,
                        fontWeight: FontWeight.bold,
                        color: tierColor,
                      ),
                    ),
                    if (! isFree)
                      Text(
                        isIndia ? 'INR' : 'USD',
                        style: const TextStyle(
                          fontSize:  11,
                          color: AppColors.labelText,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            if (plan.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),

            // Features List
            ... plan.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isSilver
                            ? const Color(0xFFC8E6C9)
                            : tierColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: tierColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            // Selection Indicator
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: tierColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment:  MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'SELECTED',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Compact version for list view
class CompactPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final bool isCurrentPlan;
  final bool isIndia;
  final VoidCallback onTap;

  const CompactPlanCard({
    Key? key,
    required this.plan,
    required this.isSelected,
    required this.isCurrentPlan,
    required this.isIndia,
    required this.onTap,
  }) : super(key: key);

  Color _getTierColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'FREE':
        return AppColors.secondaryText;
      case 'BRONZE':
        return AppColors. bronze;
      case 'SILVER':
        return AppColors. silver; // Green
      case 'GOLD':
        return AppColors.gold;
      default:
        return AppColors.accentTeal;
    }
  }

  IconData _getTierIcon(String tier) {
    switch (tier. toUpperCase()) {
      case 'FREE':
        return Icons.card_giftcard_rounded;
      case 'BRONZE':
        return Icons.workspace_premium_outlined;
      case 'SILVER':
        return Icons.workspace_premium_rounded;
      case 'GOLD':
        return Icons.diamond_rounded;
      default:
        return Icons.card_membership_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierColor = _getTierColor(plan. tier);
    final price = plan.getDisplayPrice(isIndia);
    final isSilver = plan.tier.toUpperCase() == 'SILVER';
    final hasBadge = plan.isPopular || plan.isBestValue;

    return GestureDetector(
      onTap: isCurrentPlan ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets. all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isSilver
              ? const Color(0xFFE8F5E9)
              : tierColor.withOpacity(0.08))
              : isCurrentPlan
              ? AppColors.lightGray
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? tierColor
                : isCurrentPlan
                ? Colors.green. shade400
                : AppColors.silverBorder,
            width: isSelected || isCurrentPlan ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding:  const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSilver
                    ? const Color(0xFFC8E6C9)
                    : tierColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Icon(
                _getTierIcon(plan.tier),
                color: tierColor,
                size: 22,
              ),
            ),
            const SizedBox(width:  14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and tier badge
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets. symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSilver ?  tierColor : tierColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          plan.tier,
                          style: TextStyle(
                            fontSize:  8,
                            fontWeight: FontWeight.w700,
                            color: isSilver ? Colors.white : tierColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Duration and description
                  Text(
                    '${plan.durationText} • ${plan.description}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.labelText,
                    ),
                  ),
                  // Badges row (below description)
                  if (hasBadge) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (plan.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical:  2),
                            decoration:  BoxDecoration(
                              color:  AppColors.accentTeal,
                              borderRadius: BorderRadius. circular(4),
                            ),
                            child: const Text(
                              'POPULAR',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (plan.isBestValue)
                          Container(
                            padding:  const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.silver, // Green
                              borderRadius: BorderRadius. circular(4),
                            ),
                            child: const Text(
                              'BEST VALUE',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Price & Status (right side)
            Column(
              crossAxisAlignment:  CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: tierColor,
                  ),
                ),
                const SizedBox(height: 4),
                if (isCurrentPlan)
                  Container(
                    padding:
                    const EdgeInsets. symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'CURRENT',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (isSelected)
                  Container(
                    padding:  const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:  tierColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors. white,
                    ),
                  )
                else
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                      Border. all(color: AppColors.silverBorder, width: 2),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}