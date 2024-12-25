import 'package:floor/floor.dart';
import 'recipe.dart';

@Entity(
  tableName: 'day_table',
  foreignKeys: [
    ForeignKey(
      childColumns: ['breakfast'],
      parentColumns: ['id'],
      entity: Recipe,
    ),
    ForeignKey(
      childColumns: ['lunch'],
      parentColumns: ['id'],
      entity: Recipe,
    ),
    ForeignKey(
      childColumns: ['dinner'],
      parentColumns: ['id'],
      entity: Recipe,
    ),
  ],
  indices: [
    Index(value: ['breakfast']),
    Index(value: ['lunch']),
    Index(value: ['dinner']),
  ],
)

class Day {
  @PrimaryKey()
  final int id;

  final String name;
  final int breakfast;
  final int lunch;
  final int dinner;

  Day({
  required this.id,
  required this.name,
  required this.breakfast,
  required this.lunch,
  required this.dinner,
});

  
}