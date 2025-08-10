class SignUpInformation {
  final String name;
  final bool isPrivacyPolicyAgreed;
  final String email;
  final String password;
  final String passwordConfirm;

  const SignUpInformation({
    required this.name,
    required this.isPrivacyPolicyAgreed,
    required this.email,
    required this.password,
    required this.passwordConfirm,
  });

  SignUpInformation copyWith({
    String? name,
    bool? isPrivacyPolicyAgreed,
    String? email,
    String? password,
    String? passwordConfirm,
  }) {
    return SignUpInformation(
      name: name ?? this.name,
      isPrivacyPolicyAgreed: isPrivacyPolicyAgreed ?? this.isPrivacyPolicyAgreed,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
    );
  }

  static SignUpInformation initialState = const SignUpInformation(
    name: '',
    isPrivacyPolicyAgreed: false,
    email: '',
    password: '',
    passwordConfirm: '',
  );
}