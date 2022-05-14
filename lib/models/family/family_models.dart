class FamilyMemberData {
  FamilyMemberData(this.id, this.name, this.avatarPath, this.phoneNumber,
      this.email, this.admin, this.permission);

  final String id;
  final String name;
  final String avatarPath;
  final String phoneNumber;
  final String email;
  final bool admin;
  final List<int> permission;
}