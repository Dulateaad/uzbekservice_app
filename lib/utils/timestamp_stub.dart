// Заглушка для Timestamp из Firebase Firestore
// Используется для совместимости при миграции на Supabase

class Timestamp {
  final DateTime _dateTime;

  Timestamp._(this._dateTime);

  factory Timestamp.fromDate(DateTime date) => Timestamp._(date);
  
  factory Timestamp.fromMillisecondsSinceEpoch(int milliseconds) =>
      Timestamp._(DateTime.fromMillisecondsSinceEpoch(milliseconds));
  
  factory Timestamp.now() => Timestamp._(DateTime.now());

  DateTime toDate() => _dateTime;
  
  int get seconds => _dateTime.millisecondsSinceEpoch ~/ 1000;
  int get nanoseconds => (_dateTime.millisecondsSinceEpoch % 1000) * 1000000;
  
  @override
  String toString() => _dateTime.toString();
}

