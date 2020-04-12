// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.6
part of engine;

html.AnchorElement _urlParsingNode;
html.Element _baseElement;

String baseHrefFromDOM() {
  var href = _getBaseElementHref();
  if (href == null) {
    return null;
  }
  return _relativePath(href);
}

String _getBaseElementHref() {
  if (_baseElement == null) {
    _baseElement = html.document.querySelector('base');
    if (_baseElement == null) {
      return null;
    }
  }
  return _baseElement.getAttribute('href');
}

// based on urlUtils.js in AngularJS 1.
String _relativePath(String url) {
  _urlParsingNode ??= html.AnchorElement();
  _urlParsingNode.href = url;
  var pathname = _urlParsingNode.pathname;
  return (pathname.isEmpty || pathname[0] == '/') ? pathname : '/$pathname';
}
