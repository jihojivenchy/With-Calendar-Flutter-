class SignInInformation {
  final String email;
  final String password;

  const SignInInformation({required this.email, required this.password});

  SignInInformation copyWith({String? email, String? password}) {
    return SignInInformation(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  static SignInInformation get initialData =>
      SignInInformation(email: '', password: '');
}