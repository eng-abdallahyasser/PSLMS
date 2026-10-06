import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/app_widgets.dart';
import 'package:lms/features/instructor/storage/domain/entities/storage_entities.dart';
import 'package:lms/features/instructor/storage/presentation/cubit/storage_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  bool _subscribing = false;

  @override
  void initState() {
    super.initState();
    context.read<StorageCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage & Billing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<StorageCubit>().load(),
          ),
        ],
      ),
      body: BlocListener<StorageCubit, StorageState>(
        listener: (context, state) {
          if (state is StorageSubscribeCheckout) {
            _openUrl(state.checkoutUrl);
          }
          if (state is StorageError) {
            setState(() => _subscribing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<StorageCubit, StorageState>(
          builder: (context, state) {
            return switch (state) {
              StorageInitial() => const SizedBox.shrink(),
              StorageLoading() => const AppLoadingWidget(),
              StorageLoaded(:final usage, :final plans, :final revenue) =>
                _buildContent(usage, plans, revenue),
              StorageSubscribeCheckout() =>
                _subscribing ? const AppLoadingWidget() : const SizedBox.shrink(),
              StorageError(:final message) => _buildError(message),
            };
          },
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) {
      setState(() => _subscribing = false);
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!mounted) return;
    setState(() => _subscribing = false);
    context.read<StorageCubit>().load();
  }

  Widget _buildContent(
    StorageUsage usage,
    List<StoragePlan> plans,
    RevenueSummary? revenue,
  ) {
    return RefreshIndicator(
      onRefresh: () async => context.read<StorageCubit>().load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUsageCard(usage),
            if (revenue != null) ...[
              const SizedBox(height: 24),
              _buildRevenueCard(revenue),
            ],
            const SizedBox(height: 24),
            Text(
              'Storage Plans',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...plans.map((plan) => _buildPlanCard(plan)),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageCard(StorageUsage usage) {
    final usedGb = usage.usedBytes / (1024 * 1024 * 1024);
    final quotaGb = usage.quotaBytes / (1024 * 1024 * 1024);
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
                const Icon(Icons.storage, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Storage Usage',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${usedGb.toStringAsFixed(2)} GB of ${quotaGb.toStringAsFixed(2)} GB used',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: usage.usedPercentage / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  usage.usedPercentage > 90 ? Colors.red : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Active subscriptions: ${usage.activeSubscriptions}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(RevenueSummary revenue) {
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
                const Icon(Icons.payments, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Revenue',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRevenueRow('Sales', '${revenue.totalSales}'),
            _buildRevenueRow(
              'Gross revenue',
              '${revenue.grossRevenue.toStringAsFixed(2)} ${revenue.currency}',
            ),
            _buildRevenueRow(
              'Platform commission',
              '-${revenue.totalCommission.toStringAsFixed(2)} ${revenue.currency}',
            ),
            const Divider(),
            _buildRevenueRow(
              'Net revenue',
              '${revenue.netRevenue.toStringAsFixed(2)} ${revenue.currency}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueRow(String label, String value, {bool bold = false}) {
    final style = bold
        ? Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: style), Text(value, style: style)],
      ),
    );
  }

  Widget _buildPlanCard(StoragePlan plan) {
    final displayName =
        plan.nameAr != null && plan.nameAr!.isNotEmpty ? plan.nameAr! : plan.name;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.cloud, color: Colors.deepPurple, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.gigabytes} GB for ${plan.durationDays} days',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.price.toStringAsFixed(0)} ${plan.currency}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed:
                      plan.isActive && !_subscribing ? () => _subscribe(plan.id) : null,
                  child: const Text('Subscribe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _subscribe(String planId) {
    setState(() => _subscribing = true);
    context.read<StorageCubit>().subscribe(planId);
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<StorageCubit>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
