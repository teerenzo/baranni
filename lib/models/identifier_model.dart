import 'package:barrani/models/model.dart';

abstract class IdentifierModel<T> extends Model {
  final int id;

  IdentifierModel(this.id);
}
