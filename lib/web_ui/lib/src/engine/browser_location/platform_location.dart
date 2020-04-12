// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.6
part of engine;

/// [PlatformLocation] encapsulates all calls to DOM apis, which allows the
/// [LocationStrategy] classes to be platform agnostic and testable.
///
/// The [PlatformLocation] class is used directly by all implementations of
/// [LocationStrategy] when they need to interact with the DOM apis like
/// pushState, popState, etc...
abstract class PlatformLocation {
  const PlatformLocation();

  String getBaseHrefFromDOM();

  void onPopState(html.EventListener fn);
  void offPopState(html.EventListener fn);

  void onHashChange(html.EventListener fn);
  void offHashChange(html.EventListener fn);

  String get pathname;
  String get search;
  String get hash;

  void pushState(dynamic state, String title, String url);
  void replaceState(dynamic state, String title, String url);
  void forward();
  void back();
}

typedef String BaseHRefFromDOMProvider();

/// Returns base href from browser location.
BaseHRefFromDOMProvider baseHRefFromDOM;