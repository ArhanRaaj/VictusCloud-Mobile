import 'package:dio/dio.dart';
import 'package:victus_app/features/billing/data/models/service_model.dart';
import 'package:victus_app/features/billing/data/models/invoice_model.dart';
import 'package:victus_app/features/billing/data/models/ticket_model.dart';
import 'package:victus_app/features/billing/data/models/product_model.dart';

class PaymenterClient {
  final Dio apiClient;
  final String baseUrl;

  PaymenterClient({required this.apiClient, required this.baseUrl});

  Future<Map<String, dynamic>> getAccount() async {
    final response = await apiClient.get('$baseUrl/account');
    return response.data['data'];
  }

  Future<List<ServiceModel>> listServices() async {
    final response = await apiClient.get('$baseUrl/services');
    return (response.data['data'] as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<ServiceModel> getService(int id) async {
    final response = await apiClient.get('$baseUrl/services/$id');
    return ServiceModel.fromJson(response.data['data']);
  }

  Future<void> cancelService(int id, {bool immediate = false}) async {
    await apiClient.post('$baseUrl/services/$id/cancel', data: {'immediate': immediate});
  }

  Future<List<InvoiceModel>> listInvoices() async {
    final response = await apiClient.get('$baseUrl/invoices');
    return (response.data['data'] as List).map((e) => InvoiceModel.fromJson(e)).toList();
  }

  Future<InvoiceModel> getInvoice(int id) async {
    final response = await apiClient.get('$baseUrl/invoices/$id');
    return InvoiceModel.fromJson(response.data['data']);
  }

  Future<String> payInvoice(int id, String gateway) async {
    final response = await apiClient.post('$baseUrl/invoices/$id/pay', data: {'gateway': gateway});
    return response.data['data']['url']; // Assuming 'url' field contains the payment URL
  }

  Future<List<TicketModel>> listTickets() async {
    final response = await apiClient.get('$baseUrl/tickets');
    return (response.data['data'] as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  Future<TicketModel> getTicket(int id) async {
    final response = await apiClient.get('$baseUrl/tickets/$id');
    return TicketModel.fromJson(response.data['data']);
  }

  Future<TicketModel> createTicket(String subject, String message, String priority, String department) async {
    final response = await apiClient.post('$baseUrl/tickets', data: {
      'subject': subject,
      'message': message,
      'priority': priority,
      'department': department,
    });
    return TicketModel.fromJson(response.data['data']);
  }

  Future<TicketModel> replyToTicket(int id, String message) async {
    final response = await apiClient.post('$baseUrl/tickets/$id/reply', data: {'message': message});
    return TicketModel.fromJson(response.data['data']);
  }

  Future<List<CategoryModel>> listCategories() async {
    final response = await apiClient.get('$baseUrl/categories');
    return (response.data['data'] as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<List<ProductModel>> listProducts(int categoryId) async {
    final response = await apiClient.get('$baseUrl/categories/$categoryId/products');
    return (response.data['data'] as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<ProductModel> getProduct(int id) async {
    final response = await apiClient.get('$baseUrl/products/$id');
    return ProductModel.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> createOrder(int productId, Map<String, dynamic> options) async {
    final response = await apiClient.post('$baseUrl/orders', data: {
      'product_id': productId,
      'options': options,
    });
    return response.data['data']; // Assuming order response map
  }
}
