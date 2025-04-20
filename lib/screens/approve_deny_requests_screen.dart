import 'dart:async';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_role.dart';
import '../models/training_request_status.dart';
import 'deny_reason_screen.dart';

class ApproveDenyRequestsScreen extends StatefulWidget {
  final String currentUserId;
  final String userRole;
  const ApproveDenyRequestsScreen({
    Key? key,
    required this.currentUserId,
    required this.userRole,
  }) : super(key: key);

  @override
  State<ApproveDenyRequestsScreen> createState() => _ApproveDenyRequestsScreenState();
}

class _ApproveDenyRequestsScreenState extends State<ApproveDenyRequestsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];
  late StreamSubscription<List<Map<String, dynamic>>> _subscription;
  final SupabaseService _supabaseService = SupabaseService();

  final Map<String, String> _statusLabels = {
    'pending_central': 'في انتظار موافقة مسؤول التنمية المركزي',
    'central_approved': 'تمت الموافقة من مسؤول التنمية المركزي',
    'pending_project': 'في انتظار موافقة مدير المشروع',
    'project_approved': 'تمت الموافقة من مدير المشروع',
    'pending_trainers': 'في انتظار ردود المدربين',
    'trainers_responded': 'تم استقبال ردود المدربين',
    'trainer_selected': 'تم اختيار المدرب',
    'selection_approved_project': 'في انتظار موافقة مدير المشروع بعد الاختيار',
    'final_approved_central': 'في انتظار الموافقة النهائية من مسؤول التنمية المركزي',
    'completed': 'تم إرسال الطلب للتنفيذ في المحافظة',
  };

  /// Load initial data for this screen
  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final data = await _supabaseService.getTrainingRequests();
    final roleEnum = UserRole.fromCode(widget.userRole) ?? UserRole.projectManager;
    final filtered = data.where((r) {
      final statusEnum = TrainingRequestStatus.fromCode((r['status'] as String?) ?? '');
      if (roleEnum == UserRole.centralCoordinator) {
        return statusEnum == TrainingRequestStatus.pendingCentral
            || statusEnum == TrainingRequestStatus.selectionApprovedProject;
      } else if (roleEnum == UserRole.projectManager) {
        return statusEnum == TrainingRequestStatus.pendingProject
            || statusEnum == TrainingRequestStatus.trainerSelected;
      } else if (roleEnum == UserRole.trainer) {
        return statusEnum == TrainingRequestStatus.pendingTrainers;
      } else if (roleEnum == UserRole.monitoringAgent) {
        return statusEnum == TrainingRequestStatus.trainersResponded;
      }
      return false;
    }).toList();
    setState(() {
      requests = filtered;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscription = _supabaseService.subscribeToTrainingRequests().listen((data) {
      final roleEnum = UserRole.fromCode(widget.userRole) ?? UserRole.projectManager;
      final filtered = data.where((r) {
        final statusEnum = TrainingRequestStatus.fromCode((r['status'] as String?) ?? '');
        if (roleEnum == UserRole.centralCoordinator) {
          return statusEnum == TrainingRequestStatus.pendingCentral
              || statusEnum == TrainingRequestStatus.selectionApprovedProject;
        } else if (roleEnum == UserRole.projectManager) {
          return statusEnum == TrainingRequestStatus.pendingProject
              || statusEnum == TrainingRequestStatus.trainerSelected;
        } else if (roleEnum == UserRole.trainer) {
          return statusEnum == TrainingRequestStatus.pendingTrainers;
        } else if (roleEnum == UserRole.monitoringAgent) {
          return statusEnum == TrainingRequestStatus.trainersResponded;
        }
        return false;
      }).toList();
      setState(() {
        requests = filtered;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    final status = (req['status'] as String?) ?? '';
    final roleEnum = UserRole.fromCode(widget.userRole) ?? UserRole.projectManager;
    final label = _statusLabels[status] ?? status;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ExpansionTile(
        title: Text(
          req['province'] ?? '',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'التخصص: ${req['specialty']}',
          style: const TextStyle(fontSize: 14),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          Text('عدد المتدربين: ${req['trainee_count']}'),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          if (roleEnum == UserRole.centralCoordinator && status == 'pending_central')
            OverflowBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.centralCoordinatorInitialDecision(
                      requestId: req['id'],
                      approved: true,
                    );
                  },
                  child: const Text('موافقة'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DenyReasonScreen(
                          requestId: req['id'],
                          nextStatus: 'denied_central',
                        ),
                      ),
                    );
                  },
                  child: const Text('رفض'),
                ),
              ],
            ),
          if (roleEnum == UserRole.projectManager && status == 'pending_project')
            OverflowBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.projectManagerInitialDecision(
                      requestId: req['id'],
                      approved: true,
                    );
                  },
                  child: const Text('موافقة'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DenyReasonScreen(
                          requestId: req['id'],
                          nextStatus: 'denied_project',
                        ),
                      ),
                    );
                  },
                  child: const Text('رفض'),
                ),
              ],
            ),
          if (roleEnum == UserRole.projectManager && status == 'trainer_selected')
            ElevatedButton(
              onPressed: () async {
                await _supabaseService.projectManagerFinalDecision(
                  requestId: req['id'],
                  approved: true,
                );
              },
              child: const Text('موافقة مدير المشروع'),
            ),
          if (roleEnum == UserRole.trainer && status == 'pending_trainers')
            OverflowBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.updateTrainingRequestStatus(
                      requestId: req['id'],
                      newStatus: 'trainers_responded',
                    );
                  },
                  child: const Text('قبول'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DenyReasonScreen(
                          requestId: req['id'],
                          nextStatus: 'pending_trainers_denied',
                        ),
                      ),
                    );
                  },
                  child: const Text('رفض'),
                ),
              ],
            ),
          if (roleEnum == UserRole.centralCoordinator && status == 'selection_approved_project')
            ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.centralCoordinatorFinalDecision(
                      requestId: req['id'],
                      approved: true,
                    );
                  },
                  child: const Text('موافقة نهائية'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DenyReasonScreen(
                          requestId: req['id'],
                          nextStatus: 'denied_final_cc',
                        ),
                      ),
                    );
                  },
                  child: const Text('رفض'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الطلبات')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('لا توجد طلبات في هذه المرحلة'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final status = (req['status'] as String?) ?? '';
                    final roleEnum = UserRole.fromCode(widget.userRole) ?? UserRole.projectManager;
                    String approveStatus = '';
                    String denyStatus = '';
                    if (roleEnum == UserRole.centralCoordinator) {
                      if (status == 'pending_central') {
                        approveStatus = 'pending_project';
                        denyStatus = 'denied_central';
                      } else if (status == 'selection_approved_project') {
                        approveStatus = 'final_approved_central';
                        denyStatus = 'denied_final_cc';
                      }
                    } else if (roleEnum == UserRole.projectManager) {
                      if (status == 'pending_project') {
                        approveStatus = 'pending_trainers';
                        denyStatus = 'denied_project';
                      } else if (status == 'trainer_selected') {
                        approveStatus = 'selection_approved_project';
                      }
                    } else if (roleEnum == UserRole.trainer && status == 'pending_trainers') {
                      approveStatus = 'trainers_responded';
                      denyStatus = 'pending_trainers_denied';
                    }
                    return Dismissible(
                      key: ValueKey(req['id']),
                      direction: (approveStatus.isEmpty && denyStatus.isEmpty)
                          ? DismissDirection.none
                          : DismissDirection.horizontal,
                      background: approveStatus.isNotEmpty
                          ? Container(
                              color: Colors.green,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.check, color: Colors.white),
                            )
                          : null,
                      secondaryBackground: denyStatus.isNotEmpty
                          ? Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.close, color: Colors.white),
                            )
                          : null,
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd && approveStatus.isNotEmpty) {
                          if (roleEnum == UserRole.centralCoordinator && status == 'pending_central') {
                            await _supabaseService.centralCoordinatorInitialDecision(
                              requestId: req['id'],
                              approved: true,
                            );
                          } else if (roleEnum == UserRole.projectManager && status == 'pending_project') {
                            await _supabaseService.projectManagerInitialDecision(
                              requestId: req['id'],
                              approved: true,
                            );
                          } else if (roleEnum == UserRole.projectManager && status == 'trainer_selected') {
                            await _supabaseService.projectManagerFinalDecision(
                              requestId: req['id'],
                              approved: true,
                            );
                          } else if (roleEnum == UserRole.centralCoordinator && status == 'selection_approved_project') {
                            await _supabaseService.centralCoordinatorFinalDecision(
                              requestId: req['id'],
                              approved: true,
                            );
                          } else {
                            await _supabaseService.updateTrainingRequestStatus(
                              requestId: req['id'],
                              newStatus: approveStatus,
                            );
                          }
                          return true;
                        } else if (direction == DismissDirection.endToStart && denyStatus.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DenyReasonScreen(
                                requestId: req['id'],
                                nextStatus: denyStatus,
                              ),
                            ),
                          );
                          return false;
                        }
                        return false;
                      },
                      child: _buildRequestCard(req),
                    );
                  },
                ),
    );
  }
}
