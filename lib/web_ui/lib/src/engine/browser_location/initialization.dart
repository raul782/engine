// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.6
part of engine;

/// EXPERIMENTAL: Enable the Location Path rendering backend.
const bool experimentalUseLocationPath =
    bool.fromEnvironment('FLUTTER_WEB_USE_LOCATION_PATH_STRATEGY', defaultValue: false);

LocationStrategy initializeLocationPathStrategy() {
  PlatformLocation _platformLocation = BrowserPlatformLocation();
  return PathLocationStrategy(_platformLocation, '/');
}

LocationStrategy initializeLocationHashStrategy() {
  PlatformLocation _platformLocation = BrowserPlatformLocation();
  return HashLocationStrategy(_platformLocation);
}