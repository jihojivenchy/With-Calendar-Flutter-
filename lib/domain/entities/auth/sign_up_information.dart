class SignUpInformation {
  final String name;
  final bool privacyPolicyAgreed;
  final String email;
  final String password;
  final String passwordConfirm;

  const SignUpInformation({
    required this.name,
    required this.privacyPolicyAgreed,
    required this.email,
    required this.password,
    required this.passwordConfirm,
  });

  SignUpInformation copyWith({
    String? name,
    bool? privacyPolicyAgreed,
    String? email,
    String? password,
    String? passwordConfirm,
  }) {
    return SignUpInformation(
      name: name ?? this.name,
      privacyPolicyAgreed: privacyPolicyAgreed ?? this.privacyPolicyAgreed,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
    );
  }

  static SignUpInformation emptyData = SignUpInformation(
    name: '',
    privacyPolicyAgreed: false,
    email: '',
    password: '',
    passwordConfirm: '',
  );
}
