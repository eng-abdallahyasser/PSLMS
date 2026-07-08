import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/storage_addon_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_entity.dart';
import 'package:lms/features/instructor/subscriptions/domain/entities/subscription_plan_entity.dart';
import 'package:lms/features/instructor/subscriptions/presentation/cubit/subscription_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().loadSubscriptionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<SubscriptionCubit>().refreshSubscription(),
          ),
        ],
      ),
      body: BlocListener<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionCheckoutUrl || state is SubscriptionPortalUrl) {
            _openUrl(state is SubscriptionCheckoutUrl ? state.url : (state as SubscriptionPortalUrl).url);
          }
          if (state is SubscriptionActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
          builder: (context, state) {
            return switch (state) {
              SubscriptionInitial() => const SizedBox.shrink(),
              SubscriptionLoading() => const AppLoadingWidget(),
              SubscriptionLoaded(:final subscription, :final plans, :final storageAddons) => _buildContent(
                  subscription,
                  plans,
                  storageAddons,
                ),
              SubscriptionCheckoutUrl() => const AppLoadingWidget(),
              SubscriptionPortalUrl() => const AppLoadingWidget(),
              SubscriptionActionSuccess() => const AppLoadingWidget(),
              SubscriptionError(:final message) => _buildError(message),
            };
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    SubscriptionEntity subscription,
    List<SubscriptionPlanEntity> plans,
    List<StorageAddonEntity> storageAddons,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<SubscriptionCubit>().loadSubscriptionData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Plan Section
            _buildCurrentPlanCard(subscription),
            const SizedBox(height: 24),

            // Storage Usage
            _buildStorageSection(subscription, storageAddons),
            const SizedBox(height: 24),

            // Plans Grid
            Text(
              'Available Plans',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildPlansGrid(plans),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(SubscriptionEntity subscription) {
    final isActive = subscription.isActive;
    final isFree = subscription.isFree;
    final planLabel = subscription.planType.toUpperCase();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFree ? Icons.card_giftcard : Icons.star,
                  color: isFree ? Colors.grey : Colors.amber,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Plan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        planLabel,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: isActive ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (!isFree) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<SubscriptionCubit>().openPortal(),
                    icon: const Icon(Icons.credit_card, size: 18),
                    label: const Text('Manage Billing'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _confirmCancel(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSection(SubscriptionEntity subscription, List<StorageAddonEntity> storageAddons) {
    final storageUsed = subscription.storageUsed;
    final storageLimit = subscription.storageLimit;
    final usagePercent = storageLimit > 0
        ? (storageUsed / storageLimit).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  'Storage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      context.read<SubscriptionCubit>().buyStorage(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add 10 GB'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: usagePercent,
                backgroundColor: Colors.grey[200],
                color: usagePercent > 0.8 ? Colors.red : Colors.blue,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatStorage(storageUsed)} / ${_formatStorage(storageLimit)} used',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            if (storageAddons.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Storage Add-ons',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ...storageAddons.map((addon) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: Colors.green[400]),
                        const SizedBox(width: 8),
                        Text('${addon.sizeGb} GB add-on'),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlansGrid(List<SubscriptionPlanEntity> plans) {
    if (plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No plans available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: plans.length,
      itemBuilder: (context, index) => _buildPlanCard(plans[index]),
    );
  }

  Widget _buildPlanCard(SubscriptionPlanEntity plan) {
    final isPopular = plan.isPopular;

    return Card(
      elevation: isPopular ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.formattedPrice,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plan.price > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 2),
                        child: Text(
                          plan.pricePeriod,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: plan.features.map((f) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check,
                                  size: 16, color: Colors.green[400]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  f,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context
                        .read<SubscriptionCubit>()
                        .choosePlan(planType: plan.type),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPopular ? Colors.blue : Colors.grey[200],
                      foregroundColor: isPopular ? Colors.white : Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Choose'),
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<SubscriptionCubit>().loadSubscriptionData(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No URL returned from server')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure? Your subscription will be downgraded to Free at the end of the current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Plan'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<SubscriptionCubit>().cancelSubscription();
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );
  }

  String _formatStorage(double bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
}
