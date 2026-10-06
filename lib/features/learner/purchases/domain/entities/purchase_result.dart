class PurchaseResult {
  const PurchaseResult({required this.status, this.checkoutUrl});

  /// `completed` | `pending` | `already_enrolled`
  final String status;
  final String? checkoutUrl;

  bool get needsCheckout => checkoutUrl != null && checkoutUrl!.isNotEmpty;
  bool get isCompleted => status == 'completed' || status == 'already_enrolled';

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    final session = json['session'];
    final nested = session is Map<String, dynamic> ? session : null;
    final checkoutUrl = json['checkoutUrl'] as String? ??
        nested?['checkoutUrl'] as String?;
    final status = json['status'] as String? ?? 'pending';
    return PurchaseResult(status: status, checkoutUrl: checkoutUrl);
  }
}
