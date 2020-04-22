// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.6
part of engine;

const bool _debugLogHistoryActions = false;

class TestHistoryEntry {
  final dynamic state;
  final String title;
  final String url;
  final String queryParams;

  const TestHistoryEntry(this.state, this.title, this.url, this.queryParams);

  @override
  String toString() {
    return '$runtimeType(state:$state, title:"$title", url:"$url")';
  }
}

/// This location strategy mimics the browser's history as closely as possible
/// while doing it all in memory with no interaction with the browser.
///
/// It keeps a list of history entries and event listeners in memory and
/// manipulates them in order to achieve the desired functionality.
class TestLocationStrategy extends LocationStrategy {
  /// Creates a instance of [TestLocationStrategy] with an empty string as the
  /// path.
  factory TestLocationStrategy() => TestLocationStrategy.fromEntry(TestHistoryEntry(null, null, '', ''));

  /// Creates an instance of [TestLocationStrategy] and populates it with a list
  /// that has [initialEntry] as the only item.
  TestLocationStrategy.fromEntry(TestHistoryEntry initialEntry)
      : _currentEntryIndex = 0,
        history = <TestHistoryEntry>[initialEntry];

  String getBaseHref() => "/";

  @override
  String hash() => currentEntry.url;

  @override
  String path() => currentEntry.url;

  int _currentEntryIndex;
  int get currentEntryIndex => _currentEntryIndex;

  final List<TestHistoryEntry> history;

  TestHistoryEntry get currentEntry {
    assert(withinAppHistory);
    return history[_currentEntryIndex];
  }

  set currentEntry(TestHistoryEntry entry) {
    assert(withinAppHistory);
    history[_currentEntryIndex] = entry;
  }

  /// Whether we are still within the history of the Flutter Web app. This
  /// remains true until we go back in history beyond the entry where the app
  /// started.
  bool get withinAppHistory => _currentEntryIndex >= 0;

  @override
  void pushState(dynamic state, String title, String url, String queryParams) {
    assert(withinAppHistory);
    _currentEntryIndex++;
    // When pushing a new state, we need to remove all entries that exist after
    // the current entry.
    //
    // If the user goes A -> B -> C -> D, then goes back to B and pushes a new
    // entry called E, we should end up with: A -> B -> E in the history list.
    history.removeRange(_currentEntryIndex, history.length);
    history.add(TestHistoryEntry(state, title, url, queryParams));

    if (_debugLogHistoryActions) {
      print('$runtimeType.pushState(...) -> $this');
    }
  }

  @override
  void replaceState(dynamic state, String title, String url, String queryParams) {
    assert(withinAppHistory);
    if (url == null || url == '') {
      url = currentEntry.url;
    }
    currentEntry = TestHistoryEntry(state, title, url, queryParams);

    if (_debugLogHistoryActions) {
      print('$runtimeType.replaceState(...) -> $this');
    }
  }

  /// This simulates the case where a user types in a url manually. It causes
  /// a new state to be pushed, and all event listeners will be invoked.
  Future<void> simulateUserTypingUrl(String url, String queryParams) {
    assert(withinAppHistory);
    return _nextEventLoop(() {
      pushState(null, '', url, queryParams);
      _firePopStateEvent();
    });
  }

  @override
  Future<void> back() {
    assert(withinAppHistory);
    // Browsers don't move back in history immediately. They do it at the next
    // event loop. So let's simulate that.
    return _nextEventLoop(() {
      _currentEntryIndex--;
      if (withinAppHistory) {
        _firePopStateEvent();
      }

      if (_debugLogHistoryActions) {
        print('$runtimeType.back() -> $this');
      }
    });
  }

  @override
  Future<void> forward() {
    assert(withinAppHistory);
    // Browsers don't move forward in history immediately. They do it at the next
    // event loop. So let's simulate that.
    return _nextEventLoop(() {
      _currentEntryIndex++;
      if (withinAppHistory) {
        _firePopStateEvent();
      }

      if (_debugLogHistoryActions) {
        print('$runtimeType.forward() -> $this');
      }
    });
  }

  final List<html.EventListener> listeners = <html.EventListener>[];

  @override
  ui.VoidCallback onPopState(html.EventListener fn) {
    listeners.add(fn);
    return () {
      // Schedule a micro task here to avoid removing the listener during
      // iteration in [_firePopStateEvent].
      scheduleMicrotask(() => listeners.remove(fn));
    };
  }

  /// Simulates the scheduling of a new event loop by creating a delayed future.
  /// Details explained here: https://webdev.dartlang.org/articles/performance/event-loop
  Future<void> _nextEventLoop(ui.VoidCallback callback) {
    return Future<void>.delayed(Duration.zero).then((_) => callback());
  }

  /// Invokes all the attached event listeners in order of
  /// attaching. This method should be called asynchronously to make it behave
  /// like a real browser.
  void _firePopStateEvent() {
    assert(withinAppHistory);
    final html.PopStateEvent event = html.PopStateEvent(
      'popstate',
      <String, dynamic>{'state': currentEntry.state},
    );
    for (int i = 0; i < listeners.length; i++) {
      listeners[i](event);
    }

    if (_debugLogHistoryActions) {
      print('$runtimeType: fired popstate event $event');
    }
  }

  @override
  String prepareExternalUrl(String internalUrl) => internalUrl;

  @override
  String toString() {
    final List<String> lines = List<String>(history.length);
    for (int i = 0; i < history.length; i++) {
      final TestHistoryEntry entry = history[i];
      lines[i] = _currentEntryIndex == i ? '* $entry' : '  $entry';
    }
    return '$runtimeType: [\n${lines.join('\n')}\n]';
  }
}
