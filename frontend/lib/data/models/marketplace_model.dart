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
    return MarketplaceProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      price: json['price'] as String? ?? '\$0.00',
      orders: json['orders'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'price': price,
    'orders': orders,
    'image_url': imageUrl,
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
      id: json['id'] as String? ?? '',
      customer: json['customer'] as String? ?? '',
      product: json['product'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      status: json['status'] as String? ?? 'Pending',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customer': customer,
    'product': product,
    'quantity': quantity,
    'status': status,
    'date': date.toIso8601String(),
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
      email: json['email'] as String? ?? '',
      contactPerson: json['contact_person'] as String? ?? '',
      integrationType: json['integration_type'] as String? ?? 'REST API',
    );
  }

  Map<String, dynamic> toJson() => {
    'company_name': companyName,
    'email': email,
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
    'webhook_url': webhookUrl,
  };
}
