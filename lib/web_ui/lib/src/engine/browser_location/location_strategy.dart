// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.6
part of engine;

/// [LocationStrategy] is responsible for representing and reading route state
/// from the browser's URL.
///
/// At the moment, only one strategy is implemented: [HashLocationStrategy].
///
/// This is used by [BrowserHistory] to interact with browser history APIs.
abstract class LocationStrategy {
  const LocationStrategy();

  /// Subscribes to popstate events and returns a function that could be used to
  /// unsubscribe from popstate events.
  ui.VoidCallback onPopState(html.EventListener fn);

  /// The active path in the browser history.
  String path();

  String hash();

  /// Given a path that's internal to the app, create the external url that
  /// will be used in the browser.
  String prepareExternalUrl(String internalUrl);

  /// Push a new history entry.
  void pushState(dynamic state, String title, String url, String queryParams);

  /// Replace the currently active history entry.
  void replaceState(dynamic state, String title, String url, String queryParams);

  /// Go to the previous history entry.
  Future<void> back();

  /// Go to the next history entry.
  Future<void> forward();

  /// Get BaseHref
  String getBaseHref();

  /// Waits until the next popstate event is fired.
  ///
  /// This is useful for example to wait until the browser has handled the
  /// `history.back` transition.
  Future<void> _waitForPopState() {
    final Completer<void> completer = Completer<void>();
    ui.VoidCallback unsubscribe;
    unsubscribe = onPopState((_) {
      unsubscribe();
      completer.complete();
    });
    return completer.future;
  }
}