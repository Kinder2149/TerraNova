import 'dart:async';
import 'package:terranova/core/models/domain.dart';
import 'package:terranova/core/managers/domain_manager.dart';

class LoopTickEvent {
  final DateTime at;
  final Domain domain;
  const LoopTickEvent(this.at, this.domain);
}

class LoopManager {
  final DomainManager _domainManager;
  final String _domainId;
  Timer? _timer;
  final StreamController<LoopTickEvent> _controller = StreamController.broadcast();

  LoopManager({required DomainManager domainManager, required String domainId})
      : _domainManager = domainManager,
        _domainId = domainId;

  Stream<LoopTickEvent> get onTick => _controller.stream;

  Future<Domain> tickOnce() async {
    final updated = await _domainManager.applyProductionTick(_domainId);
    _controller.add(LoopTickEvent(DateTime.now(), updated));
    return updated;
  }

  void start({int intervalMs = 1000}) {
    if (_timer != null) return;
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      tickOnce();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
