// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:expect/expect.dart';

@pragma('vm:never-inline')
double getDoubleWithHeapObjectTag() {
  final bd = ByteData(8);
  bd.setUint64(0, 0x8000000180000001, Endian.host);
  final double v = bd.getFloat64(0, Endian.host);
  return v;
}

class Foo {
  int val;
  Foo nxt;
  Foo(this.val);
}

final int kNum = 100000;
var global_foo;

final dbl2 = getDoubleWithHeapObjectTag();

@pragma('vm:never-inline')
int bar(int i, double k, Foo foo, double j) {
  var last = null;
  for (int i = 0; i < kNum; i++) {
    final new_node = Foo(i);
    new_node.nxt = last;
    last = new_node;
    foo.val = i;
    Expect.equals(global_foo.val, i);
  }
  Expect.equals(k, 2 * dbl2);
  Expect.equals(j, dbl2);
  while (last.nxt != null) last = last.nxt;
  return i + 2 + j.toInt() - j.toInt() + last.val;
}

@pragma('vm:never-inline')
create_foo() {
  global_foo = Foo(1);
}

final bool kTrue = int.parse('1') == 1;

main() {
  create_foo();
  final dbl = getDoubleWithHeapObjectTag();
  Expect.equals(3,
      bar(kTrue ? 1 : 2, kTrue ? 2 * dbl : 0.0, global_foo, kTrue ? dbl : 1.0));
}
