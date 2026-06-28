import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_gradients.dart';
import '../../widgets/common/aura_button.dart';
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

  final _partnerProducts = <_PartnerProduct>[
    _PartnerProduct(name: 'Luminous Hydrating Serum', brand: 'Aura Labs', price: '\$52.00', category: 'Skincare', routineStep: 'Serum'),
    _PartnerProduct(name: 'Retinol Night Recovery', brand: 'Aura Labs', price: '\$68.00', category: 'Skincare', routineStep: 'Moisturizer'),
    _PartnerProduct(name: 'Gentle Foaming Cleanse', brand: 'Aura Labs', price: '\$28.00', category: 'Skincare', routineStep: 'Cleanser'),
  ];
  bool _showAddProductForm = false;

  final _productNameController = TextEditingController();
  final _productBrandController = TextEditingController();
  final _productDescriptionController = TextEditingController();
  final _productPriceController = TextEditingController();
  String _productCategory = 'Skincare';
  String _productRoutineStep = 'Serum';
  final _productCategories = ['Skincare', 'Haircare', 'Body', 'Fragrance'];
  final _productRoutineSteps = ['Cleanser', 'Toner', 'Serum', 'Moisturizer', 'SPF', 'Shampoo', 'Conditioner', 'Hair Mask', 'Hair Serum', 'Treatment'];

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

  bool _downloading = false;
  bool _bulkImporting = false;
  String? _bulkImportResult;
  bool _bulkImportSuccess = false;

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
    _productNameController.dispose();
    _productBrandController.dispose();
    _productDescriptionController.dispose();
    _productPriceController.dispose();
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
                      onChanged: (v) => setState(() => _selectedBrand = v ?? _selectedBrand),
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
            child: SectionHeader(title: 'My Products', subtitle: '${_partnerProducts.length} products'),
          ),
          if (_showAddProductForm) _buildAddProductForm(),
          if (_showAddProductForm) const SizedBox(height: AppSpacing.sm),
          ...List.generate(_partnerProducts.length, (i) {
            return _buildPartnerProductCard(_partnerProducts[i], i);
          }),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontalPadding,
              8,
              AppSpacing.pageHorizontalPadding,
              4,
            ),
            child: AuraButton(
              label: _showAddProductForm ? 'Cancel' : 'Add Product',
              onPressed: () => setState(() => _showAddProductForm = !_showAddProductForm),
              trailingIcon: _showAddProductForm ? Icons.close : Icons.add,
              isSecondary: !_showAddProductForm,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildBulkImportSection(),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: AppSpacing.horizontalPadding,
            child: SectionHeader(title: 'Incoming Orders', subtitle: '${_orders.length} total'),
          ),
          ...List.generate(_orders.length, (i) {
            final order = _orders[i];
            return _PartnerOrderCard(
              order: order,
              onStatusChanged: (newStatus) {
                setState(() => order.status = newStatus);
              },
            );
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
                onChanged: (v) => setState(() => _integrationType = v ?? _integrationType),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AuraButton(
            label: 'Submit Registration',
            onPressed: () {
              if (_companyNameController.text.trim().isEmpty ||
                  _emailController.text.trim().isEmpty) {
                return;
              }
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

  Widget _buildAddProductForm() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontalPadding,
        8,
        AppSpacing.pageHorizontalPadding,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.matteGold.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle_outline, size: 18, color: AppColors.matteGold),
                const SizedBox(width: 8),
                Text('New Product', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
              ],
            ),
            const SizedBox(height: 14),
            _buildField('Product Name', _productNameController),
            const SizedBox(height: 12),
            _buildField('Brand', _productBrandController),
            const SizedBox(height: 12),
            _buildField('Description', _productDescriptionController),
            const SizedBox(height: 12),
            _buildField('Price', _productPriceController),
            const SizedBox(height: 12),
            Text('Category', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _productCategory,
                  isExpanded: true,
                  items: _productCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _productCategory = v ?? _productCategory),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Routine Step', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _productRoutineStep,
                  isExpanded: true,
                  items: _productRoutineSteps.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _productRoutineStep = v ?? _productRoutineStep),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AuraButton(
                    label: 'Save Product',
                    onPressed: () {
                      if (_productNameController.text.trim().isEmpty) return;
                      setState(() {
                        _partnerProducts.add(_PartnerProduct(
                          name: _productNameController.text.trim(),
                          brand: _productBrandController.text.trim().isEmpty
                              ? 'Aura Labs'
                              : _productBrandController.text.trim(),
                          price: _productPriceController.text.trim().isEmpty
                              ? '\$0.00'
                              : '\$${_productPriceController.text.trim()}',
                          category: _productCategory,
                          routineStep: _productRoutineStep,
                        ));
                        _productNameController.clear();
                        _productBrandController.clear();
                        _productDescriptionController.clear();
                        _productPriceController.clear();
                        _showAddProductForm = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkImportSection() {
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
                Icon(Icons.cloud_upload_outlined, size: 18, color: AppColors.matteGold),
                const SizedBox(width: 8),
                Text('Bulk Import Products', style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.softCharcoal)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Upload a CSV or Excel file to add multiple products at once.',
              style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AuraButton(
                    label: _downloading ? 'Downloading...' : 'Download Template',
                    onPressed: _downloading ? null : _downloadTemplate,
                    trailingIcon: Icons.download_rounded,
                    isSecondary: true,
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AuraButton(
                    label: _bulkImporting ? 'Uploading...' : 'Upload File',
                    onPressed: _bulkImporting ? null : _uploadBulkImport,
                    trailingIcon: _bulkImporting ? null : Icons.upload_file,
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
            if (_bulkImportResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _bulkImportSuccess ? AppColors.sageGreen.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _bulkImportSuccess ? Icons.check_circle : Icons.error_outline,
                      size: 18,
                      color: _bulkImportSuccess ? AppColors.sageGreen : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _bulkImportResult!,
                        style: AppTypography.caption.copyWith(
                          color: _bulkImportSuccess ? AppColors.sageGreen : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _downloadTemplate() async {
    if (_downloading) return;
    setState(() => _downloading = true);
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/aura_product_template.xlsx';
      final dio = Dio();

      await dio.download(
        'https://api.aurabeauty.app/api/method/aura.api.marketplace.partner_download_template',
        path,
      );

      if (!mounted) return;
      setState(() {
        _bulkImportResult = 'Template downloaded to $path';
        _bulkImportSuccess = true;
        _downloading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bulkImportResult = 'Could not reach server. Creating local template...';
        _downloading = false;
      });
      _createSampleTemplateLocally();
    }
  }

  Future<void> _createSampleTemplateLocally() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/aura_product_template.csv');
      final content = 'product_name,brand,description,price,category,routine_step\n'
          'Example Serum,Your Brand,A rich hydrating serum,52.00,Skincare,Serum\n'
          'Example Cream,Your Brand,Retinol night cream,68.00,Skincare,Moisturizer\n';
      await file.writeAsString(content);

      if (!mounted) return;
      setState(() {
        _bulkImportResult = 'Sample CSV created at ${file.path}. Fill it out and upload.';
        _bulkImportSuccess = true;
      });
    } catch (_) {}
  }

  Future<void> _uploadBulkImport() async {
    final result = await FilePicker.platform?.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _bulkImporting = true;
      _bulkImportResult = null;
    });

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          result.files.single.path!,
          filename: result.files.single.name,
        ),
      });

      final response = await dio.post(
        'https://api.aurabeauty.app/api/method/aura.api.marketplace.partner_bulk_import',
        data: formData,
      );

      if (!mounted) return;
      final data = response.data as Map<String, dynamic>?;
      if (data != null && data['message'] != null) {
        final rawErrors = data['errors'];
        final errors = (rawErrors is List) ? rawErrors : [];
        setState(() {
          _bulkImportResult = data['message'].toString();
          _bulkImportSuccess = errors.isEmpty;
        });
      } else {
        setState(() {
          _bulkImportResult = 'Import completed with unknown result';
          _bulkImportSuccess = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _bulkImportResult = 'Simulating upload — ${_partnerProducts.length} products in catalog. Server unavailable.';
        _bulkImportSuccess = false;
      });
    } finally {
      if (mounted) setState(() => _bulkImporting = false);
    }
  }

  Widget _buildPartnerProductCard(_PartnerProduct product, int index) {
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.warmNude.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.spa_outlined, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.softCharcoal)),
                  const SizedBox(height: 2),
                  Text('${product.brand} · ${product.category}', style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
                  Text(product.routineStep, style: AppTypography.caption.copyWith(color: AppColors.matteGold, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(product.price, style: AppTypography.cardTitle.copyWith(fontSize: 15, color: AppColors.softCharcoal)),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _partnerProducts.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Remove', style: AppTypography.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.w600, fontSize: 11)),
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

class _PartnerProduct {
  final String name;
  final String brand;
  final String price;
  final String category;
  final String routineStep;

  const _PartnerProduct({
    required this.name,
    required this.brand,
    required this.price,
    required this.category,
    required this.routineStep,
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
  final ValueChanged<String>? onStatusChanged;

  const _PartnerOrderCard({required this.order, this.onStatusChanged});

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
                          onChanged: (v) => widget.onStatusChanged?.call(v ?? widget.order.status),
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
