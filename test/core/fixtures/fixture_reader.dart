import 'dart:io';

String fixture(String name) {
  return File('test/core/fixtures/$name').readAsStringSync();
}
