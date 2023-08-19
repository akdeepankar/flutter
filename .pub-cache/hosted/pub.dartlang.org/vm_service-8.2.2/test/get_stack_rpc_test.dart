// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:isolate' as isolate;
import 'dart:developer' as developer;

import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

import 'common/service_test_common.dart';
import 'common/test_helper.dart';

int counter = 0;
const stoppedAtLine = 25;
var port = new isolate.RawReceivePort(msgHandler);

// This name is used in a test below.
void msgHandler(_) {}

void periodicTask(_) {
  port.sendPort.send(34);
  developer.debugger(message: "fo", when: true); // We will be at the next line.
  counter++;
  if (counter % 300 == 0) {
    print('counter = $counter');
  }
}

void startTimer() {
  new Timer.periodic(const Duration(milliseconds: 10), periodicTask);
}

var tests = <IsolateTest>[
  hasStoppedAtBreakpoint,
  // Get stack
  (VmService service, IsolateRef isolateRef) async {
    final isolateId = isolateRef.id!;
    final stack = await service.getStack(isolateId);

    // Sanity check.
    expect(stack.frames!.length, greaterThanOrEqualTo(1));
    expect(stack.frames!.first.location!.line, stoppedAtLine);

    // Iterate over frames.
    int frameDepth = 0;
    for (final frame in stack.frames!) {
      print('checking frame $frameDepth');
      expect(frame.index!, frameDepth++);
//      expect(frame.code!.type, 'Code');
//      expect(frame.function!.type, 'Function');
//      expect(frame.location!.type, 'SourceLocation');
      expect(frame.location!.line, isNotNull);
    }

    // Sanity check.
    expect(stack.messages!.length, greaterThanOrEqualTo(1));

    // Iterate over messages.
    int messageDepth = 0;
    // objectId of message to be handled by msgHandler.
    var msgHandlerObjectId;
    for (final message in stack.messages!) {
      print('checking message $messageDepth');
      expect(message.index!, messageDepth++);
      expect(message.size!, greaterThanOrEqualTo(0));
      if (message.handler!.name!.contains('msgHandler')) {
        msgHandlerObjectId = message.messageObjectId;
      }
    }
    expect(msgHandlerObjectId, isNotNull);

    // Get object.
    final object =
        await service.getObject(isolateId, msgHandlerObjectId) as Instance;
    expect(object.valueAsString, '34');
  }
];

main(args) => runIsolateTests(
      args,
      tests,
      'get_stack_rpc_test.dart',
      testeeBefore: startTimer,
    );
