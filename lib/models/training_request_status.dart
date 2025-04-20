/// Enum representing the various statuses of a training request.
enum TrainingRequestStatus {
  pendingCentral('pending_central'),
  pendingProject('pending_project'),
  pendingTrainers('pending_trainers'),
  trainersResponded('trainers_responded'),
  trainerSelected('trainer_selected'),
  selectionApprovedProject('selection_approved_project'),
  finalApprovedCentral('final_approved_central'),
  finalApprovedCentralDenied('final_approved_central_denied'),
  pendingFinalPm('pending_final_pm'),
  pendingFinalCc('pending_final_cc'),
  completed('completed'),
  deniedCentral('denied_central'),
  deniedProject('denied_project'),
  deniedAgent('denied_agent'),
  deniedFinalPm('denied_final_pm'),
  deniedFinalCc('denied_final_cc');

  final String code;
  const TrainingRequestStatus(this.code);

  /// Create enum from database code string
  factory TrainingRequestStatus.fromCode(String code) {
    return TrainingRequestStatus.values
        .firstWhere((e) => e.code == code, orElse: () => TrainingRequestStatus.pendingCentral);
  }

  /// List of codes for queries
  static List<String> get allCodes => values.map((e) => e.code).toList();
}
