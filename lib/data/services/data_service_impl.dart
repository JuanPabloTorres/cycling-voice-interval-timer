import 'package:uuid/uuid.dart';
import '../interfaces/repository_interfaces.dart';
import '../repositories/timer_plan_repository_impl.dart';
import '../repositories/timer_event_repository_impl.dart';
import '../repositories/repeat_rule_repository_impl.dart';
import '../../models/models.dart';

/// Implementation of [IDataService] using Repository Pattern.
/// 
/// Aggregates all repositories and provides high-level data operations.
/// Follows Dependency Inversion Principle - depends on abstractions.
class DataServiceImpl implements IDataService {
  final IDatabaseProvider _dbProvider;
  final ITimerPlanRepository _planRepository;
  final ITimerEventRepository _eventRepository;
  final IRepeatRuleRepository _ruleRepository;
  final Uuid _uuid;

  DataServiceImpl({
    required IDatabaseProvider dbProvider,
    ITimerPlanRepository? planRepository,
    ITimerEventRepository? eventRepository,
    IRepeatRuleRepository? ruleRepository,
  })  : _dbProvider = dbProvider,
        _planRepository = planRepository ?? 
            TimerPlanRepositoryImpl(dbProvider: dbProvider),
        _eventRepository = eventRepository ?? 
            TimerEventRepositoryImpl(dbProvider: dbProvider),
        _ruleRepository = ruleRepository ?? 
            RepeatRuleRepositoryImpl(dbProvider: dbProvider),
        _uuid = const Uuid();

  /// Initializes the data service and database.
  Future<void> initialize() async {
    await _dbProvider.initialize();
    print('[DataServiceImpl] Initialized with ${_dbProvider.runtimeType}');
  }

  @override
  Future<TimerPlan?> getPlanWithDetails(String planId) async {
    final plan = await _planRepository.getById(planId);
    if (plan == null) return null;

    final events = await _eventRepository.getByPlanId(planId);
    final rules = await _ruleRepository.getByPlanId(planId);

    return plan.copyWith(events: events, repeatRules: rules);
  }

  @override
  Future<List<TimerPlan>> getAllPlansWithDetails() async {
    final plans = await _planRepository.getAll();
    final result = <TimerPlan>[];

    for (final plan in plans) {
      final events = await _eventRepository.getByPlanId(plan.id);
      final rules = await _ruleRepository.getByPlanId(plan.id);
      result.add(plan.copyWith(events: events, repeatRules: rules));
    }

    return result;
  }

  @override
  Future<String> createPlan(TimerPlan plan) async {
    await _planRepository.insert(plan);

    if (plan.events.isNotEmpty) {
      await _eventRepository.insertAll(plan.events);
    }

    if (plan.repeatRules.isNotEmpty) {
      await _ruleRepository.insertAll(plan.repeatRules);
    }

    print('[DataServiceImpl] Created plan: ${plan.name}');
    return plan.id;
  }

  @override
  Future<void> updatePlanWithDetails(TimerPlan plan) async {
    await _planRepository.update(plan);
    await _eventRepository.replaceAllForPlan(plan.id, plan.events);
    await _ruleRepository.replaceAllForPlan(plan.id, plan.repeatRules);
    print('[DataServiceImpl] Updated plan: ${plan.name}');
  }

  @override
  Future<void> deletePlan(String planId) async {
    await _planRepository.delete(planId);
    print('[DataServiceImpl] Deleted plan: $planId');
  }

  @override
  String generateId() => _uuid.v4();

  @override
  Future<Map<String, int>> getStatistics() async {
    return {
      'plans': await _planRepository.count(),
      'events': await _eventRepository.count(),
      'rules': await _ruleRepository.count(),
    };
  }

  @override
  Future<void> createDemoPlan() async {
    final planId = generateId();
    final now = DateTime.now();

    final demoPlan = TimerPlan(
      id: planId,
      name: 'Demo: Intervalos 30min',
      description: 'Plan de ejemplo con intervalos cada 5 minutos',
      totalDurationSeconds: 30 * 60, // 30 minutes
      createdAt: now,
      updatedAt: now,
      events: [
        TimerEvent(
          id: generateId(),
          planId: planId,
          triggerAtSecond: 0,
          spokenMessage: 'Iniciando entrenamiento. ¡Vamos!',
          isEnabled: true,
          sortOrder: 0,
        ),
        TimerEvent(
          id: generateId(),
          planId: planId,
          triggerAtSecond: 15 * 60, // 15 minutes
          spokenMessage: 'Mitad del entrenamiento. ¡Sigue así!',
          isEnabled: true,
          sortOrder: 1,
        ),
        TimerEvent(
          id: generateId(),
          planId: planId,
          triggerAtSecond: 25 * 60, // 25 minutes
          spokenMessage: 'Últimos 5 minutos. ¡Sprint final!',
          isEnabled: true,
          sortOrder: 2,
        ),
        TimerEvent(
          id: generateId(),
          planId: planId,
          triggerAtSecond: 30 * 60, // 30 minutes
          spokenMessage: 'Entrenamiento completado. ¡Excelente trabajo!',
          isEnabled: true,
          sortOrder: 3,
        ),
      ],
      repeatRules: [
        RepeatRule(
          id: generateId(),
          planId: planId,
          startAtSecond: 60, // Start at 1 minute
          repeatEverySeconds: 5 * 60, // Every 5 minutes
          endAtSecond: 29 * 60, // Until 29 minutes
          spokenMessage: 'Mantén el ritmo',
          isEnabled: true,
          sortOrder: 0,
        ),
      ],
    );

    await createPlan(demoPlan);
    print('[DataServiceImpl] Created demo plan');
  }

  /// Creates a quick interval plan for testing.
  Future<void> createQuickIntervalPlan() async {
    final planId = generateId();
    final now = DateTime.now();

    final quickPlan = TimerPlan(
      id: planId,
      name: 'Quick: Test 2min',
      description: 'Plan rápido de 2 minutos para probar',
      totalDurationSeconds: 2 * 60,
      createdAt: now,
      updatedAt: now,
      events: [
        TimerEvent(
          id: generateId(),
          planId: planId,
          triggerAtSecond: 0,
          spokenMessage: 'Iniciando test de 2 minutos',
          isEnabled: true,
          sortOrder: 0,
        ),
        TimerEvent(
          id: generateId(),
          planId: planId,
          triggerAtSecond: 60,
          spokenMessage: '1 minuto transcurrido',
          isEnabled: true,
          sortOrder: 1,
        ),
        TimerEvent(
          id: generateId(),
          planId: planId,
          triggerAtSecond: 2 * 60,
          spokenMessage: 'Test completado',
          isEnabled: true,
          sortOrder: 2,
        ),
      ],
      repeatRules: [
        RepeatRule(
          id: generateId(),
          planId: planId,
          startAtSecond: 10,
          repeatEverySeconds: 30,
          endAtSecond: 110,
          spokenMessage: 'Intervalo de 30 segundos',
          isEnabled: true,
          sortOrder: 0,
        ),
      ],
    );

    await createPlan(quickPlan);
    print('[DataServiceImpl] Created quick interval plan');
  }

  @override
  Future<void> close() async {
    await _dbProvider.close();
  }
}
