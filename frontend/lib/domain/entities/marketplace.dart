import 'package:equatable/equatable.dart';

class MarketplaceProduct extends Equatable {
  final String id;
  final String name;
  final String brand;
  final String price;
  final double priceValue;
  final int orders;
  final String? imageUrl;

  const MarketplaceProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    this.priceValue = 0.0,
    this.orders = 0,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, brand, price, priceValue, orders, imageUrl];
}

class PartnerOrder extends Equatable {
  final String id;
  final String customer;
  final String product;
  final int quantity;
  final String status;
  final DateTime date;

  const PartnerOrder({
    required this.id,
    required this.customer,
    required this.product,
    required this.quantity,
    this.status = 'Pending',
    required this.date,
  });

  @override
  List<Object?> get props => [id, customer, product, quantity, status, date];
}

class PartnerRegistration extends Equatable {
  final String companyName;
  final String email;
  final String contactPerson;
  final String integrationType;

  const PartnerRegistration({
    required this.companyName,
    required this.email,
    required this.contactPerson,
    this.integrationType = 'REST API',
  });

  @override
  List<Object?> get props => [companyName, email, contactPerson, integrationType];
}

class ApiCredentials extends Equatable {
  final String apiKey;
  final String apiSecret;
  final String webhookUrl;

  const ApiCredentials({
    required this.apiKey,
    required this.apiSecret,
    required this.webhookUrl,
  });

  @override
  List<Object?> get props => [apiKey, apiSecret, webhookUrl];
}
