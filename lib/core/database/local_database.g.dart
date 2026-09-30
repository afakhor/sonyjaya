// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $BarangTable extends Barang with TableInfo<$BarangTable, BarangData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarangTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _namaMeta = const VerificationMeta('nama');
  @override
  late final GeneratedColumn<String> nama = GeneratedColumn<String>(
      'nama', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _merekMeta = const VerificationMeta('merek');
  @override
  late final GeneratedColumn<String> merek = GeneratedColumn<String>(
      'merek', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _satuanTerkecilMeta =
      const VerificationMeta('satuanTerkecil');
  @override
  late final GeneratedColumn<String> satuanTerkecil = GeneratedColumn<String>(
      'satuan_terkecil', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Pcs'));
  static const VerificationMeta _satuanBesarMeta =
      const VerificationMeta('satuanBesar');
  @override
  late final GeneratedColumn<String> satuanBesar = GeneratedColumn<String>(
      'satuan_besar', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Dus'));
  static const VerificationMeta _konversiMeta =
      const VerificationMeta('konversi');
  @override
  late final GeneratedColumn<int> konversi = GeneratedColumn<int>(
      'konversi', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(24));
  static const VerificationMeta _hppAverageMeta =
      const VerificationMeta('hppAverage');
  @override
  late final GeneratedColumn<double> hppAverage = GeneratedColumn<double>(
      'hpp_average', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _hargaEcerMeta =
      const VerificationMeta('hargaEcer');
  @override
  late final GeneratedColumn<double> hargaEcer = GeneratedColumn<double>(
      'harga_ecer', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _hargaAgenMeta =
      const VerificationMeta('hargaAgen');
  @override
  late final GeneratedColumn<double> hargaAgen = GeneratedColumn<double>(
      'harga_agen', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stokMeta = const VerificationMeta('stok');
  @override
  late final GeneratedColumn<int> stok = GeneratedColumn<int>(
      'stok', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _safetyStockMeta =
      const VerificationMeta('safetyStock');
  @override
  late final GeneratedColumn<int> safetyStock = GeneratedColumn<int>(
      'safety_stock', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        sku,
        nama,
        merek,
        satuanTerkecil,
        satuanBesar,
        konversi,
        hppAverage,
        hargaEcer,
        hargaAgen,
        stok,
        safetyStock,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barang';
  @override
  VerificationContext validateIntegrity(Insertable<BarangData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('nama')) {
      context.handle(
          _namaMeta, nama.isAcceptableOrUnknown(data['nama']!, _namaMeta));
    } else if (isInserting) {
      context.missing(_namaMeta);
    }
    if (data.containsKey('merek')) {
      context.handle(
          _merekMeta, merek.isAcceptableOrUnknown(data['merek']!, _merekMeta));
    }
    if (data.containsKey('satuan_terkecil')) {
      context.handle(
          _satuanTerkecilMeta,
          satuanTerkecil.isAcceptableOrUnknown(
              data['satuan_terkecil']!, _satuanTerkecilMeta));
    }
    if (data.containsKey('satuan_besar')) {
      context.handle(
          _satuanBesarMeta,
          satuanBesar.isAcceptableOrUnknown(
              data['satuan_besar']!, _satuanBesarMeta));
    }
    if (data.containsKey('konversi')) {
      context.handle(_konversiMeta,
          konversi.isAcceptableOrUnknown(data['konversi']!, _konversiMeta));
    }
    if (data.containsKey('hpp_average')) {
      context.handle(
          _hppAverageMeta,
          hppAverage.isAcceptableOrUnknown(
              data['hpp_average']!, _hppAverageMeta));
    }
    if (data.containsKey('harga_ecer')) {
      context.handle(_hargaEcerMeta,
          hargaEcer.isAcceptableOrUnknown(data['harga_ecer']!, _hargaEcerMeta));
    }
    if (data.containsKey('harga_agen')) {
      context.handle(_hargaAgenMeta,
          hargaAgen.isAcceptableOrUnknown(data['harga_agen']!, _hargaAgenMeta));
    }
    if (data.containsKey('stok')) {
      context.handle(
          _stokMeta, stok.isAcceptableOrUnknown(data['stok']!, _stokMeta));
    }
    if (data.containsKey('safety_stock')) {
      context.handle(
          _safetyStockMeta,
          safetyStock.isAcceptableOrUnknown(
              data['safety_stock']!, _safetyStockMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BarangData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarangData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      nama: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nama'])!,
      merek: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}merek']),
      satuanTerkecil: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}satuan_terkecil'])!,
      satuanBesar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}satuan_besar'])!,
      konversi: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}konversi'])!,
      hppAverage: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hpp_average'])!,
      hargaEcer: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}harga_ecer'])!,
      hargaAgen: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}harga_agen'])!,
      stok: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stok'])!,
      safetyStock: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}safety_stock'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BarangTable createAlias(String alias) {
    return $BarangTable(attachedDatabase, alias);
  }
}

class BarangData extends DataClass implements Insertable<BarangData> {
  final int id;
  final String sku;
  final String nama;
  final String? merek;
  final String satuanTerkecil;
  final String satuanBesar;
  final int konversi;
  final double hppAverage;
  final double hargaEcer;
  final double hargaAgen;
  final int stok;
  final int safetyStock;
  final DateTime updatedAt;
  const BarangData(
      {required this.id,
      required this.sku,
      required this.nama,
      this.merek,
      required this.satuanTerkecil,
      required this.satuanBesar,
      required this.konversi,
      required this.hppAverage,
      required this.hargaEcer,
      required this.hargaAgen,
      required this.stok,
      required this.safetyStock,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sku'] = Variable<String>(sku);
    map['nama'] = Variable<String>(nama);
    if (!nullToAbsent || merek != null) {
      map['merek'] = Variable<String>(merek);
    }
    map['satuan_terkecil'] = Variable<String>(satuanTerkecil);
    map['satuan_besar'] = Variable<String>(satuanBesar);
    map['konversi'] = Variable<int>(konversi);
    map['hpp_average'] = Variable<double>(hppAverage);
    map['harga_ecer'] = Variable<double>(hargaEcer);
    map['harga_agen'] = Variable<double>(hargaAgen);
    map['stok'] = Variable<int>(stok);
    map['safety_stock'] = Variable<int>(safetyStock);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BarangCompanion toCompanion(bool nullToAbsent) {
    return BarangCompanion(
      id: Value(id),
      sku: Value(sku),
      nama: Value(nama),
      merek:
          merek == null && nullToAbsent ? const Value.absent() : Value(merek),
      satuanTerkecil: Value(satuanTerkecil),
      satuanBesar: Value(satuanBesar),
      konversi: Value(konversi),
      hppAverage: Value(hppAverage),
      hargaEcer: Value(hargaEcer),
      hargaAgen: Value(hargaAgen),
      stok: Value(stok),
      safetyStock: Value(safetyStock),
      updatedAt: Value(updatedAt),
    );
  }

  factory BarangData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarangData(
      id: serializer.fromJson<int>(json['id']),
      sku: serializer.fromJson<String>(json['sku']),
      nama: serializer.fromJson<String>(json['nama']),
      merek: serializer.fromJson<String?>(json['merek']),
      satuanTerkecil: serializer.fromJson<String>(json['satuanTerkecil']),
      satuanBesar: serializer.fromJson<String>(json['satuanBesar']),
      konversi: serializer.fromJson<int>(json['konversi']),
      hppAverage: serializer.fromJson<double>(json['hppAverage']),
      hargaEcer: serializer.fromJson<double>(json['hargaEcer']),
      hargaAgen: serializer.fromJson<double>(json['hargaAgen']),
      stok: serializer.fromJson<int>(json['stok']),
      safetyStock: serializer.fromJson<int>(json['safetyStock']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sku': serializer.toJson<String>(sku),
      'nama': serializer.toJson<String>(nama),
      'merek': serializer.toJson<String?>(merek),
      'satuanTerkecil': serializer.toJson<String>(satuanTerkecil),
      'satuanBesar': serializer.toJson<String>(satuanBesar),
      'konversi': serializer.toJson<int>(konversi),
      'hppAverage': serializer.toJson<double>(hppAverage),
      'hargaEcer': serializer.toJson<double>(hargaEcer),
      'hargaAgen': serializer.toJson<double>(hargaAgen),
      'stok': serializer.toJson<int>(stok),
      'safetyStock': serializer.toJson<int>(safetyStock),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BarangData copyWith(
          {int? id,
          String? sku,
          String? nama,
          Value<String?> merek = const Value.absent(),
          String? satuanTerkecil,
          String? satuanBesar,
          int? konversi,
          double? hppAverage,
          double? hargaEcer,
          double? hargaAgen,
          int? stok,
          int? safetyStock,
          DateTime? updatedAt}) =>
      BarangData(
        id: id ?? this.id,
        sku: sku ?? this.sku,
        nama: nama ?? this.nama,
        merek: merek.present ? merek.value : this.merek,
        satuanTerkecil: satuanTerkecil ?? this.satuanTerkecil,
        satuanBesar: satuanBesar ?? this.satuanBesar,
        konversi: konversi ?? this.konversi,
        hppAverage: hppAverage ?? this.hppAverage,
        hargaEcer: hargaEcer ?? this.hargaEcer,
        hargaAgen: hargaAgen ?? this.hargaAgen,
        stok: stok ?? this.stok,
        safetyStock: safetyStock ?? this.safetyStock,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  BarangData copyWithCompanion(BarangCompanion data) {
    return BarangData(
      id: data.id.present ? data.id.value : this.id,
      sku: data.sku.present ? data.sku.value : this.sku,
      nama: data.nama.present ? data.nama.value : this.nama,
      merek: data.merek.present ? data.merek.value : this.merek,
      satuanTerkecil: data.satuanTerkecil.present
          ? data.satuanTerkecil.value
          : this.satuanTerkecil,
      satuanBesar:
          data.satuanBesar.present ? data.satuanBesar.value : this.satuanBesar,
      konversi: data.konversi.present ? data.konversi.value : this.konversi,
      hppAverage:
          data.hppAverage.present ? data.hppAverage.value : this.hppAverage,
      hargaEcer: data.hargaEcer.present ? data.hargaEcer.value : this.hargaEcer,
      hargaAgen: data.hargaAgen.present ? data.hargaAgen.value : this.hargaAgen,
      stok: data.stok.present ? data.stok.value : this.stok,
      safetyStock:
          data.safetyStock.present ? data.safetyStock.value : this.safetyStock,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarangData(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('nama: $nama, ')
          ..write('merek: $merek, ')
          ..write('satuanTerkecil: $satuanTerkecil, ')
          ..write('satuanBesar: $satuanBesar, ')
          ..write('konversi: $konversi, ')
          ..write('hppAverage: $hppAverage, ')
          ..write('hargaEcer: $hargaEcer, ')
          ..write('hargaAgen: $hargaAgen, ')
          ..write('stok: $stok, ')
          ..write('safetyStock: $safetyStock, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      sku,
      nama,
      merek,
      satuanTerkecil,
      satuanBesar,
      konversi,
      hppAverage,
      hargaEcer,
      hargaAgen,
      stok,
      safetyStock,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarangData &&
          other.id == this.id &&
          other.sku == this.sku &&
          other.nama == this.nama &&
          other.merek == this.merek &&
          other.satuanTerkecil == this.satuanTerkecil &&
          other.satuanBesar == this.satuanBesar &&
          other.konversi == this.konversi &&
          other.hppAverage == this.hppAverage &&
          other.hargaEcer == this.hargaEcer &&
          other.hargaAgen == this.hargaAgen &&
          other.stok == this.stok &&
          other.safetyStock == this.safetyStock &&
          other.updatedAt == this.updatedAt);
}

class BarangCompanion extends UpdateCompanion<BarangData> {
  final Value<int> id;
  final Value<String> sku;
  final Value<String> nama;
  final Value<String?> merek;
  final Value<String> satuanTerkecil;
  final Value<String> satuanBesar;
  final Value<int> konversi;
  final Value<double> hppAverage;
  final Value<double> hargaEcer;
  final Value<double> hargaAgen;
  final Value<int> stok;
  final Value<int> safetyStock;
  final Value<DateTime> updatedAt;
  const BarangCompanion({
    this.id = const Value.absent(),
    this.sku = const Value.absent(),
    this.nama = const Value.absent(),
    this.merek = const Value.absent(),
    this.satuanTerkecil = const Value.absent(),
    this.satuanBesar = const Value.absent(),
    this.konversi = const Value.absent(),
    this.hppAverage = const Value.absent(),
    this.hargaEcer = const Value.absent(),
    this.hargaAgen = const Value.absent(),
    this.stok = const Value.absent(),
    this.safetyStock = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BarangCompanion.insert({
    this.id = const Value.absent(),
    required String sku,
    required String nama,
    this.merek = const Value.absent(),
    this.satuanTerkecil = const Value.absent(),
    this.satuanBesar = const Value.absent(),
    this.konversi = const Value.absent(),
    this.hppAverage = const Value.absent(),
    this.hargaEcer = const Value.absent(),
    this.hargaAgen = const Value.absent(),
    this.stok = const Value.absent(),
    this.safetyStock = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : sku = Value(sku),
        nama = Value(nama);
  static Insertable<BarangData> custom({
    Expression<int>? id,
    Expression<String>? sku,
    Expression<String>? nama,
    Expression<String>? merek,
    Expression<String>? satuanTerkecil,
    Expression<String>? satuanBesar,
    Expression<int>? konversi,
    Expression<double>? hppAverage,
    Expression<double>? hargaEcer,
    Expression<double>? hargaAgen,
    Expression<int>? stok,
    Expression<int>? safetyStock,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sku != null) 'sku': sku,
      if (nama != null) 'nama': nama,
      if (merek != null) 'merek': merek,
      if (satuanTerkecil != null) 'satuan_terkecil': satuanTerkecil,
      if (satuanBesar != null) 'satuan_besar': satuanBesar,
      if (konversi != null) 'konversi': konversi,
      if (hppAverage != null) 'hpp_average': hppAverage,
      if (hargaEcer != null) 'harga_ecer': hargaEcer,
      if (hargaAgen != null) 'harga_agen': hargaAgen,
      if (stok != null) 'stok': stok,
      if (safetyStock != null) 'safety_stock': safetyStock,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BarangCompanion copyWith(
      {Value<int>? id,
      Value<String>? sku,
      Value<String>? nama,
      Value<String?>? merek,
      Value<String>? satuanTerkecil,
      Value<String>? satuanBesar,
      Value<int>? konversi,
      Value<double>? hppAverage,
      Value<double>? hargaEcer,
      Value<double>? hargaAgen,
      Value<int>? stok,
      Value<int>? safetyStock,
      Value<DateTime>? updatedAt}) {
    return BarangCompanion(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      nama: nama ?? this.nama,
      merek: merek ?? this.merek,
      satuanTerkecil: satuanTerkecil ?? this.satuanTerkecil,
      satuanBesar: satuanBesar ?? this.satuanBesar,
      konversi: konversi ?? this.konversi,
      hppAverage: hppAverage ?? this.hppAverage,
      hargaEcer: hargaEcer ?? this.hargaEcer,
      hargaAgen: hargaAgen ?? this.hargaAgen,
      stok: stok ?? this.stok,
      safetyStock: safetyStock ?? this.safetyStock,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (nama.present) {
      map['nama'] = Variable<String>(nama.value);
    }
    if (merek.present) {
      map['merek'] = Variable<String>(merek.value);
    }
    if (satuanTerkecil.present) {
      map['satuan_terkecil'] = Variable<String>(satuanTerkecil.value);
    }
    if (satuanBesar.present) {
      map['satuan_besar'] = Variable<String>(satuanBesar.value);
    }
    if (konversi.present) {
      map['konversi'] = Variable<int>(konversi.value);
    }
    if (hppAverage.present) {
      map['hpp_average'] = Variable<double>(hppAverage.value);
    }
    if (hargaEcer.present) {
      map['harga_ecer'] = Variable<double>(hargaEcer.value);
    }
    if (hargaAgen.present) {
      map['harga_agen'] = Variable<double>(hargaAgen.value);
    }
    if (stok.present) {
      map['stok'] = Variable<int>(stok.value);
    }
    if (safetyStock.present) {
      map['safety_stock'] = Variable<int>(safetyStock.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarangCompanion(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('nama: $nama, ')
          ..write('merek: $merek, ')
          ..write('satuanTerkecil: $satuanTerkecil, ')
          ..write('satuanBesar: $satuanBesar, ')
          ..write('konversi: $konversi, ')
          ..write('hppAverage: $hppAverage, ')
          ..write('hargaEcer: $hargaEcer, ')
          ..write('hargaAgen: $hargaAgen, ')
          ..write('stok: $stok, ')
          ..write('safetyStock: $safetyStock, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PembelianTable extends Pembelian
    with TableInfo<$PembelianTable, PembelianData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PembelianTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _barangIdMeta =
      const VerificationMeta('barangId');
  @override
  late final GeneratedColumn<int> barangId = GeneratedColumn<int>(
      'barang_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES barang(id) ON DELETE CASCADE');
  static const VerificationMeta _qtyPcsMeta = const VerificationMeta('qtyPcs');
  @override
  late final GeneratedColumn<int> qtyPcs = GeneratedColumn<int>(
      'qty_pcs', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hargaBeliPerPcsMeta =
      const VerificationMeta('hargaBeliPerPcs');
  @override
  late final GeneratedColumn<double> hargaBeliPerPcs = GeneratedColumn<double>(
      'harga_beli_per_pcs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _supplierMeta =
      const VerificationMeta('supplier');
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
      'supplier', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tanggalMeta =
      const VerificationMeta('tanggal');
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
      'tanggal', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, barangId, qtyPcs, hargaBeliPerPcs, supplier, tanggal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pembelian';
  @override
  VerificationContext validateIntegrity(Insertable<PembelianData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barang_id')) {
      context.handle(_barangIdMeta,
          barangId.isAcceptableOrUnknown(data['barang_id']!, _barangIdMeta));
    } else if (isInserting) {
      context.missing(_barangIdMeta);
    }
    if (data.containsKey('qty_pcs')) {
      context.handle(_qtyPcsMeta,
          qtyPcs.isAcceptableOrUnknown(data['qty_pcs']!, _qtyPcsMeta));
    } else if (isInserting) {
      context.missing(_qtyPcsMeta);
    }
    if (data.containsKey('harga_beli_per_pcs')) {
      context.handle(
          _hargaBeliPerPcsMeta,
          hargaBeliPerPcs.isAcceptableOrUnknown(
              data['harga_beli_per_pcs']!, _hargaBeliPerPcsMeta));
    } else if (isInserting) {
      context.missing(_hargaBeliPerPcsMeta);
    }
    if (data.containsKey('supplier')) {
      context.handle(_supplierMeta,
          supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta));
    }
    if (data.containsKey('tanggal')) {
      context.handle(_tanggalMeta,
          tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PembelianData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PembelianData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      barangId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}barang_id'])!,
      qtyPcs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_pcs'])!,
      hargaBeliPerPcs: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}harga_beli_per_pcs'])!,
      supplier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier']),
      tanggal: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}tanggal'])!,
    );
  }

  @override
  $PembelianTable createAlias(String alias) {
    return $PembelianTable(attachedDatabase, alias);
  }
}

class PembelianData extends DataClass implements Insertable<PembelianData> {
  final int id;
  final int barangId;
  final int qtyPcs;
  final double hargaBeliPerPcs;
  final String? supplier;
  final DateTime tanggal;
  const PembelianData(
      {required this.id,
      required this.barangId,
      required this.qtyPcs,
      required this.hargaBeliPerPcs,
      this.supplier,
      required this.tanggal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barang_id'] = Variable<int>(barangId);
    map['qty_pcs'] = Variable<int>(qtyPcs);
    map['harga_beli_per_pcs'] = Variable<double>(hargaBeliPerPcs);
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    map['tanggal'] = Variable<DateTime>(tanggal);
    return map;
  }

  PembelianCompanion toCompanion(bool nullToAbsent) {
    return PembelianCompanion(
      id: Value(id),
      barangId: Value(barangId),
      qtyPcs: Value(qtyPcs),
      hargaBeliPerPcs: Value(hargaBeliPerPcs),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      tanggal: Value(tanggal),
    );
  }

  factory PembelianData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PembelianData(
      id: serializer.fromJson<int>(json['id']),
      barangId: serializer.fromJson<int>(json['barangId']),
      qtyPcs: serializer.fromJson<int>(json['qtyPcs']),
      hargaBeliPerPcs: serializer.fromJson<double>(json['hargaBeliPerPcs']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barangId': serializer.toJson<int>(barangId),
      'qtyPcs': serializer.toJson<int>(qtyPcs),
      'hargaBeliPerPcs': serializer.toJson<double>(hargaBeliPerPcs),
      'supplier': serializer.toJson<String?>(supplier),
      'tanggal': serializer.toJson<DateTime>(tanggal),
    };
  }

  PembelianData copyWith(
          {int? id,
          int? barangId,
          int? qtyPcs,
          double? hargaBeliPerPcs,
          Value<String?> supplier = const Value.absent(),
          DateTime? tanggal}) =>
      PembelianData(
        id: id ?? this.id,
        barangId: barangId ?? this.barangId,
        qtyPcs: qtyPcs ?? this.qtyPcs,
        hargaBeliPerPcs: hargaBeliPerPcs ?? this.hargaBeliPerPcs,
        supplier: supplier.present ? supplier.value : this.supplier,
        tanggal: tanggal ?? this.tanggal,
      );
  PembelianData copyWithCompanion(PembelianCompanion data) {
    return PembelianData(
      id: data.id.present ? data.id.value : this.id,
      barangId: data.barangId.present ? data.barangId.value : this.barangId,
      qtyPcs: data.qtyPcs.present ? data.qtyPcs.value : this.qtyPcs,
      hargaBeliPerPcs: data.hargaBeliPerPcs.present
          ? data.hargaBeliPerPcs.value
          : this.hargaBeliPerPcs,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PembelianData(')
          ..write('id: $id, ')
          ..write('barangId: $barangId, ')
          ..write('qtyPcs: $qtyPcs, ')
          ..write('hargaBeliPerPcs: $hargaBeliPerPcs, ')
          ..write('supplier: $supplier, ')
          ..write('tanggal: $tanggal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, barangId, qtyPcs, hargaBeliPerPcs, supplier, tanggal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PembelianData &&
          other.id == this.id &&
          other.barangId == this.barangId &&
          other.qtyPcs == this.qtyPcs &&
          other.hargaBeliPerPcs == this.hargaBeliPerPcs &&
          other.supplier == this.supplier &&
          other.tanggal == this.tanggal);
}

class PembelianCompanion extends UpdateCompanion<PembelianData> {
  final Value<int> id;
  final Value<int> barangId;
  final Value<int> qtyPcs;
  final Value<double> hargaBeliPerPcs;
  final Value<String?> supplier;
  final Value<DateTime> tanggal;
  const PembelianCompanion({
    this.id = const Value.absent(),
    this.barangId = const Value.absent(),
    this.qtyPcs = const Value.absent(),
    this.hargaBeliPerPcs = const Value.absent(),
    this.supplier = const Value.absent(),
    this.tanggal = const Value.absent(),
  });
  PembelianCompanion.insert({
    this.id = const Value.absent(),
    required int barangId,
    required int qtyPcs,
    required double hargaBeliPerPcs,
    this.supplier = const Value.absent(),
    this.tanggal = const Value.absent(),
  })  : barangId = Value(barangId),
        qtyPcs = Value(qtyPcs),
        hargaBeliPerPcs = Value(hargaBeliPerPcs);
  static Insertable<PembelianData> custom({
    Expression<int>? id,
    Expression<int>? barangId,
    Expression<int>? qtyPcs,
    Expression<double>? hargaBeliPerPcs,
    Expression<String>? supplier,
    Expression<DateTime>? tanggal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barangId != null) 'barang_id': barangId,
      if (qtyPcs != null) 'qty_pcs': qtyPcs,
      if (hargaBeliPerPcs != null) 'harga_beli_per_pcs': hargaBeliPerPcs,
      if (supplier != null) 'supplier': supplier,
      if (tanggal != null) 'tanggal': tanggal,
    });
  }

  PembelianCompanion copyWith(
      {Value<int>? id,
      Value<int>? barangId,
      Value<int>? qtyPcs,
      Value<double>? hargaBeliPerPcs,
      Value<String?>? supplier,
      Value<DateTime>? tanggal}) {
    return PembelianCompanion(
      id: id ?? this.id,
      barangId: barangId ?? this.barangId,
      qtyPcs: qtyPcs ?? this.qtyPcs,
      hargaBeliPerPcs: hargaBeliPerPcs ?? this.hargaBeliPerPcs,
      supplier: supplier ?? this.supplier,
      tanggal: tanggal ?? this.tanggal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barangId.present) {
      map['barang_id'] = Variable<int>(barangId.value);
    }
    if (qtyPcs.present) {
      map['qty_pcs'] = Variable<int>(qtyPcs.value);
    }
    if (hargaBeliPerPcs.present) {
      map['harga_beli_per_pcs'] = Variable<double>(hargaBeliPerPcs.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PembelianCompanion(')
          ..write('id: $id, ')
          ..write('barangId: $barangId, ')
          ..write('qtyPcs: $qtyPcs, ')
          ..write('hargaBeliPerPcs: $hargaBeliPerPcs, ')
          ..write('supplier: $supplier, ')
          ..write('tanggal: $tanggal')
          ..write(')'))
        .toString();
  }
}

class $PenjualanTable extends Penjualan
    with TableInfo<$PenjualanTable, PenjualanData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PenjualanTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _barangIdMeta =
      const VerificationMeta('barangId');
  @override
  late final GeneratedColumn<int> barangId = GeneratedColumn<int>(
      'barang_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES barang(id) ON DELETE CASCADE');
  static const VerificationMeta _qtyPcsMeta = const VerificationMeta('qtyPcs');
  @override
  late final GeneratedColumn<int> qtyPcs = GeneratedColumn<int>(
      'qty_pcs', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hargaJualPerPcsMeta =
      const VerificationMeta('hargaJualPerPcs');
  @override
  late final GeneratedColumn<double> hargaJualPerPcs = GeneratedColumn<double>(
      'harga_jual_per_pcs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _hppSnapshotMeta =
      const VerificationMeta('hppSnapshot');
  @override
  late final GeneratedColumn<double> hppSnapshot = GeneratedColumn<double>(
      'hpp_snapshot', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _labaMeta = const VerificationMeta('laba');
  @override
  late final GeneratedColumn<double> laba = GeneratedColumn<double>(
      'laba', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _tipeMeta = const VerificationMeta('tipe');
  @override
  late final GeneratedColumn<String> tipe = GeneratedColumn<String>(
      'tipe', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ecer'));
  static const VerificationMeta _tanggalMeta =
      const VerificationMeta('tanggal');
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
      'tanggal', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, barangId, qtyPcs, hargaJualPerPcs, hppSnapshot, laba, tipe, tanggal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'penjualan';
  @override
  VerificationContext validateIntegrity(Insertable<PenjualanData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barang_id')) {
      context.handle(_barangIdMeta,
          barangId.isAcceptableOrUnknown(data['barang_id']!, _barangIdMeta));
    } else if (isInserting) {
      context.missing(_barangIdMeta);
    }
    if (data.containsKey('qty_pcs')) {
      context.handle(_qtyPcsMeta,
          qtyPcs.isAcceptableOrUnknown(data['qty_pcs']!, _qtyPcsMeta));
    } else if (isInserting) {
      context.missing(_qtyPcsMeta);
    }
    if (data.containsKey('harga_jual_per_pcs')) {
      context.handle(
          _hargaJualPerPcsMeta,
          hargaJualPerPcs.isAcceptableOrUnknown(
              data['harga_jual_per_pcs']!, _hargaJualPerPcsMeta));
    } else if (isInserting) {
      context.missing(_hargaJualPerPcsMeta);
    }
    if (data.containsKey('hpp_snapshot')) {
      context.handle(
          _hppSnapshotMeta,
          hppSnapshot.isAcceptableOrUnknown(
              data['hpp_snapshot']!, _hppSnapshotMeta));
    } else if (isInserting) {
      context.missing(_hppSnapshotMeta);
    }
    if (data.containsKey('laba')) {
      context.handle(
          _labaMeta, laba.isAcceptableOrUnknown(data['laba']!, _labaMeta));
    } else if (isInserting) {
      context.missing(_labaMeta);
    }
    if (data.containsKey('tipe')) {
      context.handle(
          _tipeMeta, tipe.isAcceptableOrUnknown(data['tipe']!, _tipeMeta));
    }
    if (data.containsKey('tanggal')) {
      context.handle(_tanggalMeta,
          tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PenjualanData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PenjualanData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      barangId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}barang_id'])!,
      qtyPcs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_pcs'])!,
      hargaJualPerPcs: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}harga_jual_per_pcs'])!,
      hppSnapshot: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}hpp_snapshot'])!,
      laba: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}laba'])!,
      tipe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipe'])!,
      tanggal: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}tanggal'])!,
    );
  }

  @override
  $PenjualanTable createAlias(String alias) {
    return $PenjualanTable(attachedDatabase, alias);
  }
}

class PenjualanData extends DataClass implements Insertable<PenjualanData> {
  final int id;
  final int barangId;
  final int qtyPcs;
  final double hargaJualPerPcs;
  final double hppSnapshot;
  final double laba;
  final String tipe;
  final DateTime tanggal;
  const PenjualanData(
      {required this.id,
      required this.barangId,
      required this.qtyPcs,
      required this.hargaJualPerPcs,
      required this.hppSnapshot,
      required this.laba,
      required this.tipe,
      required this.tanggal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barang_id'] = Variable<int>(barangId);
    map['qty_pcs'] = Variable<int>(qtyPcs);
    map['harga_jual_per_pcs'] = Variable<double>(hargaJualPerPcs);
    map['hpp_snapshot'] = Variable<double>(hppSnapshot);
    map['laba'] = Variable<double>(laba);
    map['tipe'] = Variable<String>(tipe);
    map['tanggal'] = Variable<DateTime>(tanggal);
    return map;
  }

  PenjualanCompanion toCompanion(bool nullToAbsent) {
    return PenjualanCompanion(
      id: Value(id),
      barangId: Value(barangId),
      qtyPcs: Value(qtyPcs),
      hargaJualPerPcs: Value(hargaJualPerPcs),
      hppSnapshot: Value(hppSnapshot),
      laba: Value(laba),
      tipe: Value(tipe),
      tanggal: Value(tanggal),
    );
  }

  factory PenjualanData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PenjualanData(
      id: serializer.fromJson<int>(json['id']),
      barangId: serializer.fromJson<int>(json['barangId']),
      qtyPcs: serializer.fromJson<int>(json['qtyPcs']),
      hargaJualPerPcs: serializer.fromJson<double>(json['hargaJualPerPcs']),
      hppSnapshot: serializer.fromJson<double>(json['hppSnapshot']),
      laba: serializer.fromJson<double>(json['laba']),
      tipe: serializer.fromJson<String>(json['tipe']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barangId': serializer.toJson<int>(barangId),
      'qtyPcs': serializer.toJson<int>(qtyPcs),
      'hargaJualPerPcs': serializer.toJson<double>(hargaJualPerPcs),
      'hppSnapshot': serializer.toJson<double>(hppSnapshot),
      'laba': serializer.toJson<double>(laba),
      'tipe': serializer.toJson<String>(tipe),
      'tanggal': serializer.toJson<DateTime>(tanggal),
    };
  }

  PenjualanData copyWith(
          {int? id,
          int? barangId,
          int? qtyPcs,
          double? hargaJualPerPcs,
          double? hppSnapshot,
          double? laba,
          String? tipe,
          DateTime? tanggal}) =>
      PenjualanData(
        id: id ?? this.id,
        barangId: barangId ?? this.barangId,
        qtyPcs: qtyPcs ?? this.qtyPcs,
        hargaJualPerPcs: hargaJualPerPcs ?? this.hargaJualPerPcs,
        hppSnapshot: hppSnapshot ?? this.hppSnapshot,
        laba: laba ?? this.laba,
        tipe: tipe ?? this.tipe,
        tanggal: tanggal ?? this.tanggal,
      );
  PenjualanData copyWithCompanion(PenjualanCompanion data) {
    return PenjualanData(
      id: data.id.present ? data.id.value : this.id,
      barangId: data.barangId.present ? data.barangId.value : this.barangId,
      qtyPcs: data.qtyPcs.present ? data.qtyPcs.value : this.qtyPcs,
      hargaJualPerPcs: data.hargaJualPerPcs.present
          ? data.hargaJualPerPcs.value
          : this.hargaJualPerPcs,
      hppSnapshot:
          data.hppSnapshot.present ? data.hppSnapshot.value : this.hppSnapshot,
      laba: data.laba.present ? data.laba.value : this.laba,
      tipe: data.tipe.present ? data.tipe.value : this.tipe,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PenjualanData(')
          ..write('id: $id, ')
          ..write('barangId: $barangId, ')
          ..write('qtyPcs: $qtyPcs, ')
          ..write('hargaJualPerPcs: $hargaJualPerPcs, ')
          ..write('hppSnapshot: $hppSnapshot, ')
          ..write('laba: $laba, ')
          ..write('tipe: $tipe, ')
          ..write('tanggal: $tanggal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, barangId, qtyPcs, hargaJualPerPcs, hppSnapshot, laba, tipe, tanggal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PenjualanData &&
          other.id == this.id &&
          other.barangId == this.barangId &&
          other.qtyPcs == this.qtyPcs &&
          other.hargaJualPerPcs == this.hargaJualPerPcs &&
          other.hppSnapshot == this.hppSnapshot &&
          other.laba == this.laba &&
          other.tipe == this.tipe &&
          other.tanggal == this.tanggal);
}

class PenjualanCompanion extends UpdateCompanion<PenjualanData> {
  final Value<int> id;
  final Value<int> barangId;
  final Value<int> qtyPcs;
  final Value<double> hargaJualPerPcs;
  final Value<double> hppSnapshot;
  final Value<double> laba;
  final Value<String> tipe;
  final Value<DateTime> tanggal;
  const PenjualanCompanion({
    this.id = const Value.absent(),
    this.barangId = const Value.absent(),
    this.qtyPcs = const Value.absent(),
    this.hargaJualPerPcs = const Value.absent(),
    this.hppSnapshot = const Value.absent(),
    this.laba = const Value.absent(),
    this.tipe = const Value.absent(),
    this.tanggal = const Value.absent(),
  });
  PenjualanCompanion.insert({
    this.id = const Value.absent(),
    required int barangId,
    required int qtyPcs,
    required double hargaJualPerPcs,
    required double hppSnapshot,
    required double laba,
    this.tipe = const Value.absent(),
    this.tanggal = const Value.absent(),
  })  : barangId = Value(barangId),
        qtyPcs = Value(qtyPcs),
        hargaJualPerPcs = Value(hargaJualPerPcs),
        hppSnapshot = Value(hppSnapshot),
        laba = Value(laba);
  static Insertable<PenjualanData> custom({
    Expression<int>? id,
    Expression<int>? barangId,
    Expression<int>? qtyPcs,
    Expression<double>? hargaJualPerPcs,
    Expression<double>? hppSnapshot,
    Expression<double>? laba,
    Expression<String>? tipe,
    Expression<DateTime>? tanggal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barangId != null) 'barang_id': barangId,
      if (qtyPcs != null) 'qty_pcs': qtyPcs,
      if (hargaJualPerPcs != null) 'harga_jual_per_pcs': hargaJualPerPcs,
      if (hppSnapshot != null) 'hpp_snapshot': hppSnapshot,
      if (laba != null) 'laba': laba,
      if (tipe != null) 'tipe': tipe,
      if (tanggal != null) 'tanggal': tanggal,
    });
  }

  PenjualanCompanion copyWith(
      {Value<int>? id,
      Value<int>? barangId,
      Value<int>? qtyPcs,
      Value<double>? hargaJualPerPcs,
      Value<double>? hppSnapshot,
      Value<double>? laba,
      Value<String>? tipe,
      Value<DateTime>? tanggal}) {
    return PenjualanCompanion(
      id: id ?? this.id,
      barangId: barangId ?? this.barangId,
      qtyPcs: qtyPcs ?? this.qtyPcs,
      hargaJualPerPcs: hargaJualPerPcs ?? this.hargaJualPerPcs,
      hppSnapshot: hppSnapshot ?? this.hppSnapshot,
      laba: laba ?? this.laba,
      tipe: tipe ?? this.tipe,
      tanggal: tanggal ?? this.tanggal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barangId.present) {
      map['barang_id'] = Variable<int>(barangId.value);
    }
    if (qtyPcs.present) {
      map['qty_pcs'] = Variable<int>(qtyPcs.value);
    }
    if (hargaJualPerPcs.present) {
      map['harga_jual_per_pcs'] = Variable<double>(hargaJualPerPcs.value);
    }
    if (hppSnapshot.present) {
      map['hpp_snapshot'] = Variable<double>(hppSnapshot.value);
    }
    if (laba.present) {
      map['laba'] = Variable<double>(laba.value);
    }
    if (tipe.present) {
      map['tipe'] = Variable<String>(tipe.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PenjualanCompanion(')
          ..write('id: $id, ')
          ..write('barangId: $barangId, ')
          ..write('qtyPcs: $qtyPcs, ')
          ..write('hargaJualPerPcs: $hargaJualPerPcs, ')
          ..write('hppSnapshot: $hppSnapshot, ')
          ..write('laba: $laba, ')
          ..write('tipe: $tipe, ')
          ..write('tanggal: $tanggal')
          ..write(')'))
        .toString();
  }
}

class $KartuStokTable extends KartuStok
    with TableInfo<$KartuStokTable, KartuStokData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KartuStokTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _barangIdMeta =
      const VerificationMeta('barangId');
  @override
  late final GeneratedColumn<int> barangId = GeneratedColumn<int>(
      'barang_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES barang(id) ON DELETE CASCADE');
  static const VerificationMeta _tipeMeta = const VerificationMeta('tipe');
  @override
  late final GeneratedColumn<String> tipe = GeneratedColumn<String>(
      'tipe', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
      'qty', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _qtySisaLogMeta =
      const VerificationMeta('qtySisaLog');
  @override
  late final GeneratedColumn<int> qtySisaLog = GeneratedColumn<int>(
      'qty_sisa_log', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _stokAkhirMeta =
      const VerificationMeta('stokAkhir');
  @override
  late final GeneratedColumn<int> stokAkhir = GeneratedColumn<int>(
      'stok_akhir', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hargaBeliSaatItuMeta =
      const VerificationMeta('hargaBeliSaatItu');
  @override
  late final GeneratedColumn<double> hargaBeliSaatItu = GeneratedColumn<double>(
      'harga_beli_saat_itu', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
      'ref_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tanggalMeta =
      const VerificationMeta('tanggal');
  @override
  late final GeneratedColumn<DateTime> tanggal = GeneratedColumn<DateTime>(
      'tanggal', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        barangId,
        tipe,
        qty,
        qtySisaLog,
        stokAkhir,
        hargaBeliSaatItu,
        refId,
        tanggal
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kartu_stok';
  @override
  VerificationContext validateIntegrity(Insertable<KartuStokData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barang_id')) {
      context.handle(_barangIdMeta,
          barangId.isAcceptableOrUnknown(data['barang_id']!, _barangIdMeta));
    } else if (isInserting) {
      context.missing(_barangIdMeta);
    }
    if (data.containsKey('tipe')) {
      context.handle(
          _tipeMeta, tipe.isAcceptableOrUnknown(data['tipe']!, _tipeMeta));
    } else if (isInserting) {
      context.missing(_tipeMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
          _qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('qty_sisa_log')) {
      context.handle(
          _qtySisaLogMeta,
          qtySisaLog.isAcceptableOrUnknown(
              data['qty_sisa_log']!, _qtySisaLogMeta));
    }
    if (data.containsKey('stok_akhir')) {
      context.handle(_stokAkhirMeta,
          stokAkhir.isAcceptableOrUnknown(data['stok_akhir']!, _stokAkhirMeta));
    } else if (isInserting) {
      context.missing(_stokAkhirMeta);
    }
    if (data.containsKey('harga_beli_saat_itu')) {
      context.handle(
          _hargaBeliSaatItuMeta,
          hargaBeliSaatItu.isAcceptableOrUnknown(
              data['harga_beli_saat_itu']!, _hargaBeliSaatItuMeta));
    }
    if (data.containsKey('ref_id')) {
      context.handle(
          _refIdMeta, refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta));
    }
    if (data.containsKey('tanggal')) {
      context.handle(_tanggalMeta,
          tanggal.isAcceptableOrUnknown(data['tanggal']!, _tanggalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KartuStokData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KartuStokData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      barangId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}barang_id'])!,
      tipe: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tipe'])!,
      qty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty'])!,
      qtySisaLog: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_sisa_log'])!,
      stokAkhir: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stok_akhir'])!,
      hargaBeliSaatItu: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}harga_beli_saat_itu'])!,
      refId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ref_id']),
      tanggal: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}tanggal'])!,
    );
  }

  @override
  $KartuStokTable createAlias(String alias) {
    return $KartuStokTable(attachedDatabase, alias);
  }
}

class KartuStokData extends DataClass implements Insertable<KartuStokData> {
  final int id;
  final int barangId;
  final String tipe;
  final int qty;
  final int qtySisaLog;
  final int stokAkhir;
  final double hargaBeliSaatItu;
  final String? refId;
  final DateTime tanggal;
  const KartuStokData(
      {required this.id,
      required this.barangId,
      required this.tipe,
      required this.qty,
      required this.qtySisaLog,
      required this.stokAkhir,
      required this.hargaBeliSaatItu,
      this.refId,
      required this.tanggal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barang_id'] = Variable<int>(barangId);
    map['tipe'] = Variable<String>(tipe);
    map['qty'] = Variable<int>(qty);
    map['qty_sisa_log'] = Variable<int>(qtySisaLog);
    map['stok_akhir'] = Variable<int>(stokAkhir);
    map['harga_beli_saat_itu'] = Variable<double>(hargaBeliSaatItu);
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    map['tanggal'] = Variable<DateTime>(tanggal);
    return map;
  }

  KartuStokCompanion toCompanion(bool nullToAbsent) {
    return KartuStokCompanion(
      id: Value(id),
      barangId: Value(barangId),
      tipe: Value(tipe),
      qty: Value(qty),
      qtySisaLog: Value(qtySisaLog),
      stokAkhir: Value(stokAkhir),
      hargaBeliSaatItu: Value(hargaBeliSaatItu),
      refId:
          refId == null && nullToAbsent ? const Value.absent() : Value(refId),
      tanggal: Value(tanggal),
    );
  }

  factory KartuStokData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KartuStokData(
      id: serializer.fromJson<int>(json['id']),
      barangId: serializer.fromJson<int>(json['barangId']),
      tipe: serializer.fromJson<String>(json['tipe']),
      qty: serializer.fromJson<int>(json['qty']),
      qtySisaLog: serializer.fromJson<int>(json['qtySisaLog']),
      stokAkhir: serializer.fromJson<int>(json['stokAkhir']),
      hargaBeliSaatItu: serializer.fromJson<double>(json['hargaBeliSaatItu']),
      refId: serializer.fromJson<String?>(json['refId']),
      tanggal: serializer.fromJson<DateTime>(json['tanggal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barangId': serializer.toJson<int>(barangId),
      'tipe': serializer.toJson<String>(tipe),
      'qty': serializer.toJson<int>(qty),
      'qtySisaLog': serializer.toJson<int>(qtySisaLog),
      'stokAkhir': serializer.toJson<int>(stokAkhir),
      'hargaBeliSaatItu': serializer.toJson<double>(hargaBeliSaatItu),
      'refId': serializer.toJson<String?>(refId),
      'tanggal': serializer.toJson<DateTime>(tanggal),
    };
  }

  KartuStokData copyWith(
          {int? id,
          int? barangId,
          String? tipe,
          int? qty,
          int? qtySisaLog,
          int? stokAkhir,
          double? hargaBeliSaatItu,
          Value<String?> refId = const Value.absent(),
          DateTime? tanggal}) =>
      KartuStokData(
        id: id ?? this.id,
        barangId: barangId ?? this.barangId,
        tipe: tipe ?? this.tipe,
        qty: qty ?? this.qty,
        qtySisaLog: qtySisaLog ?? this.qtySisaLog,
        stokAkhir: stokAkhir ?? this.stokAkhir,
        hargaBeliSaatItu: hargaBeliSaatItu ?? this.hargaBeliSaatItu,
        refId: refId.present ? refId.value : this.refId,
        tanggal: tanggal ?? this.tanggal,
      );
  KartuStokData copyWithCompanion(KartuStokCompanion data) {
    return KartuStokData(
      id: data.id.present ? data.id.value : this.id,
      barangId: data.barangId.present ? data.barangId.value : this.barangId,
      tipe: data.tipe.present ? data.tipe.value : this.tipe,
      qty: data.qty.present ? data.qty.value : this.qty,
      qtySisaLog:
          data.qtySisaLog.present ? data.qtySisaLog.value : this.qtySisaLog,
      stokAkhir: data.stokAkhir.present ? data.stokAkhir.value : this.stokAkhir,
      hargaBeliSaatItu: data.hargaBeliSaatItu.present
          ? data.hargaBeliSaatItu.value
          : this.hargaBeliSaatItu,
      refId: data.refId.present ? data.refId.value : this.refId,
      tanggal: data.tanggal.present ? data.tanggal.value : this.tanggal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KartuStokData(')
          ..write('id: $id, ')
          ..write('barangId: $barangId, ')
          ..write('tipe: $tipe, ')
          ..write('qty: $qty, ')
          ..write('qtySisaLog: $qtySisaLog, ')
          ..write('stokAkhir: $stokAkhir, ')
          ..write('hargaBeliSaatItu: $hargaBeliSaatItu, ')
          ..write('refId: $refId, ')
          ..write('tanggal: $tanggal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, barangId, tipe, qty, qtySisaLog,
      stokAkhir, hargaBeliSaatItu, refId, tanggal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KartuStokData &&
          other.id == this.id &&
          other.barangId == this.barangId &&
          other.tipe == this.tipe &&
          other.qty == this.qty &&
          other.qtySisaLog == this.qtySisaLog &&
          other.stokAkhir == this.stokAkhir &&
          other.hargaBeliSaatItu == this.hargaBeliSaatItu &&
          other.refId == this.refId &&
          other.tanggal == this.tanggal);
}

class KartuStokCompanion extends UpdateCompanion<KartuStokData> {
  final Value<int> id;
  final Value<int> barangId;
  final Value<String> tipe;
  final Value<int> qty;
  final Value<int> qtySisaLog;
  final Value<int> stokAkhir;
  final Value<double> hargaBeliSaatItu;
  final Value<String?> refId;
  final Value<DateTime> tanggal;
  const KartuStokCompanion({
    this.id = const Value.absent(),
    this.barangId = const Value.absent(),
    this.tipe = const Value.absent(),
    this.qty = const Value.absent(),
    this.qtySisaLog = const Value.absent(),
    this.stokAkhir = const Value.absent(),
    this.hargaBeliSaatItu = const Value.absent(),
    this.refId = const Value.absent(),
    this.tanggal = const Value.absent(),
  });
  KartuStokCompanion.insert({
    this.id = const Value.absent(),
    required int barangId,
    required String tipe,
    required int qty,
    this.qtySisaLog = const Value.absent(),
    required int stokAkhir,
    this.hargaBeliSaatItu = const Value.absent(),
    this.refId = const Value.absent(),
    this.tanggal = const Value.absent(),
  })  : barangId = Value(barangId),
        tipe = Value(tipe),
        qty = Value(qty),
        stokAkhir = Value(stokAkhir);
  static Insertable<KartuStokData> custom({
    Expression<int>? id,
    Expression<int>? barangId,
    Expression<String>? tipe,
    Expression<int>? qty,
    Expression<int>? qtySisaLog,
    Expression<int>? stokAkhir,
    Expression<double>? hargaBeliSaatItu,
    Expression<String>? refId,
    Expression<DateTime>? tanggal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barangId != null) 'barang_id': barangId,
      if (tipe != null) 'tipe': tipe,
      if (qty != null) 'qty': qty,
      if (qtySisaLog != null) 'qty_sisa_log': qtySisaLog,
      if (stokAkhir != null) 'stok_akhir': stokAkhir,
      if (hargaBeliSaatItu != null) 'harga_beli_saat_itu': hargaBeliSaatItu,
      if (refId != null) 'ref_id': refId,
      if (tanggal != null) 'tanggal': tanggal,
    });
  }

  KartuStokCompanion copyWith(
      {Value<int>? id,
      Value<int>? barangId,
      Value<String>? tipe,
      Value<int>? qty,
      Value<int>? qtySisaLog,
      Value<int>? stokAkhir,
      Value<double>? hargaBeliSaatItu,
      Value<String?>? refId,
      Value<DateTime>? tanggal}) {
    return KartuStokCompanion(
      id: id ?? this.id,
      barangId: barangId ?? this.barangId,
      tipe: tipe ?? this.tipe,
      qty: qty ?? this.qty,
      qtySisaLog: qtySisaLog ?? this.qtySisaLog,
      stokAkhir: stokAkhir ?? this.stokAkhir,
      hargaBeliSaatItu: hargaBeliSaatItu ?? this.hargaBeliSaatItu,
      refId: refId ?? this.refId,
      tanggal: tanggal ?? this.tanggal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barangId.present) {
      map['barang_id'] = Variable<int>(barangId.value);
    }
    if (tipe.present) {
      map['tipe'] = Variable<String>(tipe.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (qtySisaLog.present) {
      map['qty_sisa_log'] = Variable<int>(qtySisaLog.value);
    }
    if (stokAkhir.present) {
      map['stok_akhir'] = Variable<int>(stokAkhir.value);
    }
    if (hargaBeliSaatItu.present) {
      map['harga_beli_saat_itu'] = Variable<double>(hargaBeliSaatItu.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
    }
    if (tanggal.present) {
      map['tanggal'] = Variable<DateTime>(tanggal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KartuStokCompanion(')
          ..write('id: $id, ')
          ..write('barangId: $barangId, ')
          ..write('tipe: $tipe, ')
          ..write('qty: $qty, ')
          ..write('qtySisaLog: $qtySisaLog, ')
          ..write('stokAkhir: $stokAkhir, ')
          ..write('hargaBeliSaatItu: $hargaBeliSaatItu, ')
          ..write('refId: $refId, ')
          ..write('tanggal: $tanggal')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $BarangTable barang = $BarangTable(this);
  late final $PembelianTable pembelian = $PembelianTable(this);
  late final $PenjualanTable penjualan = $PenjualanTable(this);
  late final $KartuStokTable kartuStok = $KartuStokTable(this);
  late final BarangDao barangDao = BarangDao(this as LocalDatabase);
  late final TransaksiDao transaksiDao = TransaksiDao(this as LocalDatabase);
  late final LaporanDao laporanDao = LaporanDao(this as LocalDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [barang, pembelian, penjualan, kartuStok];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('barang',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('pembelian', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('barang',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('penjualan', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('barang',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('kartu_stok', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$BarangTableCreateCompanionBuilder = BarangCompanion Function({
  Value<int> id,
  required String sku,
  required String nama,
  Value<String?> merek,
  Value<String> satuanTerkecil,
  Value<String> satuanBesar,
  Value<int> konversi,
  Value<double> hppAverage,
  Value<double> hargaEcer,
  Value<double> hargaAgen,
  Value<int> stok,
  Value<int> safetyStock,
  Value<DateTime> updatedAt,
});
typedef $$BarangTableUpdateCompanionBuilder = BarangCompanion Function({
  Value<int> id,
  Value<String> sku,
  Value<String> nama,
  Value<String?> merek,
  Value<String> satuanTerkecil,
  Value<String> satuanBesar,
  Value<int> konversi,
  Value<double> hppAverage,
  Value<double> hargaEcer,
  Value<double> hargaAgen,
  Value<int> stok,
  Value<int> safetyStock,
  Value<DateTime> updatedAt,
});

final class $$BarangTableReferences
    extends BaseReferences<_$LocalDatabase, $BarangTable, BarangData> {
  $$BarangTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PembelianTable, List<PembelianData>>
      _pembelianRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
          db.pembelian,
          aliasName: $_aliasNameGenerator(db.barang.id, db.pembelian.barangId));

  $$PembelianTableProcessedTableManager get pembelianRefs {
    final manager = $$PembelianTableTableManager($_db, $_db.pembelian)
        .filter((f) => f.barangId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pembelianRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PenjualanTable, List<PenjualanData>>
      _penjualanRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
          db.penjualan,
          aliasName: $_aliasNameGenerator(db.barang.id, db.penjualan.barangId));

  $$PenjualanTableProcessedTableManager get penjualanRefs {
    final manager = $$PenjualanTableTableManager($_db, $_db.penjualan)
        .filter((f) => f.barangId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_penjualanRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$KartuStokTable, List<KartuStokData>>
      _kartuStokRefsTable(_$LocalDatabase db) => MultiTypedResultKey.fromTable(
          db.kartuStok,
          aliasName: $_aliasNameGenerator(db.barang.id, db.kartuStok.barangId));

  $$KartuStokTableProcessedTableManager get kartuStokRefs {
    final manager = $$KartuStokTableTableManager($_db, $_db.kartuStok)
        .filter((f) => f.barangId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_kartuStokRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BarangTableFilterComposer
    extends Composer<_$LocalDatabase, $BarangTable> {
  $$BarangTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get merek => $composableBuilder(
      column: $table.merek, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get satuanTerkecil => $composableBuilder(
      column: $table.satuanTerkecil,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get satuanBesar => $composableBuilder(
      column: $table.satuanBesar, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get konversi => $composableBuilder(
      column: $table.konversi, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hppAverage => $composableBuilder(
      column: $table.hppAverage, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hargaEcer => $composableBuilder(
      column: $table.hargaEcer, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hargaAgen => $composableBuilder(
      column: $table.hargaAgen, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stok => $composableBuilder(
      column: $table.stok, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get safetyStock => $composableBuilder(
      column: $table.safetyStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> pembelianRefs(
      Expression<bool> Function($$PembelianTableFilterComposer f) f) {
    final $$PembelianTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pembelian,
        getReferencedColumn: (t) => t.barangId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PembelianTableFilterComposer(
              $db: $db,
              $table: $db.pembelian,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> penjualanRefs(
      Expression<bool> Function($$PenjualanTableFilterComposer f) f) {
    final $$PenjualanTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.penjualan,
        getReferencedColumn: (t) => t.barangId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PenjualanTableFilterComposer(
              $db: $db,
              $table: $db.penjualan,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> kartuStokRefs(
      Expression<bool> Function($$KartuStokTableFilterComposer f) f) {
    final $$KartuStokTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.kartuStok,
        getReferencedColumn: (t) => t.barangId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KartuStokTableFilterComposer(
              $db: $db,
              $table: $db.kartuStok,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BarangTableOrderingComposer
    extends Composer<_$LocalDatabase, $BarangTable> {
  $$BarangTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nama => $composableBuilder(
      column: $table.nama, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get merek => $composableBuilder(
      column: $table.merek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get satuanTerkecil => $composableBuilder(
      column: $table.satuanTerkecil,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get satuanBesar => $composableBuilder(
      column: $table.satuanBesar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get konversi => $composableBuilder(
      column: $table.konversi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hppAverage => $composableBuilder(
      column: $table.hppAverage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hargaEcer => $composableBuilder(
      column: $table.hargaEcer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hargaAgen => $composableBuilder(
      column: $table.hargaAgen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stok => $composableBuilder(
      column: $table.stok, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get safetyStock => $composableBuilder(
      column: $table.safetyStock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$BarangTableAnnotationComposer
    extends Composer<_$LocalDatabase, $BarangTable> {
  $$BarangTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get nama =>
      $composableBuilder(column: $table.nama, builder: (column) => column);

  GeneratedColumn<String> get merek =>
      $composableBuilder(column: $table.merek, builder: (column) => column);

  GeneratedColumn<String> get satuanTerkecil => $composableBuilder(
      column: $table.satuanTerkecil, builder: (column) => column);

  GeneratedColumn<String> get satuanBesar => $composableBuilder(
      column: $table.satuanBesar, builder: (column) => column);

  GeneratedColumn<int> get konversi =>
      $composableBuilder(column: $table.konversi, builder: (column) => column);

  GeneratedColumn<double> get hppAverage => $composableBuilder(
      column: $table.hppAverage, builder: (column) => column);

  GeneratedColumn<double> get hargaEcer =>
      $composableBuilder(column: $table.hargaEcer, builder: (column) => column);

  GeneratedColumn<double> get hargaAgen =>
      $composableBuilder(column: $table.hargaAgen, builder: (column) => column);

  GeneratedColumn<int> get stok =>
      $composableBuilder(column: $table.stok, builder: (column) => column);

  GeneratedColumn<int> get safetyStock => $composableBuilder(
      column: $table.safetyStock, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> pembelianRefs<T extends Object>(
      Expression<T> Function($$PembelianTableAnnotationComposer a) f) {
    final $$PembelianTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pembelian,
        getReferencedColumn: (t) => t.barangId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PembelianTableAnnotationComposer(
              $db: $db,
              $table: $db.pembelian,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> penjualanRefs<T extends Object>(
      Expression<T> Function($$PenjualanTableAnnotationComposer a) f) {
    final $$PenjualanTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.penjualan,
        getReferencedColumn: (t) => t.barangId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PenjualanTableAnnotationComposer(
              $db: $db,
              $table: $db.penjualan,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> kartuStokRefs<T extends Object>(
      Expression<T> Function($$KartuStokTableAnnotationComposer a) f) {
    final $$KartuStokTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.kartuStok,
        getReferencedColumn: (t) => t.barangId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$KartuStokTableAnnotationComposer(
              $db: $db,
              $table: $db.kartuStok,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BarangTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $BarangTable,
    BarangData,
    $$BarangTableFilterComposer,
    $$BarangTableOrderingComposer,
    $$BarangTableAnnotationComposer,
    $$BarangTableCreateCompanionBuilder,
    $$BarangTableUpdateCompanionBuilder,
    (BarangData, $$BarangTableReferences),
    BarangData,
    PrefetchHooks Function(
        {bool pembelianRefs, bool penjualanRefs, bool kartuStokRefs})> {
  $$BarangTableTableManager(_$LocalDatabase db, $BarangTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarangTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarangTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarangTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<String> nama = const Value.absent(),
            Value<String?> merek = const Value.absent(),
            Value<String> satuanTerkecil = const Value.absent(),
            Value<String> satuanBesar = const Value.absent(),
            Value<int> konversi = const Value.absent(),
            Value<double> hppAverage = const Value.absent(),
            Value<double> hargaEcer = const Value.absent(),
            Value<double> hargaAgen = const Value.absent(),
            Value<int> stok = const Value.absent(),
            Value<int> safetyStock = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BarangCompanion(
            id: id,
            sku: sku,
            nama: nama,
            merek: merek,
            satuanTerkecil: satuanTerkecil,
            satuanBesar: satuanBesar,
            konversi: konversi,
            hppAverage: hppAverage,
            hargaEcer: hargaEcer,
            hargaAgen: hargaAgen,
            stok: stok,
            safetyStock: safetyStock,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sku,
            required String nama,
            Value<String?> merek = const Value.absent(),
            Value<String> satuanTerkecil = const Value.absent(),
            Value<String> satuanBesar = const Value.absent(),
            Value<int> konversi = const Value.absent(),
            Value<double> hppAverage = const Value.absent(),
            Value<double> hargaEcer = const Value.absent(),
            Value<double> hargaAgen = const Value.absent(),
            Value<int> stok = const Value.absent(),
            Value<int> safetyStock = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BarangCompanion.insert(
            id: id,
            sku: sku,
            nama: nama,
            merek: merek,
            satuanTerkecil: satuanTerkecil,
            satuanBesar: satuanBesar,
            konversi: konversi,
            hppAverage: hppAverage,
            hargaEcer: hargaEcer,
            hargaAgen: hargaAgen,
            stok: stok,
            safetyStock: safetyStock,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BarangTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {pembelianRefs = false,
              penjualanRefs = false,
              kartuStokRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pembelianRefs) db.pembelian,
                if (penjualanRefs) db.penjualan,
                if (kartuStokRefs) db.kartuStok
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pembelianRefs)
                    await $_getPrefetchedData<BarangData, $BarangTable,
                            PembelianData>(
                        currentTable: table,
                        referencedTable:
                            $$BarangTableReferences._pembelianRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BarangTableReferences(db, table, p0)
                                .pembelianRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.barangId == item.id),
                        typedResults: items),
                  if (penjualanRefs)
                    await $_getPrefetchedData<BarangData, $BarangTable,
                            PenjualanData>(
                        currentTable: table,
                        referencedTable:
                            $$BarangTableReferences._penjualanRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BarangTableReferences(db, table, p0)
                                .penjualanRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.barangId == item.id),
                        typedResults: items),
                  if (kartuStokRefs)
                    await $_getPrefetchedData<BarangData, $BarangTable,
                            KartuStokData>(
                        currentTable: table,
                        referencedTable:
                            $$BarangTableReferences._kartuStokRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BarangTableReferences(db, table, p0)
                                .kartuStokRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.barangId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BarangTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $BarangTable,
    BarangData,
    $$BarangTableFilterComposer,
    $$BarangTableOrderingComposer,
    $$BarangTableAnnotationComposer,
    $$BarangTableCreateCompanionBuilder,
    $$BarangTableUpdateCompanionBuilder,
    (BarangData, $$BarangTableReferences),
    BarangData,
    PrefetchHooks Function(
        {bool pembelianRefs, bool penjualanRefs, bool kartuStokRefs})>;
typedef $$PembelianTableCreateCompanionBuilder = PembelianCompanion Function({
  Value<int> id,
  required int barangId,
  required int qtyPcs,
  required double hargaBeliPerPcs,
  Value<String?> supplier,
  Value<DateTime> tanggal,
});
typedef $$PembelianTableUpdateCompanionBuilder = PembelianCompanion Function({
  Value<int> id,
  Value<int> barangId,
  Value<int> qtyPcs,
  Value<double> hargaBeliPerPcs,
  Value<String?> supplier,
  Value<DateTime> tanggal,
});

final class $$PembelianTableReferences
    extends BaseReferences<_$LocalDatabase, $PembelianTable, PembelianData> {
  $$PembelianTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BarangTable _barangIdTable(_$LocalDatabase db) => db.barang
      .createAlias($_aliasNameGenerator(db.pembelian.barangId, db.barang.id));

  $$BarangTableProcessedTableManager get barangId {
    final $_column = $_itemColumn<int>('barang_id')!;

    final manager = $$BarangTableTableManager($_db, $_db.barang)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_barangIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PembelianTableFilterComposer
    extends Composer<_$LocalDatabase, $PembelianTable> {
  $$PembelianTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyPcs => $composableBuilder(
      column: $table.qtyPcs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hargaBeliPerPcs => $composableBuilder(
      column: $table.hargaBeliPerPcs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
      column: $table.tanggal, builder: (column) => ColumnFilters(column));

  $$BarangTableFilterComposer get barangId {
    final $$BarangTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.barangId,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableFilterComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PembelianTableOrderingComposer
    extends Composer<_$LocalDatabase, $PembelianTable> {
  $$PembelianTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyPcs => $composableBuilder(
      column: $table.qtyPcs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hargaBeliPerPcs => $composableBuilder(
      column: $table.hargaBeliPerPcs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
      column: $table.tanggal, builder: (column) => ColumnOrderings(column));

  $$BarangTableOrderingComposer get barangId {
    final $$BarangTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.barangId,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableOrderingComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PembelianTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PembelianTable> {
  $$PembelianTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get qtyPcs =>
      $composableBuilder(column: $table.qtyPcs, builder: (column) => column);

  GeneratedColumn<double> get hargaBeliPerPcs => $composableBuilder(
      column: $table.hargaBeliPerPcs, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  $$BarangTableAnnotationComposer get barangId {
    final $$BarangTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.barangId,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableAnnotationComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PembelianTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $PembelianTable,
    PembelianData,
    $$PembelianTableFilterComposer,
    $$PembelianTableOrderingComposer,
    $$PembelianTableAnnotationComposer,
    $$PembelianTableCreateCompanionBuilder,
    $$PembelianTableUpdateCompanionBuilder,
    (PembelianData, $$PembelianTableReferences),
    PembelianData,
    PrefetchHooks Function({bool barangId})> {
  $$PembelianTableTableManager(_$LocalDatabase db, $PembelianTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PembelianTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PembelianTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PembelianTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> barangId = const Value.absent(),
            Value<int> qtyPcs = const Value.absent(),
            Value<double> hargaBeliPerPcs = const Value.absent(),
            Value<String?> supplier = const Value.absent(),
            Value<DateTime> tanggal = const Value.absent(),
          }) =>
              PembelianCompanion(
            id: id,
            barangId: barangId,
            qtyPcs: qtyPcs,
            hargaBeliPerPcs: hargaBeliPerPcs,
            supplier: supplier,
            tanggal: tanggal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int barangId,
            required int qtyPcs,
            required double hargaBeliPerPcs,
            Value<String?> supplier = const Value.absent(),
            Value<DateTime> tanggal = const Value.absent(),
          }) =>
              PembelianCompanion.insert(
            id: id,
            barangId: barangId,
            qtyPcs: qtyPcs,
            hargaBeliPerPcs: hargaBeliPerPcs,
            supplier: supplier,
            tanggal: tanggal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PembelianTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({barangId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (barangId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.barangId,
                    referencedTable:
                        $$PembelianTableReferences._barangIdTable(db),
                    referencedColumn:
                        $$PembelianTableReferences._barangIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PembelianTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $PembelianTable,
    PembelianData,
    $$PembelianTableFilterComposer,
    $$PembelianTableOrderingComposer,
    $$PembelianTableAnnotationComposer,
    $$PembelianTableCreateCompanionBuilder,
    $$PembelianTableUpdateCompanionBuilder,
    (PembelianData, $$PembelianTableReferences),
    PembelianData,
    PrefetchHooks Function({bool barangId})>;
typedef $$PenjualanTableCreateCompanionBuilder = PenjualanCompanion Function({
  Value<int> id,
  required int barangId,
  required int qtyPcs,
  required double hargaJualPerPcs,
  required double hppSnapshot,
  required double laba,
  Value<String> tipe,
  Value<DateTime> tanggal,
});
typedef $$PenjualanTableUpdateCompanionBuilder = PenjualanCompanion Function({
  Value<int> id,
  Value<int> barangId,
  Value<int> qtyPcs,
  Value<double> hargaJualPerPcs,
  Value<double> hppSnapshot,
  Value<double> laba,
  Value<String> tipe,
  Value<DateTime> tanggal,
});

final class $$PenjualanTableReferences
    extends BaseReferences<_$LocalDatabase, $PenjualanTable, PenjualanData> {
  $$PenjualanTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BarangTable _barangIdTable(_$LocalDatabase db) => db.barang
      .createAlias($_aliasNameGenerator(db.penjualan.barangId, db.barang.id));

  $$BarangTableProcessedTableManager get barangId {
    final $_column = $_itemColumn<int>('barang_id')!;

    final manager = $$BarangTableTableManager($_db, $_db.barang)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_barangIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PenjualanTableFilterComposer
    extends Composer<_$LocalDatabase, $PenjualanTable> {
  $$PenjualanTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyPcs => $composableBuilder(
      column: $table.qtyPcs, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hargaJualPerPcs => $composableBuilder(
      column: $table.hargaJualPerPcs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hppSnapshot => $composableBuilder(
      column: $table.hppSnapshot, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get laba => $composableBuilder(
      column: $table.laba, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipe => $composableBuilder(
      column: $table.tipe, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
      column: $table.tanggal, builder: (column) => ColumnFilters(column));

  $$BarangTableFilterComposer get barangId {
    final $$BarangTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.barangId,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableFilterComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PenjualanTableOrderingComposer
    extends Composer<_$LocalDatabase, $PenjualanTable> {
  $$PenjualanTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyPcs => $composableBuilder(
      column: $table.qtyPcs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hargaJualPerPcs => $composableBuilder(
      column: $table.hargaJualPerPcs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hppSnapshot => $composableBuilder(
      column: $table.hppSnapshot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get laba => $composableBuilder(
      column: $table.laba, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipe => $composableBuilder(
      column: $table.tipe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
      column: $table.tanggal, builder: (column) => ColumnOrderings(column));

  $$BarangTableOrderingComposer get barangId {
    final $$BarangTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.barangId,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableOrderingComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PenjualanTableAnnotationComposer
    extends Composer<_$LocalDatabase, $PenjualanTable> {
  $$PenjualanTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get qtyPcs =>
      $composableBuilder(column: $table.qtyPcs, builder: (column) => column);

  GeneratedColumn<double> get hargaJualPerPcs => $composableBuilder(
      column: $table.hargaJualPerPcs, builder: (column) => column);

  GeneratedColumn<double> get hppSnapshot => $composableBuilder(
      column: $table.hppSnapshot, builder: (column) => column);

  GeneratedColumn<double> get laba =>
      $composableBuilder(column: $table.laba, builder: (column) => column);

  GeneratedColumn<String> get tipe =>
      $composableBuilder(column: $table.tipe, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  $$BarangTableAnnotationComposer get barangId {
    final $$BarangTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.barangId,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableAnnotationComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PenjualanTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $PenjualanTable,
    PenjualanData,
    $$PenjualanTableFilterComposer,
    $$PenjualanTableOrderingComposer,
    $$PenjualanTableAnnotationComposer,
    $$PenjualanTableCreateCompanionBuilder,
    $$PenjualanTableUpdateCompanionBuilder,
    (PenjualanData, $$PenjualanTableReferences),
    PenjualanData,
    PrefetchHooks Function({bool barangId})> {
  $$PenjualanTableTableManager(_$LocalDatabase db, $PenjualanTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PenjualanTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PenjualanTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PenjualanTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> barangId = const Value.absent(),
            Value<int> qtyPcs = const Value.absent(),
            Value<double> hargaJualPerPcs = const Value.absent(),
            Value<double> hppSnapshot = const Value.absent(),
            Value<double> laba = const Value.absent(),
            Value<String> tipe = const Value.absent(),
            Value<DateTime> tanggal = const Value.absent(),
          }) =>
              PenjualanCompanion(
            id: id,
            barangId: barangId,
            qtyPcs: qtyPcs,
            hargaJualPerPcs: hargaJualPerPcs,
            hppSnapshot: hppSnapshot,
            laba: laba,
            tipe: tipe,
            tanggal: tanggal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int barangId,
            required int qtyPcs,
            required double hargaJualPerPcs,
            required double hppSnapshot,
            required double laba,
            Value<String> tipe = const Value.absent(),
            Value<DateTime> tanggal = const Value.absent(),
          }) =>
              PenjualanCompanion.insert(
            id: id,
            barangId: barangId,
            qtyPcs: qtyPcs,
            hargaJualPerPcs: hargaJualPerPcs,
            hppSnapshot: hppSnapshot,
            laba: laba,
            tipe: tipe,
            tanggal: tanggal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PenjualanTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({barangId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (barangId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.barangId,
                    referencedTable:
                        $$PenjualanTableReferences._barangIdTable(db),
                    referencedColumn:
                        $$PenjualanTableReferences._barangIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PenjualanTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $PenjualanTable,
    PenjualanData,
    $$PenjualanTableFilterComposer,
    $$PenjualanTableOrderingComposer,
    $$PenjualanTableAnnotationComposer,
    $$PenjualanTableCreateCompanionBuilder,
    $$PenjualanTableUpdateCompanionBuilder,
    (PenjualanData, $$PenjualanTableReferences),
    PenjualanData,
    PrefetchHooks Function({bool barangId})>;
typedef $$KartuStokTableCreateCompanionBuilder = KartuStokCompanion Function({
  Value<int> id,
  required int barangId,
  required String tipe,
  required int qty,
  Value<int> qtySisaLog,
  required int stokAkhir,
  Value<double> hargaBeliSaatItu,
  Value<String?> refId,
  Value<DateTime> tanggal,
});
typedef $$KartuStokTableUpdateCompanionBuilder = KartuStokCompanion Function({
  Value<int> id,
  Value<int> barangId,
  Value<String> tipe,
  Value<int> qty,
  Value<int> qtySisaLog,
  Value<int> stokAkhir,
  Value<double> hargaBeliSaatItu,
  Value<String?> refId,
  Value<DateTime> tanggal,
});

final class $$KartuStokTableReferences
    extends BaseReferences<_$LocalDatabase, $KartuStokTable, KartuStokData> {
  $$KartuStokTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BarangTable _barangIdTable(_$LocalDatabase db) => db.barang
      .createAlias($_aliasNameGenerator(db.kartuStok.barangId, db.barang.id));

  $$BarangTableProcessedTableManager get barangId {
    final $_column = $_itemColumn<int>('barang_id')!;

    final manager = $$BarangTableTableManager($_db, $_db.barang)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_barangIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$KartuStokTableFilterComposer
    extends Composer<_$LocalDatabase, $KartuStokTable> {
  $$KartuStokTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tipe => $composableBuilder(
      column: $table.tipe, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtySisaLog => $composableBuilder(
      column: $table.qtySisaLog, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get stokAkhir => $composableBuilder(
      column: $table.stokAkhir, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get hargaBeliSaatItu => $composableBuilder(
      column: $table.hargaBeliSaatItu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get tanggal => $composableBuilder(
      column: $table.tanggal, builder: (column) => ColumnFilters(column));

  $$BarangTableFilterComposer get barangId {
    final $$BarangTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.barangId,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableFilterComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$KartuStokTableOrderingComposer
    extends Composer<_$LocalDatabase, $KartuStokTable> {
  $$KartuStokTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tipe => $composableBuilder(
      column: $table.tipe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtySisaLog => $composableBuilder(
      column: $table.qtySisaLog, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get stokAkhir => $composableBuilder(
      column: $table.stokAkhir, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get hargaBeliSaatItu => $composableBuilder(
      column: $table.hargaBeliSaatItu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get tanggal => $composableBuilder(
      column: $table.tanggal, builder: (column) => ColumnOrderings(column));

  $$BarangTableOrderingComposer get barangId {
    final $$BarangTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.barangId,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableOrderingComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$KartuStokTableAnnotationComposer
    extends Composer<_$LocalDatabase, $KartuStokTable> {
  $$KartuStokTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipe =>
      $composableBuilder(column: $table.tipe, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<int> get qtySisaLog => $composableBuilder(
      column: $table.qtySisaLog, builder: (column) => column);

  GeneratedColumn<int> get stokAkhir =>
      $composableBuilder(column: $table.stokAkhir, builder: (column) => column);

  GeneratedColumn<double> get hargaBeliSaatItu => $composableBuilder(
      column: $table.hargaBeliSaatItu, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<DateTime> get tanggal =>
      $composableBuilder(column: $table.tanggal, builder: (column) => column);

  $$BarangTableAnnotationComposer get barangId {
    final $$BarangTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.barangId,
        referencedTable: $db.barang,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BarangTableAnnotationComposer(
              $db: $db,
              $table: $db.barang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$KartuStokTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $KartuStokTable,
    KartuStokData,
    $$KartuStokTableFilterComposer,
    $$KartuStokTableOrderingComposer,
    $$KartuStokTableAnnotationComposer,
    $$KartuStokTableCreateCompanionBuilder,
    $$KartuStokTableUpdateCompanionBuilder,
    (KartuStokData, $$KartuStokTableReferences),
    KartuStokData,
    PrefetchHooks Function({bool barangId})> {
  $$KartuStokTableTableManager(_$LocalDatabase db, $KartuStokTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KartuStokTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KartuStokTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KartuStokTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> barangId = const Value.absent(),
            Value<String> tipe = const Value.absent(),
            Value<int> qty = const Value.absent(),
            Value<int> qtySisaLog = const Value.absent(),
            Value<int> stokAkhir = const Value.absent(),
            Value<double> hargaBeliSaatItu = const Value.absent(),
            Value<String?> refId = const Value.absent(),
            Value<DateTime> tanggal = const Value.absent(),
          }) =>
              KartuStokCompanion(
            id: id,
            barangId: barangId,
            tipe: tipe,
            qty: qty,
            qtySisaLog: qtySisaLog,
            stokAkhir: stokAkhir,
            hargaBeliSaatItu: hargaBeliSaatItu,
            refId: refId,
            tanggal: tanggal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int barangId,
            required String tipe,
            required int qty,
            Value<int> qtySisaLog = const Value.absent(),
            required int stokAkhir,
            Value<double> hargaBeliSaatItu = const Value.absent(),
            Value<String?> refId = const Value.absent(),
            Value<DateTime> tanggal = const Value.absent(),
          }) =>
              KartuStokCompanion.insert(
            id: id,
            barangId: barangId,
            tipe: tipe,
            qty: qty,
            qtySisaLog: qtySisaLog,
            stokAkhir: stokAkhir,
            hargaBeliSaatItu: hargaBeliSaatItu,
            refId: refId,
            tanggal: tanggal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$KartuStokTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({barangId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (barangId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.barangId,
                    referencedTable:
                        $$KartuStokTableReferences._barangIdTable(db),
                    referencedColumn:
                        $$KartuStokTableReferences._barangIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$KartuStokTableProcessedTableManager = ProcessedTableManager<
    _$LocalDatabase,
    $KartuStokTable,
    KartuStokData,
    $$KartuStokTableFilterComposer,
    $$KartuStokTableOrderingComposer,
    $$KartuStokTableAnnotationComposer,
    $$KartuStokTableCreateCompanionBuilder,
    $$KartuStokTableUpdateCompanionBuilder,
    (KartuStokData, $$KartuStokTableReferences),
    KartuStokData,
    PrefetchHooks Function({bool barangId})>;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$BarangTableTableManager get barang =>
      $$BarangTableTableManager(_db, _db.barang);
  $$PembelianTableTableManager get pembelian =>
      $$PembelianTableTableManager(_db, _db.pembelian);
  $$PenjualanTableTableManager get penjualan =>
      $$PenjualanTableTableManager(_db, _db.penjualan);
  $$KartuStokTableTableManager get kartuStok =>
      $$KartuStokTableTableManager(_db, _db.kartuStok);
}
