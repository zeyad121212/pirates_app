// Full TrainingRequestsScreen with ExpansionTiles for cards
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/user_role.dart';
import '../models/training_request_status.dart';
import 'deny_reason_screen.dart';
import 'dart:async';

class TrainingRequestsScreen extends StatefulWidget {
  final String? currentUserId;
  final String? userRole;
  const TrainingRequestsScreen({Key? key, this.currentUserId, this.userRole})
    : super(key: key);

  @override
  _TrainingRequestsScreenState createState() => _TrainingRequestsScreenState();
}

class _TrainingRequestsScreenState extends State<TrainingRequestsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];
  final _supabaseService = SupabaseService();
  final List<String> _statusOrder = [
    'pending_central',
    'central_approved',
    'pending_project',
    'project_approved',
    'pending_trainers',
    'trainers_responded',
    'trainer_selected',
    'selection_approved_project',
    'final_approved_central',
    'completed',
  ]; zeyad121212
  final Map<String, String> _statusLabels = {
    'pending_central': 'في انتظار موافقة مسؤول التنمية المركزي',
    'central_approved': 'تمت الموافقة من مسؤول التنمية المركزي',
    'pending_project': 'في انتظار موافقة مدير المشروع',
    'project_approved': 'تمت الموافقة من مدير المشروع',
    'pending_trainers': 'في انتظار ردود المدربين',
    'trainers_responded': 'تم استقبال ردود المدربين',
    'trainer_selected': 'تم اختيار المدرب',
    'selection_approved_project': 'في انتظار موافقة مدير المشروع بعد الاختيار',
    'final_approved_central':
        'في انتظار الموافقة النهائية من مسؤول التنمية المركزي',
    'completed': 'تم إرسال الطلب للتنفيذ في المحافظة',
  };
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _supabaseService.subscribeToTrainingRequests().listen((
      data,
    ) {
      setState(() {
        requests = data;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Widget _buildIncomplete() {
    return RefreshIndicator(
      onRefresh: () async {
        await _subscription?.cancel();
        _subscription = _supabaseService.subscribeToTrainingRequests().listen((
          data,
        ) {
          setState(() {
            requests = data;
            isLoading = false;
          });
        });
      },
      child: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          final statusEnum = TrainingRequestStatus.fromCode((req['status'] as String?) ?? 'pending_central');
          if (statusEnum == TrainingRequestStatus.completed || statusEnum.code.startsWith('denied')) {
            return const SizedBox.shrink();
          }
          return _buildRequestCard(req);
        },
      ),
    );
  }

  Widget _buildApproved() {
    final approved =
        requests.where((r) => TrainingRequestStatus.fromCode((r['status'] as String?) ?? 'pending_central') == TrainingRequestStatus.completed).toList();
    return ListView.builder(
      itemCount: approved.length,
      itemBuilder: (context, index) {
        final req = approved[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req['province'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'التخصص: ${req['specialty']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text('عدد المتدربين: ${req['trainee_count']}'),
                const SizedBox(height: 8),
                const Text(
                  'تم تنفيذ التدريب',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDenied() {
    final denied =
        requests.where((r) {
          final s = TrainingRequestStatus.fromCode((r['status'] as String?) ?? 'pending_central');
          return s.code.startsWith('denied');
        }).toList();
    return ListView.builder(
      itemCount: denied.length,
      itemBuilder: (context, index) {
        final req = denied[index];
        final reason = req['denial_reason'] ?? 'لم يتم ذكر سبب';
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req['province'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'التخصص: ${req['specialty']}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text('عدد المتدربين: ${req['trainee_count']}'),
                const SizedBox(height: 8),
                Text('تم رفض الطلب', style: const TextStyle(color: Colors.red)),
                Text('السبب: $reason'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('متابعة الطلب'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'INCOMPLETE'),
              Tab(text: 'APPROVED'),
              Tab(text: 'DENIED'),
            ],
          ),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    _buildIncomplete(),
                    _buildApproved(),
                    _buildDenied(),
                  ],
                ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    final statusEnum = TrainingRequestStatus.fromCode((req['status'] as String?) ?? 'pending_central');
    final idx = _statusOrder.indexOf(statusEnum.code);
    final safeIdx = idx < 0 ? 0 : idx;
    final progress = (safeIdx + 1) / _statusOrder.length;
    final label = _statusLabels[statusEnum.code] ?? statusEnum.code;
    final roleEnum = UserRole.fromCode(widget.userRole ?? '');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color:
          statusEnum.code.startsWith('denied')
              ? Colors.red.shade50
              : statusEnum == TrainingRequestStatus.completed
              ? Colors.green.shade50
              : Colors.white,
      child: ExpansionTile(
        title: Text(
          req['province'] ?? '',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'التخصص: ${req['specialty']}',
          style: const TextStyle(fontSize: 14),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        children: [
          Text('عدد المتدربين: ${req['trainee_count']}'),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 12),
          // action buttons expanded on tap
          if (roleEnum == UserRole.centralCoordinator &&
              statusEnum == TrainingRequestStatus.pendingCentral)
            OverflowBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.updateTrainingRequestStatus(
                      requestId: req['id'],
                      newStatus: 'pending_project',
                    );
                    _subscription?.cancel();
                    _subscription = _supabaseService
                        .subscribeToTrainingRequests()
                        .listen((data) {
                          setState(() {
                            requests = data;
                            isLoading = false;
                          });
                        });
                  },
                  child: const Text('موافقة'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => DenyReasonScreen(
                              requestId: req['id'],
                              nextStatus: 'pending_central_denied',
                            ),
                      ),
                    );
                  },
                  child: const Text('رفض'),
                ),
              ],
            ),
          if (roleEnum == UserRole.projectManager &&
              statusEnum == TrainingRequestStatus.pendingProject)
            OverflowBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.updateTrainingRequestStatus(
                      requestId: req['id'],
                      newStatus: 'pending_trainers',
                    );
                    _subscription?.cancel();
                    _subscription = _supabaseService
                        .subscribeToTrainingRequests()
                        .listen((data) {
                          setState(() {
                            requests = data;
                            isLoading = false;
                          });
                        });
                  },
                  child: const Text('موافق'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => DenyReasonScreen(
                              requestId: req['id'],
                              nextStatus: 'pending_project_denied',
                            ),
                      ),
                    );
                  },
                  child: const Text('رفض'),
                ),
              ],
            ),
          if (roleEnum == UserRole.trainer && statusEnum == TrainingRequestStatus.pendingTrainers)
            OverflowBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.updateTrainingRequestStatus(
                      requestId: req['id'],
                      newStatus: 'trainers_responded',
                    );
                    _subscription?.cancel();
                    _subscription = _supabaseService
                        .subscribeToTrainingRequests()
                        .listen((data) {
                          setState(() {
                            requests = data;
                            isLoading = false;
                          });
                        });
                  },
                  child: const Text('قبول'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => DenyReasonScreen(
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
          if (roleEnum == UserRole.projectManager &&
              statusEnum == TrainingRequestStatus.trainerSelected)
            OverflowBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.updateTrainingRequestStatus(
                      requestId: req['id'],
                      newStatus: 'selection_approved_project',
                    );
                    _subscription?.cancel();
                    _subscription = _supabaseService
                        .subscribeToTrainingRequests()
                        .listen((data) {
                          setState(() {
                            requests = data;
                            isLoading = false;
                          });
                        });
                  },
                  child: const Text('موافقة مدير المشروع'),
                ),
              ],
            ),
          if (roleEnum == UserRole.centralCoordinator &&
              statusEnum == TrainingRequestStatus.selectionApprovedProject)
            ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.updateTrainingRequestStatus(
                      requestId: req['id'],
                      newStatus: 'final_approved_central',
                    );
                    _subscription?.cancel();
                    _subscription = _supabaseService
                        .subscribeToTrainingRequests()
                        .listen((data) {
                          setState(() {
                            requests = data;
                            isLoading = false;
                          });
                        });
                  },
                  child: const Text('موافقة نهائية'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => DenyReasonScreen(
                              requestId: req['id'],
                              nextStatus: 'final_approved_central_denied',
                            ),
                      ),
                    );
                  },
                  child: const Text('رفض'),
                ),
              ],
            ),
          if (roleEnum == UserRole.provinceManager &&
              statusEnum == TrainingRequestStatus.finalApprovedCentral)
            ButtonBar(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _supabaseService.updateTrainingRequestStatus(
                      requestId: req['id'],
                      newStatus: 'completed',
                    );
                    _subscription?.cancel();
                    _subscription = _supabaseService
                        .subscribeToTrainingRequests()
                        .listen((data) {
                          setState(() {
                            requests = data;
                            isLoading = false;
                          });
                        });
                  },
                  child: const Text('إرسال للتنفيذ'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
