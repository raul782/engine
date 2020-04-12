// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.6
part of engine;

// TODO(mdebbar): add other strategies.

// Some parts of this file were inspired/copied from the AngularDart router.

/// This is an implementation of [LocationStrategy] that uses the browser URL's
/// [hash fragments](https://en.wikipedia.org/wiki/Uniform_Resource_Locator#Syntax)
/// to represent its state.
///
/// In order to use this [LocationStrategy] for an app, it needs to be set in
/// [ui.window.locationStrategy]:
///
/// ```dart
/// import 'package:flutter_web/material.dart';
/// import 'package:flutter_web/ui.dart' as ui;
///
/// void main() {
///   ui.window.locationStrategy = const ui.HashLocationStrategy();
///   runApp(MyApp());
/// }
/// ```
class HashLocationStrategy extends LocationStrategy {
  final PlatformLocation _platformLocation;
  final String _baseHref;

  HashLocationStrategy(
      this._platformLocation,
        [String baseHref]
      ) : _baseHref = baseHref ?? '';

  @override
  ui.VoidCallback onPopState(html.EventListener fn) {
    _platformLocation.onPopState(fn);
    return () => _platformLocation.offPopState(fn);
  }

  @override
  String hash() {
    return _platformLocation.hash;
  }

  @override
  String path() {
    // the hash value is always prefixed with a `#`
    // and if it is empty then it will stay empty
    String path = _platformLocation.hash ?? '';
    assert(path.isEmpty || path.startsWith('#'));
    // Dart will complain if a call to substring is
    // executed with a position value that exceeds the
    // length of string.
    return path.isEmpty ? path : path.substring(1);
  }

  @override
  String prepareExternalUrl(String internalUrl) {
    // It's convention that if the hash path is empty, we omit the `#`; however,
    // if the empty URL is pushed it won't replace any existing fragment. So
    // when the hash path is empty, we instead return the location's path and
    // query.
    return internalUrl.isEmpty
        ? '${_platformLocation.pathname}${_platformLocation.search}'
        : '#$internalUrl';
  }

  @override
  void pushState(dynamic state, String title, String url, String queryParams) {
    _platformLocation.pushState(state, title, prepareExternalUrl(url));
  }

  @override
  void replaceState(dynamic state, String title, String url, String queryParams) {
    _platformLocation.replaceState(state, title, prepareExternalUrl(url));
  }

  @override
  Future<void> back() {
    _platformLocation.back();
    return _waitForPopState();
  }

  @override
  Future<void> forward() {
    _platformLocation.forward();
    return _waitForPopState();
  }

  @override
  String getBaseHref() {
    return _baseHref;
  }
}