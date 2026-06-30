import '../../domain/entities/marketplace.dart';

class MarketplaceProductModel extends MarketplaceProduct {
  const MarketplaceProductModel({
    required super.id,
    required super.name,
    required super.brand,
    required super.price,
    super.orders,
    super.imageUrl,
  });

  factory MarketplaceProductModel.fromJson(Map<String, dynamic> json) {
    final priceNum = (json['price'] as num?)?.toDouble() ?? 0.0;
    return MarketplaceProductModel(
      id: json['name'] as String? ?? '',
      name: json['product_name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      price: priceNum > 0 ? '\$${priceNum.toStringAsFixed(2)}' : '\$0.00',
      orders: json['orders'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'product_name': name,
    'brand': brand,
    'price': price,
  };
}

class PartnerOrderModel extends PartnerOrder {
  const PartnerOrderModel({
    required super.id,
    required super.customer,
    required super.product,
    required super.quantity,
    super.status,
    required super.date,
  });

  factory PartnerOrderModel.fromJson(Map<String, dynamic> json) {
    return PartnerOrderModel(
      id: json['name'] as String? ?? '',
      customer: json['user'] as String? ?? '',
      product: (json['items'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['items']!.first as Map<String, dynamic>)['product'] as String? ?? ''
          : '',
      quantity: (json['items'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['items']!.first as Map<String, dynamic>)['quantity'] as int? ?? 1
          : 1,
      status: json['order_status'] as String? ?? 'Pending',
      date: json['ordered_date'] != null
          ? DateTime.parse(json['ordered_date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'user': customer,
    'order_status': status,
  };
}

class PartnerRegistrationModel extends PartnerRegistration {
  const PartnerRegistrationModel({
    required super.companyName,
    required super.email,
    required super.contactPerson,
    super.integrationType,
  });

  factory PartnerRegistrationModel.fromJson(Map<String, dynamic> json) {
    return PartnerRegistrationModel(
      companyName: json['company_name'] as String? ?? '',
      email: json['contact_email'] as String? ?? '',
      contactPerson: json['contact_person'] as String? ?? '',
      integrationType: json['integration_type'] as String? ?? 'REST API',
    );
  }

  Map<String, dynamic> toJson() => {
    'company_name': companyName,
    'contact_email': email,
    'contact_person': contactPerson,
    'integration_type': integrationType,
  };
}

class ApiCredentialsModel extends ApiCredentials {
  const ApiCredentialsModel({
    required super.apiKey,
    required super.apiSecret,
    required super.webhookUrl,
  });

  factory ApiCredentialsModel.fromJson(Map<String, dynamic> json) {
    return ApiCredentialsModel(
      apiKey: json['api_key'] as String? ?? '',
      apiSecret: json['api_secret'] as String? ?? '',
      webhookUrl: json['webhook_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'api_key': apiKey,
    'api_secret': apiSecret,
  };
}
