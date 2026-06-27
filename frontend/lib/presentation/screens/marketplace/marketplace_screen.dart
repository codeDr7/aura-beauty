import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_gradients.dart';
import '../../widgets/common/aura_card.dart';
import '../../widgets/common/aura_button.dart';
import '../../widgets/common/product_card.dart';
import '../../widgets/common/section_header.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const MarketplaceScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPartnerRegistered = false;
  bool _showRegistrationForm = false;
  bool _showApiKeys = false;

  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactPersonController = TextEditingController();
  String _integrationType = 'REST API';

  final _integrationTypes = ['REST API', 'GraphQL', 'Webhook', 'Custom SDK'];

  final _products = [
    _ShopProduct(name: 'Luminous Hydrating Serum', brand: 'Aura Labs', price: '\$52.00', orders: 234),
    _ShopProduct(name: 'Retinol Night Recovery', brand: 'DermaPrime', price: '\$68.00', orders: 189),
    _ShopProduct(name: 'Gentle Foaming Cleanse', brand: 'Aura Labs', price: '\$28.00', orders: 312),
    _ShopProduct(name: 'Vitamin C Brightening Complex', brand: 'GlowDerm', price: '\$45.00', orders: 156),
    _ShopProduct(name: 'Hydra Barrier Cream', brand: 'DermaPrime', price: '\$38.00', orders: 278),
    _ShopProduct(name: 'SPF 50 Invisible Shield', brand: 'Aura Labs', price: '\$32.00', orders: 198),
  ];

  final _brands = ['All Brands', 'Aura Labs', 'DermaPrime', 'GlowDerm'];
  String _selectedBrand = 'All Brands';

  final _orders = [
    _PartnerOrder(id: 'ORD-001', customer: 'Sarah M.', product: 'Hydrating Serum', quantity: 2, status: 'Pending', date: 'Jun 25'),
    _PartnerOrder(id: 'ORD-002', customer: 'Jessica L.', product: 'Night Cream', quantity: 1, status: 'Shipped', date: 'Jun 24'),
    _PartnerOrder(id: 'ORD-003', customer: 'Emma R.', product: 'Vitamin C Serum', quantity: 3, status: 'Delivered', date: 'Jun 22'),
    _PartnerOrder(id: 'ORD-004', customer: 'Olivia K.', product: 'Cleanser Bundle', quantity: 5, status: 'Processing', date: 'Jun 21'),
    _PartnerOrder(id: 'ORD-005', customer: 'Mia T.', product: 'SPF 50', quantity: 2, status: 'Pending', date: 'Jun 20'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShopTab(),
                  _buildPartnerPortalTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warmNude.withOpacity(0.3),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: AppColors.softCharcoal, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            'AURA MARKETPLACE',
            style: AppTypography.overline.copyWith(color: AppColors.matteGold, letterSpacing: 3),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.matteGold,
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: AppTypography.buttonLabel.copyWith(fontSize: 12),
          unselectedLabelStyle: AppTypography.buttonLabel.copyWith(fontSize: 12, color: AppColors.onSurfaceVariant),
          tabs: const [
            Tab(text: 'Shop'),
            Tab(text: 'Partner Portal'),
          ],
        ),
      ),
    );
  }

  Widget _buildShopTab() {
    final filtered = _selectedBrand == 'All Brands'
        ? _products
        : _products.where((p) => p.brand == _selectedBrand).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.horizontalPadding,
            child: Row(
              children: [
                const Expanded(
                  child: SectionHeader(title: 'Products'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.ivoryWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBrand,
                      items: _brands.map((b) => DropdownMenuItem(value: b, child: Text(b, style: AppTypography.caption.copyWith(color: AppColors.softCharcoal)))).toList(),
                      onChanged: (v) => setState(() => _selectedBrand = v!),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(filtered.length, (i) {
            final product = filtered[i];
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.pageHorizontalPadding,
                right: AppSpacing.pageHorizontalPadding,
                bottom: 10,
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.warmNude.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.spa_outlined, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
                          const SizedBox(height: 2),
                          Text(product.brand, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text('${product.orders} orders', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(product.price, style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.matteGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Order', style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.horizontalPadding,
            child: SectionHeader(title: 'Order History', subtitle: 'Your recent purchases'),
          ),
          _OrderHistoryCard(
            product: 'Hydrating Serum',
            date: 'Jun 20',
            status: 'Delivered',
            amount: '\$52.00',
          ),
          _OrderHistoryCard(
            product: 'Retinol Night Cream',
            date: 'Jun 15',
            status: 'Delivered',
            amount: '\$68.00',
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerPortalTab() {
    if (!_isPartnerRegistered) {
      if (_showRegistrationForm) {
        return _buildRegistrationForm();
      }
      return _buildRegistrationPrompt();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
          _buildPartnerDashboard(),
          const SizedBox(height: AppSpacing.md),
          if (_showApiKeys) _buildApiKeys(),
          if (_showApiKeys) const SizedBox(height: AppSpacing.md),
          Padding(
            padding: AppSpacing.horizontalPadding,
            child: SectionHeader(title: 'Incoming Orders', subtitle: '${_orders.length} total'),
          ),
          ...List.generate(_orders.length, (i) {
            final order = _orders[i];
            return _PartnerOrderCard(order: order);
          }),
        ],
      ),
    );
  }

  Widget _buildRegistrationPrompt() {
    return Center(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.matteGold.withOpacity(0.08),
              ),
              child: const Icon(Icons.store_outlined, size: 40, color: AppColors.matteGold),
            ),
            const SizedBox(height: 16),
            Text(
              'Partner Portal',
              style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal),
            ),
            const SizedBox(height: 8),
            Text(
              'Register your cosmetic company to manage orders, track revenue, and integrate with the Aura platform.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AuraButton(
              label: 'Register Your Company',
              onPressed: () => setState(() => _showRegistrationForm = true),
              trailingIcon: Icons.arrow_forward_rounded,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: Text('Already registered? Sign in', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: AppSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _showRegistrationForm = false),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warmNude.withOpacity(0.3),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.softCharcoal, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text('Company Registration', style: AppTypography.cardTitle.copyWith(color: AppColors.softCharcoal)),
            ],
          ),
          const SizedBox(height: 24),
          _buildField('Company Name', _companyNameController),
          const SizedBox(height: 14),
          _buildField('Email Address', _emailController),
          const SizedBox(height: 14),
          _buildField('Contact Person', _contactPersonController),
          const SizedBox(height: 14),
          Text('Integration Type', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _integrationType,
                isExpanded: true,
                items: _integrationTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _integrationType = v!),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AuraButton(
            label: 'Submit Registration',
            onPressed: () {
              setState(() {
                _isPartnerRegistered = true;
                _showRegistrationForm = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerDashboard() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppGradients.auraGold,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Aura Labs Dashboard', style: AppTypography.cardTitle.copyWith(color: Colors.white, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _DashboardStat(label: 'Total Orders', value: '128', icon: Icons.shopping_bag_outlined),
                const SizedBox(width: 10),
                _DashboardStat(label: 'Pending', value: '14', icon: Icons.pending_outlined),
                const SizedBox(width: 10),
                _DashboardStat(label: 'Revenue', value: '\$4.2k', icon: Icons.trending_up),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showApiKeys = !_showApiKeys),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.vpn_key_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text('API Keys', style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeys() {
    return Padding(
      padding: AppSpacing.horizontalPadding,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.vpn_key, size: 18, color: AppColors.matteGold),
                const SizedBox(width: 8),
                Text('API Credentials', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
              ],
            ),
            const SizedBox(height: 14),
            _ApiKeyRow(label: 'API Key', value: 'aura_live_sk_xxxxx...'),
            const SizedBox(height: 8),
            _ApiKeyRow(label: 'API Secret', value: 'aura_live_ss_xxxxx...'),
            const SizedBox(height: 8),
            _ApiKeyRow(label: 'Webhook URL', value: 'https://api.aura.../webhook'),
          ],
        ),
      ),
    );
  }
}

class _ShopProduct {
  final String name;
  final String brand;
  final String price;
  final int orders;

  const _ShopProduct({
    required this.name,
    required this.brand,
    required this.price,
    required this.orders,
  });
}

class _PartnerOrder {
  final String id;
  final String customer;
  final String product;
  final int quantity;
  String status;
  final String date;

  _PartnerOrder({
    required this.id,
    required this.customer,
    required this.product,
    required this.quantity,
    required this.status,
    required this.date,
  });
}

class _OrderHistoryCard extends StatelessWidget {
  final String product;
  final String date;
  final String status;
  final String amount;

  const _OrderHistoryCard({
    required this.product,
    required this.date,
    required this.status,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontalPadding,
        0,
        AppSpacing.pageHorizontalPadding,
        8,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle, color: AppColors.sageGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
                  Text(date, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            Text(status, style: AppTypography.caption.copyWith(color: AppColors.sageGreen, fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Text(amount, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.softCharcoal)),
          ],
        ),
      ),
    );
  }
}

class _DashboardStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DashboardStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(value, style: AppTypography.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _PartnerOrderCard extends StatefulWidget {
  final _PartnerOrder order;

  const _PartnerOrderCard({required this.order});

  @override
  State<_PartnerOrderCard> createState() => _PartnerOrderCardState();
}

class _PartnerOrderCardState extends State<_PartnerOrderCard> {
  final _statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontalPadding,
        0,
        AppSpacing.pageHorizontalPadding,
        8,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.order.id, style: AppTypography.labelMedium.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.bold)),
                const Spacer(),
                _StatusBadge(status: widget.order.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${widget.order.customer}', style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal)),
                      Text('Product: ${widget.order.product} × ${widget.order.quantity}', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                      Text('Date: ${widget.order.date}', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: widget.order.status,
                          items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s, style: AppTypography.caption.copyWith(fontSize: 11)))).toList(),
                          onChanged: (v) => setState(() => widget.order.status = v!),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {},
                      child: Text('Invoice URL', style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'Delivered':
        return AppColors.sageGreen;
      case 'Shipped':
        return AppColors.info;
      case 'Processing':
        return AppColors.warning;
      case 'Pending':
        return AppColors.warning.withOpacity(0.7);
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: AppTypography.caption.copyWith(color: _color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}

class _ApiKeyRow extends StatelessWidget {
  final String label;
  final String value;

  const _ApiKeyRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
                Text(value, style: AppTypography.bodySmall.copyWith(color: AppColors.softCharcoal, fontWeight: FontWeight.w500, fontSize: 13)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.matteGold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.copy_rounded, size: 16, color: AppColors.matteGold),
            ),
          ),
        ],
      ),
    );
  }
}
