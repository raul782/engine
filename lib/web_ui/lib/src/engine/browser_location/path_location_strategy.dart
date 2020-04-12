// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.6
part of engine;

/// In order to use this [LocationStrategy] for an app, it needs to be set in
/// [ui.window.locationStrategy]:
/// This is an implementation of [LocationStrategy] that uses the browser URL's
/// [path](https://en.wikipedia.org/wiki/Uniform_Resource_Locator#Syntax)
/// to represent its state
///
/// If you're using `PathLocationStrategy`, you must provide a provider for
/// [appBaseHref] to a string representing the URL prefix that should
/// be preserved when generating and recognizing URLs.
///
/// For instance, if you provide an `appBaseHref` of `'/my/app'` and call
/// `location.go('/foo')`, the browser's URL will become
/// `example.com/my/app/foo`.
///
/// ### Example
///
/// ```
/// import 'package:angular/angular.dart' show bootstrap, Component, provide;
/// import 'package:angular_router/angular_router.dart'
///   show
///     appBaseHref,
///     Location,
///     ROUTER_DIRECTIVES,
///     ROUTER_PROVIDERS,
///     RouteConfig;
///
/// @Component({directives: [ROUTER_DIRECTIVES]})
/// @RouteConfig([
///  {...},
/// ])
/// class AppCmp {
///   constructor(location: Location) {
///     location.go('/foo');
///   }
/// }
///
/// bootstrap(AppCmp, [
///   ROUTER_PROVIDERS, // includes binding to PathLocationStrategy
///   provide(appBaseHref, {useValue: '/my/app'})
/// ]);
/// ```
class PathLocationStrategy extends LocationStrategy {
  final PlatformLocation _platformLocation;
  String _baseHref;
  PathLocationStrategy(this._platformLocation, [String href]) {
    href ??= _platformLocation.getBaseHrefFromDOM();
    if (href == null) {
      throw ArgumentError(
          'No base href set. Please provide a value for the appBaseHref token or add a base element to the document.');
    }
    _baseHref = href;
  }

  @override
  ui.VoidCallback onPopState(html.EventListener fn) {
    _platformLocation.onPopState(fn);
    return () => _platformLocation.offPopState(fn);
  }

  String getBaseHref() => _baseHref;

  String prepareExternalUrl(String internal) {
    return Location.joinWithSlash(_baseHref, internal);
  }

  String hash() => _platformLocation.hash;

  String query(String search) {
    return (search != null) ?
      Location.normalizeQueryParams(search) :
      '';
  }

  String path() =>
      _platformLocation.pathname + query(_platformLocation.search);

  void pushState(dynamic state, String title, String url, String queryParams) {
    var externalUrl =
    prepareExternalUrl(url + query(queryParams));
    _platformLocation.pushState(state, title, externalUrl);
  }

  void replaceState(
      dynamic state, String title, String url, String queryParams) {
    var externalUrl =
    prepareExternalUrl(url + query(queryParams));
    _platformLocation.replaceState(state, title, externalUrl);
  }

  @override
  Future<void> forward() {
    _platformLocation.forward();
    return _waitForPopState();
  }

  @override
  Future<void> back() {
    _platformLocation.back();
    return _waitForPopState();
  }
}
