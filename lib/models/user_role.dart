enum UserRole {
  projectManager('PM', 'مدير المشروع'),
  provinceManager('PR', 'مسؤول المحافظة'),
  trainer('TR', 'مدرب'),
  monitoringAgent('MB', 'وكيل المراقبة'),
  centralCoordinator('CC', 'مسؤولة التنمية بالمحافظات'),
  developmentOfficer('DV', 'مسؤول التنمية'),
  supervisor('SV', 'مجلس الإدارة');

  final String code;
  final String displayName;

  const UserRole(this.code, this.displayName);

  static UserRole? fromCode(String input) {
    final norm = input.trim();
    final codeNorm = norm.toUpperCase();
    // Prefix mapping for DB codes
    if (codeNorm.startsWith('DV')) return UserRole.developmentOfficer;
    if (codeNorm.startsWith('PR')) return UserRole.provinceManager;
    if (codeNorm.startsWith('PM')) return UserRole.projectManager;
    if (codeNorm.startsWith('TR')) return UserRole.trainer;
    if (codeNorm.startsWith('MB')) return UserRole.monitoringAgent;
    if (codeNorm.startsWith('CC')) return UserRole.centralCoordinator;
    if (codeNorm.startsWith('SV')) return UserRole.supervisor;
    // Fallback to displayName matching
    for (var role in UserRole.values) {
      if (role.displayName == norm) return role;
    }
    return null;
  }

  bool get canManageTrainers => [
    UserRole.projectManager,
    UserRole.supervisor,
    UserRole.centralCoordinator,
  ].contains(this);

  bool get canGenerateReports => [
    UserRole.projectManager,
    UserRole.supervisor,
  ].contains(this);

  bool get canEarnPoints => this == UserRole.trainer;

  bool get canAssignTrainings =>
      [UserRole.projectManager, UserRole.centralCoordinator].contains(this);
}
