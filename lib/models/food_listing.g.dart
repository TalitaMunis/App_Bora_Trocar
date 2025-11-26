part of 'food_listing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodListingAdapter extends TypeAdapter<FoodListing> {
  @override
  final int typeId = 0;

  @override
  FoodListing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodListing(
      id: fields[0] as int,
      title: fields[1] as String,
      imageUrl: fields[2] as String?,
      statusProximidadeVencimento: fields[3] as String,
      expiryDate: fields[4] as DateTime,
      description: fields[5] as String,
      contactInfo: fields[6] as String,
      quantity: fields[7] as String,
      category: fields[8] as String?,
      creatorUserId: fields[9] as String,
      location: fields[11] as String,
      isMockUserOwner: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FoodListing obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.statusProximidadeVencimento)
      ..writeByte(4)
      ..write(obj.expiryDate)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.contactInfo)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.creatorUserId)
      ..writeByte(11)
      ..write(obj.location)
      ..writeByte(10)
      ..write(obj.isMockUserOwner);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodListingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
