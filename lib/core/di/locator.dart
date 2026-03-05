import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../services/service_request_service.dart';
import '../services/address_service.dart';

final locator = _Locator();

class _Locator {
  final Map<Type, dynamic> _services = {};

  T call<T>() {
    if (!_services.containsKey(T)) {
      throw Exception('Service $T not registered');
    }
    return _services[T] as T;
  }

  void register<T>(T instance) {
    _services[T] = instance;
  }
}

void setupLocator() {
  locator.register<SupabaseService>(SupabaseService());
  locator.register<AuthService>(AuthService());
  locator.register<ServiceRequestService>(ServiceRequestService());
  locator.register<AddressService>(AddressService());
}
