import '../../../core/models/category_model.dart';

sealed class AddProductState {}

final class AddProductInitial extends AddProductState{}
final class AddProductCategoriesLoading extends AddProductState {}
final class AddProductCategoriesLoaded extends AddProductState {
  final List<CategoryModel> categories;
  AddProductCategoriesLoaded(this.categories);
}
final class AddProductCategoriesFailure extends AddProductState{
  final String errorMessage;

  AddProductCategoriesFailure(this.errorMessage);
}
final class AddProductLoading extends AddProductState {}
final class AddProductSuccess extends AddProductState {}

final class AddProductFailure extends AddProductState {
  final String errorMessage;

  AddProductFailure(this.errorMessage);
}