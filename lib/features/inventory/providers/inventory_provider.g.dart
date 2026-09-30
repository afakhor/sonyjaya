// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localDbHash() => r'f8db01c5c1d9d231f71d9673a2c1f87717676f0d';

/// See also [localDb].
@ProviderFor(localDb)
final localDbProvider = AutoDisposeProvider<LocalDatabase>.internal(
  localDb,
  name: r'localDbProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$localDbHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalDbRef = AutoDisposeProviderRef<LocalDatabase>;
String _$inventoryHash() => r'b614019e1ebab0153a63bf3d53b3c6b7781fb981';

/// See also [Inventory].
@ProviderFor(Inventory)
final inventoryProvider =
    AutoDisposeStreamNotifierProvider<Inventory, List<BarangData>>.internal(
  Inventory.new,
  name: r'inventoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$inventoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Inventory = AutoDisposeStreamNotifier<List<BarangData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
