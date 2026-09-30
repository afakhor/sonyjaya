// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fast_stock_cache.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFastStockCacheCollection on Isar {
  IsarCollection<FastStockCache> get fastStockCaches => this.collection();
}

const FastStockCacheSchema = CollectionSchema(
  name: r'FastStockCache',
  id: -2320874653383012691,
  properties: {
    r'barangId': PropertySchema(
      id: 0,
      name: r'barangId',
      type: IsarType.long,
    ),
    r'hppAverage': PropertySchema(
      id: 1,
      name: r'hppAverage',
      type: IsarType.double,
    ),
    r'isFastMoving': PropertySchema(
      id: 2,
      name: r'isFastMoving',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 3,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'nama': PropertySchema(
      id: 4,
      name: r'nama',
      type: IsarType.string,
    ),
    r'perluReorder': PropertySchema(
      id: 5,
      name: r'perluReorder',
      type: IsarType.bool,
    ),
    r'safetyStock': PropertySchema(
      id: 6,
      name: r'safetyStock',
      type: IsarType.long,
    ),
    r'sku': PropertySchema(
      id: 7,
      name: r'sku',
      type: IsarType.string,
    ),
    r'stok': PropertySchema(
      id: 8,
      name: r'stok',
      type: IsarType.long,
    ),
    r'tor': PropertySchema(
      id: 9,
      name: r'tor',
      type: IsarType.double,
    )
  },
  estimateSize: _fastStockCacheEstimateSize,
  serialize: _fastStockCacheSerialize,
  deserialize: _fastStockCacheDeserialize,
  deserializeProp: _fastStockCacheDeserializeProp,
  idName: r'id',
  indexes: {
    r'barangId': IndexSchema(
      id: 6627696932638194973,
      name: r'barangId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'barangId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _fastStockCacheGetId,
  getLinks: _fastStockCacheGetLinks,
  attach: _fastStockCacheAttach,
  version: '3.3.0-dev.1',
);

int _fastStockCacheEstimateSize(
  FastStockCache object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nama.length * 3;
  bytesCount += 3 + object.sku.length * 3;
  return bytesCount;
}

void _fastStockCacheSerialize(
  FastStockCache object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.barangId);
  writer.writeDouble(offsets[1], object.hppAverage);
  writer.writeBool(offsets[2], object.isFastMoving);
  writer.writeDateTime(offsets[3], object.lastUpdated);
  writer.writeString(offsets[4], object.nama);
  writer.writeBool(offsets[5], object.perluReorder);
  writer.writeLong(offsets[6], object.safetyStock);
  writer.writeString(offsets[7], object.sku);
  writer.writeLong(offsets[8], object.stok);
  writer.writeDouble(offsets[9], object.tor);
}

FastStockCache _fastStockCacheDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FastStockCache();
  object.barangId = reader.readLong(offsets[0]);
  object.hppAverage = reader.readDouble(offsets[1]);
  object.id = id;
  object.isFastMoving = reader.readBool(offsets[2]);
  object.lastUpdated = reader.readDateTime(offsets[3]);
  object.nama = reader.readString(offsets[4]);
  object.perluReorder = reader.readBool(offsets[5]);
  object.safetyStock = reader.readLong(offsets[6]);
  object.sku = reader.readString(offsets[7]);
  object.stok = reader.readLong(offsets[8]);
  object.tor = reader.readDouble(offsets[9]);
  return object;
}

P _fastStockCacheDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fastStockCacheGetId(FastStockCache object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fastStockCacheGetLinks(FastStockCache object) {
  return [];
}

void _fastStockCacheAttach(
    IsarCollection<dynamic> col, Id id, FastStockCache object) {
  object.id = id;
}

extension FastStockCacheByIndex on IsarCollection<FastStockCache> {
  Future<FastStockCache?> getByBarangId(int barangId) {
    return getByIndex(r'barangId', [barangId]);
  }

  FastStockCache? getByBarangIdSync(int barangId) {
    return getByIndexSync(r'barangId', [barangId]);
  }

  Future<bool> deleteByBarangId(int barangId) {
    return deleteByIndex(r'barangId', [barangId]);
  }

  bool deleteByBarangIdSync(int barangId) {
    return deleteByIndexSync(r'barangId', [barangId]);
  }

  Future<List<FastStockCache?>> getAllByBarangId(List<int> barangIdValues) {
    final values = barangIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'barangId', values);
  }

  List<FastStockCache?> getAllByBarangIdSync(List<int> barangIdValues) {
    final values = barangIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'barangId', values);
  }

  Future<int> deleteAllByBarangId(List<int> barangIdValues) {
    final values = barangIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'barangId', values);
  }

  int deleteAllByBarangIdSync(List<int> barangIdValues) {
    final values = barangIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'barangId', values);
  }

  Future<Id> putByBarangId(FastStockCache object) {
    return putByIndex(r'barangId', object);
  }

  Id putByBarangIdSync(FastStockCache object, {bool saveLinks = true}) {
    return putByIndexSync(r'barangId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByBarangId(List<FastStockCache> objects) {
    return putAllByIndex(r'barangId', objects);
  }

  List<Id> putAllByBarangIdSync(List<FastStockCache> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'barangId', objects, saveLinks: saveLinks);
  }
}

extension FastStockCacheQueryWhereSort
    on QueryBuilder<FastStockCache, FastStockCache, QWhere> {
  QueryBuilder<FastStockCache, FastStockCache, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhere> anyBarangId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'barangId'),
      );
    });
  }
}

extension FastStockCacheQueryWhere
    on QueryBuilder<FastStockCache, FastStockCache, QWhereClause> {
  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause>
      barangIdEqualTo(int barangId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'barangId',
        value: [barangId],
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause>
      barangIdNotEqualTo(int barangId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'barangId',
              lower: [],
              upper: [barangId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'barangId',
              lower: [barangId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'barangId',
              lower: [barangId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'barangId',
              lower: [],
              upper: [barangId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause>
      barangIdGreaterThan(
    int barangId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'barangId',
        lower: [barangId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause>
      barangIdLessThan(
    int barangId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'barangId',
        lower: [],
        upper: [barangId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterWhereClause>
      barangIdBetween(
    int lowerBarangId,
    int upperBarangId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'barangId',
        lower: [lowerBarangId],
        includeLower: includeLower,
        upper: [upperBarangId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FastStockCacheQueryFilter
    on QueryBuilder<FastStockCache, FastStockCache, QFilterCondition> {
  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      barangIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'barangId',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      barangIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'barangId',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      barangIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'barangId',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      barangIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'barangId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      hppAverageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hppAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      hppAverageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hppAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      hppAverageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hppAverage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      hppAverageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hppAverage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      isFastMovingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFastMoving',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nama',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nama',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nama',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      namaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nama',
        value: '',
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      perluReorderEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'perluReorder',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      safetyStockEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'safetyStock',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      safetyStockGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'safetyStock',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      safetyStockLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'safetyStock',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      safetyStockBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'safetyStock',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sku',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sku',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sku',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sku',
        value: '',
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      skuIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sku',
        value: '',
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      stokEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stok',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      stokGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stok',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      stokLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stok',
        value: value,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      stokBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stok',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      torEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      torGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      torLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tor',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterFilterCondition>
      torBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension FastStockCacheQueryObject
    on QueryBuilder<FastStockCache, FastStockCache, QFilterCondition> {}

extension FastStockCacheQueryLinks
    on QueryBuilder<FastStockCache, FastStockCache, QFilterCondition> {}

extension FastStockCacheQuerySortBy
    on QueryBuilder<FastStockCache, FastStockCache, QSortBy> {
  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> sortByBarangId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barangId', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortByBarangIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barangId', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortByHppAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hppAverage', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortByHppAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hppAverage', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortByIsFastMoving() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFastMoving', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortByIsFastMovingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFastMoving', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> sortByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> sortByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortByPerluReorder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'perluReorder', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortByPerluReorderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'perluReorder', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortBySafetyStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'safetyStock', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      sortBySafetyStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'safetyStock', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> sortBySku() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sku', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> sortBySkuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sku', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> sortByStok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stok', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> sortByStokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stok', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> sortByTor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tor', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> sortByTorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tor', Sort.desc);
    });
  }
}

extension FastStockCacheQuerySortThenBy
    on QueryBuilder<FastStockCache, FastStockCache, QSortThenBy> {
  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenByBarangId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barangId', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenByBarangIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'barangId', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenByHppAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hppAverage', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenByHppAverageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hppAverage', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenByIsFastMoving() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFastMoving', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenByIsFastMovingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFastMoving', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenByNama() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenByNamaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nama', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenByPerluReorder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'perluReorder', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenByPerluReorderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'perluReorder', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenBySafetyStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'safetyStock', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy>
      thenBySafetyStockDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'safetyStock', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenBySku() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sku', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenBySkuDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sku', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenByStok() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stok', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenByStokDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stok', Sort.desc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenByTor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tor', Sort.asc);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QAfterSortBy> thenByTorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tor', Sort.desc);
    });
  }
}

extension FastStockCacheQueryWhereDistinct
    on QueryBuilder<FastStockCache, FastStockCache, QDistinct> {
  QueryBuilder<FastStockCache, FastStockCache, QDistinct> distinctByBarangId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'barangId');
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QDistinct>
      distinctByHppAverage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hppAverage');
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QDistinct>
      distinctByIsFastMoving() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFastMoving');
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QDistinct> distinctByNama(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nama', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QDistinct>
      distinctByPerluReorder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'perluReorder');
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QDistinct>
      distinctBySafetyStock() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'safetyStock');
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QDistinct> distinctBySku(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sku', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QDistinct> distinctByStok() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stok');
    });
  }

  QueryBuilder<FastStockCache, FastStockCache, QDistinct> distinctByTor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tor');
    });
  }
}

extension FastStockCacheQueryProperty
    on QueryBuilder<FastStockCache, FastStockCache, QQueryProperty> {
  QueryBuilder<FastStockCache, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FastStockCache, int, QQueryOperations> barangIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'barangId');
    });
  }

  QueryBuilder<FastStockCache, double, QQueryOperations> hppAverageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hppAverage');
    });
  }

  QueryBuilder<FastStockCache, bool, QQueryOperations> isFastMovingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFastMoving');
    });
  }

  QueryBuilder<FastStockCache, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<FastStockCache, String, QQueryOperations> namaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nama');
    });
  }

  QueryBuilder<FastStockCache, bool, QQueryOperations> perluReorderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'perluReorder');
    });
  }

  QueryBuilder<FastStockCache, int, QQueryOperations> safetyStockProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'safetyStock');
    });
  }

  QueryBuilder<FastStockCache, String, QQueryOperations> skuProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sku');
    });
  }

  QueryBuilder<FastStockCache, int, QQueryOperations> stokProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stok');
    });
  }

  QueryBuilder<FastStockCache, double, QQueryOperations> torProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tor');
    });
  }
}
