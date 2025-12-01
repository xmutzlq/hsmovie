mixin DebounceMixin {
  bool _debounce = false;

  Future<void> debouncer(Future<void> Function() callback) async {
    if (_debounce) return;
    _debounce = true;
    try {
      await callback();
    } finally {
      _debounce = false;
    }
  }
}