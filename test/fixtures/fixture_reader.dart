import 'dart:io';

String fixtureJson(String name) =>
    File('test/fixtures/$name').readAsStringSync();
