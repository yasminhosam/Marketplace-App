sealed class AddProductState {}

final class AddProductInitial extends AddProductState{}
final class AddProductLoading extends AddProductState {}

final class AddProductSuccess extends AddProductState {}

final class AddProductFailure extends AddProductState {
  final String errorMessage;

  AddProductFailure(this.errorMessage);
}