import 'package:hive/hive.dart';
import 'ppg_session.dart';

/// Hive TypeAdapter for PPGSession
/// TypeId 0 is reserved for PPGSession
class PPGSessionAdapter extends TypeAdapter<PPGSession> {
    @override
    final int typeId = 0;

    @override
    PPGSession read(BinaryReader reader) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
        final dataLength = reader.readInt();
        final data = List<double>.generate(dataLength, (_) => reader.readDouble());
        final averageHeartRate = reader.readDouble();
        final maxHeartRate = reader.readDouble();
        final minHeartRate = reader.readDouble();

        return PPGSession(
            timestamp: timestamp,
            data: data,
            averageHeartRate: averageHeartRate,
            maxHeartRate: maxHeartRate,
            minHeartRate: minHeartRate,
        );
    }

    @override
    void write(BinaryWriter writer, PPGSession obj) {
        writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
        writer.writeInt(obj.data.length);
        for (final value in obj.data) {
            writer.writeDouble(value);
        }
        writer.writeDouble(obj.averageHeartRate);
        writer.writeDouble(obj.maxHeartRate);
        writer.writeDouble(obj.minHeartRate);
    }
}
