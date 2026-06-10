import 'package:mockito/mockito.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/core/storage/storage_service.dart';

/// Mock implementation of ApiClient for testing.
class MockApiClient extends Mock implements ApiClient {}

/// Mock implementation of StorageService for testing.
class MockStorageService extends Mock implements StorageService {}
