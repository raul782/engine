// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.6
part of engine;

/// An implementation of [PlatformLocation] for the browser.
class BrowserPlatformLocation extends PlatformLocation {
  html.Location _location;
  html.History _history;

  BrowserPlatformLocation() {
    baseHRefFromDOM = baseHrefFromDOM;
    _init();
  }
  // This is moved to its own method so that `MockPlatformLocationStrategy` can overwrite it

  void _init() {
    _location = html.window.location;
    _history = html.window.history;
  }


  String getBaseHrefFromDOM() => baseHRefFromDOM();

  @override
  void onPopState(html.EventListener fn) {
    html.window.addEventListener('popstate', fn);
  }

  @override
  void offPopState(html.EventListener fn) {
    html.window.removeEventListener('popstate', fn);
  }

  @override
  void onHashChange(html.EventListener fn) {
    html.window.addEventListener('hashchange', fn);
  }

  @override
  void offHashChange(html.EventListener fn) {
    html.window.removeEventListener('hashchange', fn);
  }

  @override
  String get pathname => _location.pathname;

  @override
  String get search => _location.search;

  @override
  String get hash => _location.hash;

  @override
  void pushState(dynamic state, String title, String url) {
    _history.pushState(state, title, url);
  }

  @override
  void replaceState(dynamic state, String title, String url) {
    _history.replaceState(state, title, url);
  }

  @override
  void back() {
    _history.back();
  }

  @override
  void forward() {
    _history.forward();
  }
}