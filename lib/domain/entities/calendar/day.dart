/// 달력 시작 요일
enum StartingDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

class Day {
  final DateTime date;
  final bool isSelected;
  final bool isOutside;
  final DayCellState state;
  final bool isCoin;

  const Day({
    required this.date,
    required this.isSelected,
    required this.isOutside,
    required this.state,
    required this.isCoin,
  });

  @override
  String toString() {
    return 'Day(day: ${date.day}, isOutside: $isOutside)';
  }
}

enum DayCellState {
  basic,
  sunday,
  saturday,
  holiday,
  today,
}