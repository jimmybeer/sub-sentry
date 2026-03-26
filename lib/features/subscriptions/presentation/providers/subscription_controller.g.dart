// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionRepositoryHash() =>
    r'1b57d78c112aa7be5518f44bea51ec2a11cabb7c';

/// See also [subscriptionRepository].
@ProviderFor(subscriptionRepository)
final subscriptionRepositoryProvider =
    AutoDisposeProvider<SubscriptionRepository>.internal(
  subscriptionRepository,
  name: r'subscriptionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionRepositoryRef
    = AutoDisposeProviderRef<SubscriptionRepository>;
String _$subscriptionControllerHash() =>
    r'bbcf867f43f9557a0ccc4bc7a3f248bf48b40c55';

/// See also [SubscriptionController].
@ProviderFor(SubscriptionController)
final subscriptionControllerProvider = AutoDisposeAsyncNotifierProvider<
    SubscriptionController, List<Subscription>>.internal(
  SubscriptionController.new,
  name: r'subscriptionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SubscriptionController = AutoDisposeAsyncNotifier<List<Subscription>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
