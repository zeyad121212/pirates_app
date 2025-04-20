import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final _supabase = Supabase.instance.client;

  // User Management
  Future<Map<String, dynamic>?> getUserByCode(String code) async {
    final response =
        await _supabase.from('users').select().eq('code', code).maybeSingle();
    return response;
  }

  Future<void> updateUserPoints(String userId, int points) async {
    await _supabase.from('points_transactions').insert({
      'trainer_id': userId,
      'points': points,
      'reason': 'Training activity',
    });

    // Update total points in users table
    await _supabase.rpc(
      'update_user_points',
      params: {'user_id': userId, 'points_to_add': points},
    );
  }

  // Training Sessions
  Future<List<Map<String, dynamic>>> getTrainerSessions(
    String trainerId,
  ) async {
    final response = await _supabase
        .from('training_sessions')
        .select()
        .eq('trainer_id', trainerId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createTrainingSession(Map<String, dynamic> sessionData) async {
    await _supabase.from('training_sessions').insert(sessionData);
  }

  // Messages
  Future<void> sendMessage(
    String senderId,
    String receiverId,
    String content,
  ) async {
    await _supabase.from('messages').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> markMessagesAsRead({
    required String receiverId,
    required String senderId,
  }) async {
    await _supabase
        .from('messages')
        .update({'read': true})
        .eq('receiver_id', receiverId)
        .eq('sender_id', senderId)
        .eq('read', false);
  }

  Future<List<Map<String, dynamic>>> getContactsByRole(
    String userId,
    String userRole,
  ) async {
    // Get allowed roles based on user role
    final allowedRoles = _getAllowedRoles(userRole);
    // If no allowed roles, return empty list to avoid filtering errors
    if (allowedRoles.isEmpty) {
      return [];
    }
    final response = await _supabase
        .from('users')
        .select()
        .neq('id', userId)
        .inFilter('role', allowedRoles);

    return List<Map<String, dynamic>>.from(response);
  }

  List<String> _getAllowedRoles(String userRole) {
    switch (userRole) {
      case 'PM': // Project Manager
        return ['TR', 'MB', 'CC', 'SV']; // Can chat with all roles
      case 'TR': // Trainer
        return [
          'PM',
          'SV',
          'CC',
        ]; // Can chat with PM, Supervisor, and Coordinator
      case 'MB': // Monitoring Board Member
        return ['PM', 'SV']; // Can chat with PM and Supervisor
      case 'CC': // Central Coordinator
        return ['PM', 'TR', 'SV']; // Can chat with PM, Trainers, and Supervisor
      case 'SV': // Supervisor
        return [
          'PM',
          'TR',
          'MB',
          'CC',
        ]; // Can chat with all except other supervisors
      default:
        return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('sender_id', userId)
        .order('created_at');
    return (response as List)
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // Notifications
  Future<void> createNotification({
    required String userId,
    required String title,
    required String content,
    required String type,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'content': content,
      'type': type,
      'read': false,
    });
  }

  // Reports
  Future<void> createReport(Map<String, dynamic> reportData) async {
    await _supabase.from('reports').insert(reportData);
  }

  Future<List<Map<String, dynamic>>> getReports(String type) async {
    final response = await _supabase
        .from('reports')
        .select()
        .eq('type', type)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Training Requests
  Future<List<Map<String, dynamic>>> getTrainingRequests() async {
    final response = await _supabase
        .from('training_requests')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetch mentors by specialty (users with role MB)
  Future<List<Map<String, dynamic>>> getMentorsBySpecialty(String specialty) async {
    final resp = await _supabase
        .from('users')
        .select()
        .eq('role', 'MB')
        .eq('specialty', specialty);
    return List<Map<String, dynamic>>.from(resp);
  }

  /// Assign a mentor (monitoring agent) to a training request
  Future<void> assignMentor({
    required int requestId,
    required int mentorId,
  }) async {
    await _supabase
        .from('training_requests')
        .update({'monitoring_agent_id': mentorId})
        .eq('id', requestId);
  }

  Future<void> updateTrainingRequestStatus({
    required int requestId,
    required String newStatus,
    String? denialReason,
    int? trainerSelectedId,
    int? monitoringAgentId,
  }) async {
    final updates = <String, dynamic>{'status': newStatus};
    // assign selected trainer and agent if provided
    if (trainerSelectedId != null)
      updates['trainer_selected_id'] = trainerSelectedId;
    if (monitoringAgentId != null)
      updates['monitoring_agent_id'] = monitoringAgentId;
    // set appropriate denial reason field
    if (denialReason != null) {
      if (newStatus == 'denied_central') {
        updates['denial_reason_central'] = denialReason;
      } else if (newStatus == 'denied_project') {
        updates['denial_reason_project'] = denialReason;
      } else if (newStatus == 'denied_agent') {
        updates['denial_reason_agent'] = denialReason;
      }
    }
    await _supabase
        .from('training_requests')
        .update(updates)
        .eq('id', requestId);
  }

  /// MB: reject all trainer responses
  Future<void> rejectAllTrainerResponses({required int requestId, required String denialReason}) async {
    await updateTrainingRequestStatus(
      requestId: requestId,
      newStatus: 'denied_agent',
      denialReason: denialReason,
    );
  }

  /// PM final approval or denial
  Future<void> projectManagerFinalDecision({required int requestId, required bool approved, String? denialReason}) async {
    final status = approved ? 'selection_approved_project' : 'denied_final_pm';
    await updateTrainingRequestStatus(
      requestId: requestId,
      newStatus: status,
      denialReason: denialReason,
    );
  }

  /// CC final approval or denial
  Future<void> centralCoordinatorFinalDecision({required int requestId, required bool approved, String? denialReason}) async {
    final status = approved ? 'completed' : 'denied_final_cc';
    await updateTrainingRequestStatus(
      requestId: requestId,
      newStatus: status,
      denialReason: denialReason,
    );
  }

  /// CC initial approval or denial
  Future<void> centralCoordinatorInitialDecision({required int requestId, required bool approved, String? denialReason}) async {
    final status = approved ? 'pending_project' : 'denied_central';
    await updateTrainingRequestStatus(
      requestId: requestId,
      newStatus: status,
      denialReason: denialReason,
    );
  }

  /// PM initial approval or denial
  Future<void> projectManagerInitialDecision({required int requestId, required bool approved, String? denialReason}) async {
    final status = approved ? 'pending_trainers' : 'denied_project';
    await updateTrainingRequestStatus(
      requestId: requestId,
      newStatus: status,
      denialReason: denialReason,
    );
  }

  /// Record DV completion with feedback, rating, and documents
  Future<void> recordDvCompletion({
    required int requestId,
    required String completionStatus,
    String? feedback,
    int? rating,
    List<String>? documents,
  }) async {
    final updates = <String, dynamic>{'dv_completion_status': completionStatus};
    if (feedback != null) updates['dv_feedback'] = feedback;
    if (rating != null) updates['dv_rating'] = rating;
    if (documents != null) updates['dv_documents'] = documents;
    await _supabase
        .from('training_requests')
        .update(updates)
        .eq('id', requestId);
  }

  /// Record Trainer completion with feedback and rating
  Future<void> recordTrainerCompletion({
    required int requestId,
    required String completionStatus,
    String? feedback,
    int? rating,
  }) async {
    final updates = <String, dynamic>{'trainer_completion_status': completionStatus};
    if (feedback != null) updates['trainer_feedback'] = feedback;
    if (rating != null) updates['trainer_rating'] = rating;
    await _supabase
        .from('training_requests')
        .update(updates)
        .eq('id', requestId);
  }

  // Fetch requests approved by a trainer
  Future<List<Map<String, dynamic>>> getApprovedRequestsForTrainer(String trainerId) async {
    final resp = await _supabase
        .from('training_request_responses')
        .select('request_id')
        .eq('trainer_id', trainerId)
        .eq('response', 'approved');
    final ids = (resp as List).map((r) => r['request_id'] as int).toList();
    if (ids.isEmpty) return [];
    final reqs = await _supabase
        .from('training_requests')
        .select()
        .inFilter('id', ids);
    return List<Map<String, dynamic>>.from(reqs);
  }

  // Training Request Responses
  Future<void> createTrainingRequestResponse({
    required int requestId,
    required int trainerId,
    required String response,
    String? reason,
  }) async {
    await _supabase.from('training_request_responses').insert({
      'request_id': requestId,
      'trainer_id': trainerId,
      'response': response,
      if (reason != null) 'reason': reason,
      'responded_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getTrainingRequestResponses(
    int requestId,
  ) async {
    final resp = await _supabase
        .from('training_request_responses')
        .select()
        .eq('request_id', requestId);
    return List<Map<String, dynamic>>.from(resp);
  }

  Stream<List<Map<String, dynamic>>> subscribeToTrainingRequestResponses(
    int requestId,
  ) {
    return _supabase
        .from('training_request_responses')
        .stream(primaryKey: ['id'])
        .eq('request_id', requestId)
        .order('responded_at')
        .execute()
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // Real-time subscriptions
  Stream<List<Map<String, dynamic>>> subscribeToNotifications(String userId) {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> subscribeToMessages(String userId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('sender_id', userId)
        .order('created_at')
        .execute()
        .map(
          (data) =>
              (data as List)
                  .map((item) => Map<String, dynamic>.from(item))
                  .toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> getReceivedMessages(String userId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .order('created_at')
        .execute()
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  /// Fetch multiple users by their IDs (for trainer name lookup)
  Future<List<Map<String, dynamic>>> getUsersByIds(List<int> userIds) async {
    final resp = await _supabase.from('users').select().inFilter('id', userIds);
    return List<Map<String, dynamic>>.from(resp);
  }

  /// Subscribe to real-time updates of training_requests
  Stream<List<Map<String, dynamic>>> subscribeToTrainingRequests() {
    return _supabase
        .from('training_requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .execute()
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // Submit province feedback and mark completed
  Future<void> submitProvinceFeedback({
    required int requestId,
    required String feedback,
  }) async {
    await _supabase.from('training_requests').update({
      'status': 'completed',
      'province_feedback': feedback,
    }).eq('id', requestId);
  }

  // Submit trainer feedback
  Future<void> submitTrainerFeedback({
    required int requestId,
    required String feedback,
  }) async {
    await _supabase.from('training_requests').update({
      'trainer_feedback': feedback,
    }).eq('id', requestId);
  }

  Future<void> createTrainingRequest({
    required String province,
    required int traineeCount,
    required String specialty,
    required String date,
  }) async {
    await _supabase.from('training_requests').insert({
      'province': province,
      'trainee_count': traineeCount,
      'specialty': specialty,
      'date': date,
      'status': 'pending_central',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
