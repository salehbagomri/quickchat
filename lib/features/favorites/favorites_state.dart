part of 'favorites_cubit.dart';

class FavoritesState extends Equatable {
  final List<FavoriteContact> contacts;

  const FavoritesState({this.contacts = const []});

  @override
  List<Object> get props => [contacts];
}
