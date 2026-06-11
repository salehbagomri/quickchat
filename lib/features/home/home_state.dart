part of 'home_cubit.dart';

class HomeState extends Equatable {
  final String countryCode;
  final bool isLoading;

  const HomeState({
    this.countryCode = '+967',
    this.isLoading = false,
  });

  HomeState copyWith({String? countryCode, bool? isLoading}) => HomeState(
        countryCode: countryCode ?? this.countryCode,
        isLoading: isLoading ?? this.isLoading,
      );

  @override
  List<Object> get props => [countryCode, isLoading];
}
