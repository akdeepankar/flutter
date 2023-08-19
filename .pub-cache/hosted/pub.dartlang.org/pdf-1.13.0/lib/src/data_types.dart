/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'color.dart';
import 'object.dart';
import 'stream.dart';

abstract class PdfDataType {
  const PdfDataType();

  void output(PdfStream s);

  PdfStream _toStream() {
    final s = PdfStream();
    output(s);
    return s;
  }

  @override
  String toString() {
    return String.fromCharCodes(_toStream().output());
  }

  @visibleForTesting
  Uint8List toList() {
    return _toStream().output();
  }
}

class PdfBool extends PdfDataType {
  const PdfBool(this.value);

  final bool value;

  @override
  void output(PdfStream s) {
    s.putString(value ? 'true' : 'false');
  }
}

class PdfNum extends PdfDataType {
  const PdfNum(this.value)
      : assert(value != null),
        assert(value != double.infinity),
        assert(value != double.nan),
        assert(value != double.negativeInfinity);

  static const int precision = 5;

  final num value;

  @override
  void output(PdfStream s) {
    if (value is int) {
      s.putString(value.toInt().toString());
    } else {
      s.putString(value.toStringAsFixed(precision));
    }
  }
}

class PdfNumList extends PdfDataType {
  PdfNumList(this.values) : assert(values != null);

  final List<num> values;

  @override
  void output(PdfStream s) {
    for (var n = 0; n < values.length; n++) {
      if (n > 0) {
        s.putByte(0x20);
      }
      PdfNum(values[n]).output(s);
    }
  }
}

enum PdfStringFormat { binary, litteral }

class PdfString extends PdfDataType {
  const PdfString(this.value, [this.format = PdfStringFormat.litteral]);

  factory PdfString.fromString(String value) {
    return PdfString(_string(value), PdfStringFormat.litteral);
  }

  factory PdfString.fromStream(PdfStream value,
      [PdfStringFormat format = PdfStringFormat.litteral]) {
    return PdfString(value.output(), format);
  }

  factory PdfString.fromDate(DateTime date) {
    return PdfString(_date(date));
  }

  final Uint8List value;

  final PdfStringFormat format;

  static Uint8List _string(String value) {
    try {
      return latin1.encode(value);
    } catch (e) {
      return Uint8List.fromList(<int>[0xfe, 0xff] + _encodeUtf16be(value));
    }
  }

  static Uint8List _date(DateTime date) {
    final utcDate = date.toUtc();
    final year = utcDate.year.toString().padLeft(4, '0');
    final month = utcDate.month.toString().padLeft(2, '0');
    final day = utcDate.day.toString().padLeft(2, '0');
    final hour = utcDate.hour.toString().padLeft(2, '0');
    final minute = utcDate.minute.toString().padLeft(2, '0');
    final second = utcDate.second.toString().padLeft(2, '0');
    return _string('D:$year$month$day$hour$minute${second}Z');
  }

  /// Produce a list of UTF-16BE encoded bytes.
  static List<int> _encodeUtf16be(String str) {
    const UNICODE_REPLACEMENT_CHARACTER_CODEPOINT = 0xfffd;
    const UNICODE_BYTE_ZERO_MASK = 0xff;
    const UNICODE_BYTE_ONE_MASK = 0xff00;
    const UNICODE_VALID_RANGE_MAX = 0x10ffff;
    const UNICODE_PLANE_ONE_MAX = 0xffff;
    const UNICODE_UTF16_RESERVED_LO = 0xd800;
    const UNICODE_UTF16_RESERVED_HI = 0xdfff;
    const UNICODE_UTF16_OFFSET = 0x10000;
    const UNICODE_UTF16_SURROGATE_UNIT_0_BASE = 0xd800;
    const UNICODE_UTF16_SURROGATE_UNIT_1_BASE = 0xdc00;
    const UNICODE_UTF16_HI_MASK = 0xffc00;
    const UNICODE_UTF16_LO_MASK = 0x3ff;

    final encoding = <int>[];

    final add = (int unit) {
      encoding.add((unit & UNICODE_BYTE_ONE_MASK) >> 8);
      encoding.add(unit & UNICODE_BYTE_ZERO_MASK);
    };

    for (var unit in str.codeUnits) {
      if ((unit >= 0 && unit < UNICODE_UTF16_RESERVED_LO) ||
          (unit > UNICODE_UTF16_RESERVED_HI && unit <= UNICODE_PLANE_ONE_MAX)) {
        add(unit);
      } else if (unit > UNICODE_PLANE_ONE_MAX &&
          unit <= UNICODE_VALID_RANGE_MAX) {
        final base = unit - UNICODE_UTF16_OFFSET;
        add(UNICODE_UTF16_SURROGATE_UNIT_0_BASE +
            ((base & UNICODE_UTF16_HI_MASK) >> 10));
        add(UNICODE_UTF16_SURROGATE_UNIT_1_BASE +
            (base & UNICODE_UTF16_LO_MASK));
      } else {
        add(UNICODE_REPLACEMENT_CHARACTER_CODEPOINT);
      }
    }
    return encoding;
  }

  /// Escape special characters
  /// \ddd Character code ddd (octal)
  void _putTextBytes(PdfStream s, List<int> b) {
    for (var c in b) {
      switch (c) {
        case 0x0a: // \n Line feed (LF)
          s.putByte(0x5c);
          s.putByte(0x6e);
          break;
        case 0x0d: // \r Carriage return (CR)
          s.putByte(0x5c);
          s.putByte(0x72);
          break;
        case 0x09: // \t Horizontal tab (HT)
          s.putByte(0x5c);
          s.putByte(0x74);
          break;
        case 0x08: // \b Backspace (BS)
          s.putByte(0x5c);
          s.putByte(0x62);
          break;
        case 0x0c: // \f Form feed (FF)
          s.putByte(0x5c);
          s.putByte(0x66);
          break;
        case 0x28: // \( Left parenthesis
          s.putByte(0x5c);
          s.putByte(0x28);
          break;
        case 0x29: // \) Right parenthesis
          s.putByte(0x5c);
          s.putByte(0x29);
          break;
        case 0x5c: // \\ Backslash
          s.putByte(0x5c);
          s.putByte(0x5c);
          break;
        default:
          s.putByte(c);
      }
    }
  }

  /// Returns the ASCII/Unicode code unit corresponding to the hexadecimal digit
  /// [digit].
  int _codeUnitForDigit(int digit) =>
      digit < 10 ? digit + 0x30 : digit + 0x61 - 10;

  void _output(PdfStream s, Uint8List value) {
    switch (format) {
      case PdfStringFormat.binary:
        s.putByte(0x3c);
        for (int byte in value) {
          s.putByte(_codeUnitForDigit((byte & 0xF0) >> 4));
          s.putByte(_codeUnitForDigit(byte & 0x0F));
        }
        s.putByte(0x3e);
        break;
      case PdfStringFormat.litteral:
        s.putByte(40);
        _putTextBytes(s, value);
        s.putByte(41);
        break;
    }
  }

  @override
  void output(PdfStream s) {
    _output(s, value);
  }
}

class PdfSecString extends PdfString {
  const PdfSecString(this.object, Uint8List value,
      [PdfStringFormat format = PdfStringFormat.binary])
      : super(value, format);

  factory PdfSecString.fromString(
    PdfObject object,
    String value, [
    PdfStringFormat format = PdfStringFormat.litteral,
  ]) {
    return PdfSecString(
      object,
      PdfString._string(value),
      format,
    );
  }

  factory PdfSecString.fromStream(
    PdfObject object,
    PdfStream value, [
    PdfStringFormat format = PdfStringFormat.litteral,
  ]) {
    return PdfSecString(
      object,
      value.output(),
      format,
    );
  }

  factory PdfSecString.fromDate(PdfObject object, DateTime date) {
    return PdfSecString(
      object,
      PdfString._date(date),
      PdfStringFormat.litteral,
    );
  }

  final PdfObject object;

  @override
  void output(PdfStream s) {
    if (object.pdfDocument.encryption == null) {
      return super.output(s);
    }

    final enc = object.pdfDocument.encryption.encrypt(value, object);
    _output(s, enc);
  }
}

class PdfName extends PdfDataType {
  const PdfName(this.value) : assert(value != null);

  final String value;

  @override
  void output(PdfStream s) {
    assert(value[0] == '/');
    s.putString(value);
  }
}

class PdfNull extends PdfDataType {
  const PdfNull();

  @override
  void output(PdfStream s) {
    s.putString('null');
  }
}

class PdfIndirect extends PdfDataType {
  const PdfIndirect(this.ser, this.gen);

  final int ser;

  final int gen;

  @override
  void output(PdfStream s) {
    s.putString('$ser $gen R');
  }
}

class PdfArray extends PdfDataType {
  PdfArray([Iterable<PdfDataType> values]) {
    if (values != null) {
      this.values.addAll(values);
    }
  }

  factory PdfArray.fromObjects(List<PdfObject> objects) {
    return PdfArray(
        objects.map<PdfIndirect>((PdfObject e) => e.ref()).toList());
  }

  factory PdfArray.fromNum(List<num> list) {
    return PdfArray(list.map<PdfNum>((num e) => PdfNum(e)).toList());
  }

  final List<PdfDataType> values = <PdfDataType>[];

  void add(PdfDataType v) {
    values.add(v);
  }

  @override
  void output(PdfStream s) {
    s.putString('[');
    if (values.isNotEmpty) {
      for (var n = 0; n < values.length; n++) {
        final val = values[n];
        if (n > 0 &&
            !(val is PdfName ||
                val is PdfString ||
                val is PdfArray ||
                val is PdfDict)) {
          s.putByte(0x20);
        }
        val.output(s);
      }
    }
    s.putString(']');
  }
}

class PdfDict extends PdfDataType {
  PdfDict([Map<String, PdfDataType> values]) {
    if (values != null) {
      this.values.addAll(values);
    }
  }

  factory PdfDict.fromObjectMap(Map<String, PdfObject> objects) {
    return PdfDict(
      objects.map<String, PdfIndirect>(
        (String key, PdfObject value) =>
            MapEntry<String, PdfIndirect>(key, value.ref()),
      ),
    );
  }

  final Map<String, PdfDataType> values = <String, PdfDataType>{};

  bool get isNotEmpty => values.isNotEmpty;

  operator []=(String k, PdfDataType v) {
    values[k] = v;
  }

  @override
  void output(PdfStream s) {
    s.putBytes(const <int>[0x3c, 0x3c]);
    values.forEach((String k, PdfDataType v) {
      s.putString(k);
      if (v is PdfNum || v is PdfBool || v is PdfNull || v is PdfIndirect) {
        s.putByte(0x20);
      }
      v.output(s);
    });
    s.putBytes(const <int>[0x3e, 0x3e]);
  }

  bool containsKey(String key) {
    return values.containsKey(key);
  }
}

class PdfColorType extends PdfDataType {
  const PdfColorType(this.color);

  final PdfColor color;

  @override
  void output(PdfStream s) {
    if (color is PdfColorCmyk) {
      final PdfColorCmyk k = color;
      PdfArray.fromNum(<double>[
        k.cyan,
        k.magenta,
        k.yellow,
        k.black,
      ]).output(s);
    } else {
      PdfArray.fromNum(<double>[
        color.red,
        color.green,
        color.blue,
      ]).output(s);
    }
  }
}
