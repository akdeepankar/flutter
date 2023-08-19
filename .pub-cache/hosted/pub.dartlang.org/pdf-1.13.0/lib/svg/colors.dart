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

import 'package:pdf/pdf.dart';

const svgColors = <String, PdfColor>{
  'indigo': PdfColor.fromInt(0xff4b0082),
  'gold': PdfColor.fromInt(0xffffd700),
  'hotpink': PdfColor.fromInt(0xffff69b4),
  'firebrick': PdfColor.fromInt(0xffb22222),
  'indianred': PdfColor.fromInt(0xffcd5c5c),
  'yellow': PdfColor.fromInt(0xffffff00),
  'mistyrose': PdfColor.fromInt(0xffffe4e1),
  'darkolivegreen': PdfColor.fromInt(0xff556b2f),
  'olive': PdfColor.fromInt(0xff808000),
  'darkseagreen': PdfColor.fromInt(0xff8fbc8f),
  'pink': PdfColor.fromInt(0xffffc0cb),
  'tomato': PdfColor.fromInt(0xffff6347),
  'lightcoral': PdfColor.fromInt(0xfff08080),
  'orangered': PdfColor.fromInt(0xffff4500),
  'navajowhite': PdfColor.fromInt(0xffffdead),
  'lime': PdfColor.fromInt(0xff00ff00),
  'palegreen': PdfColor.fromInt(0xff98fb98),
  'darkslategrey': PdfColor.fromInt(0xff2f4f4f),
  'greenyellow': PdfColor.fromInt(0xffadff2f),
  'burlywood': PdfColor.fromInt(0xffdeb887),
  'seashell': PdfColor.fromInt(0xfffff5ee),
  'mediumspringgreen': PdfColor.fromInt(0xff00fa9a),
  'fuchsia': PdfColor.fromInt(0xffff00ff),
  'papayawhip': PdfColor.fromInt(0xffffefd5),
  'blanchedalmond': PdfColor.fromInt(0xffffebcd),
  'transparent': PdfColor.fromInt(0xffffff),
  'chartreuse': PdfColor.fromInt(0xff7fff00),
  'dimgray': PdfColor.fromInt(0xff696969),
  'black': PdfColor.fromInt(0xff000000),
  'peachpuff': PdfColor.fromInt(0xffffdab9),
  'springgreen': PdfColor.fromInt(0xff00ff7f),
  'aquamarine': PdfColor.fromInt(0xff7fffd4),
  'white': PdfColor.fromInt(0xffffffff),
  'orange': PdfColor.fromInt(0xffffa500),
  'lightsalmon': PdfColor.fromInt(0xffffa07a),
  'darkslategray': PdfColor.fromInt(0xff2f4f4f),
  'brown': PdfColor.fromInt(0xffa52a2a),
  'ivory': PdfColor.fromInt(0xfffffff0),
  'dodgerblue': PdfColor.fromInt(0xff1e90ff),
  'peru': PdfColor.fromInt(0xffcd853f),
  'lawngreen': PdfColor.fromInt(0xff7cfc00),
  'chocolate': PdfColor.fromInt(0xffd2691e),
  'crimson': PdfColor.fromInt(0xffdc143c),
  'forestgreen': PdfColor.fromInt(0xff228b22),
  'darkgrey': PdfColor.fromInt(0xffa9a9a9),
  'lightseagreen': PdfColor.fromInt(0xff20b2aa),
  'cyan': PdfColor.fromInt(0xff00ffff),
  'mintcream': PdfColor.fromInt(0xfff5fffa),
  'silver': PdfColor.fromInt(0xffc0c0c0),
  'antiquewhite': PdfColor.fromInt(0xfffaebd7),
  'mediumorchid': PdfColor.fromInt(0xffba55d3),
  'skyblue': PdfColor.fromInt(0xff87ceeb),
  'gray': PdfColor.fromInt(0xff808080),
  'darkturquoise': PdfColor.fromInt(0xff00ced1),
  'goldenrod': PdfColor.fromInt(0xffdaa520),
  'darkgreen': PdfColor.fromInt(0xff006400),
  'floralwhite': PdfColor.fromInt(0xfffffaf0),
  'darkviolet': PdfColor.fromInt(0xff9400d3),
  'darkgray': PdfColor.fromInt(0xffa9a9a9),
  'moccasin': PdfColor.fromInt(0xffffe4b5),
  'saddlebrown': PdfColor.fromInt(0xff8b4513),
  'grey': PdfColor.fromInt(0xff808080),
  'darkslateblue': PdfColor.fromInt(0xff483d8b),
  'lightskyblue': PdfColor.fromInt(0xff87cefa),
  'lightpink': PdfColor.fromInt(0xffffb6c1),
  'mediumvioletred': PdfColor.fromInt(0xffc71585),
  'slategrey': PdfColor.fromInt(0xff708090),
  'red': PdfColor.fromInt(0xffff0000),
  'deeppink': PdfColor.fromInt(0xffff1493),
  'limegreen': PdfColor.fromInt(0xff32cd32),
  'darkmagenta': PdfColor.fromInt(0xff8b008b),
  'palegoldenrod': PdfColor.fromInt(0xffeee8aa),
  'plum': PdfColor.fromInt(0xffdda0dd),
  'turquoise': PdfColor.fromInt(0xff40e0d0),
  'lightgrey': PdfColor.fromInt(0xffd3d3d3),
  'lightgoldenrodyellow': PdfColor.fromInt(0xfffafad2),
  'darkgoldenrod': PdfColor.fromInt(0xffb8860b),
  'lavender': PdfColor.fromInt(0xffe6e6fa),
  'maroon': PdfColor.fromInt(0xff800000),
  'yellowgreen': PdfColor.fromInt(0xff9acd32),
  'sandybrown': PdfColor.fromInt(0xfff4a460),
  'thistle': PdfColor.fromInt(0xffd8bfd8),
  'violet': PdfColor.fromInt(0xffee82ee),
  'navy': PdfColor.fromInt(0xff000080),
  'magenta': PdfColor.fromInt(0xffff00ff),
  'dimgrey': PdfColor.fromInt(0xff696969),
  'tan': PdfColor.fromInt(0xffd2b48c),
  'rosybrown': PdfColor.fromInt(0xffbc8f8f),
  'olivedrab': PdfColor.fromInt(0xff6b8e23),
  'blue': PdfColor.fromInt(0xff0000ff),
  'lightblue': PdfColor.fromInt(0xffadd8e6),
  'ghostwhite': PdfColor.fromInt(0xfff8f8ff),
  'honeydew': PdfColor.fromInt(0xfff0fff0),
  'cornflowerblue': PdfColor.fromInt(0xff6495ed),
  'slateblue': PdfColor.fromInt(0xff6a5acd),
  'linen': PdfColor.fromInt(0xfffaf0e6),
  'darkblue': PdfColor.fromInt(0xff00008b),
  'powderblue': PdfColor.fromInt(0xffb0e0e6),
  'seagreen': PdfColor.fromInt(0xff2e8b57),
  'darkkhaki': PdfColor.fromInt(0xffbdb76b),
  'snow': PdfColor.fromInt(0xfffffafa),
  'sienna': PdfColor.fromInt(0xffa0522d),
  'mediumblue': PdfColor.fromInt(0xff0000cd),
  'royalblue': PdfColor.fromInt(0xff4169e1),
  'lightcyan': PdfColor.fromInt(0xffe0ffff),
  'green': PdfColor.fromInt(0xff008000),
  'mediumpurple': PdfColor.fromInt(0xff9370db),
  'midnightblue': PdfColor.fromInt(0xff191970),
  'cornsilk': PdfColor.fromInt(0xfffff8dc),
  'paleturquoise': PdfColor.fromInt(0xffafeeee),
  'bisque': PdfColor.fromInt(0xffffe4c4),
  'slategray': PdfColor.fromInt(0xff708090),
  'darkcyan': PdfColor.fromInt(0xff008b8b),
  'khaki': PdfColor.fromInt(0xfff0e68c),
  'wheat': PdfColor.fromInt(0xfff5deb3),
  'teal': PdfColor.fromInt(0xff008080),
  'darkorchid': PdfColor.fromInt(0xff9932cc),
  'deepskyblue': PdfColor.fromInt(0xff00bfff),
  'salmon': PdfColor.fromInt(0xfffa8072),
  'darkred': PdfColor.fromInt(0xff8b0000),
  'steelblue': PdfColor.fromInt(0xff4682b4),
  'palevioletred': PdfColor.fromInt(0xffdb7093),
  'lightslategray': PdfColor.fromInt(0xff778899),
  'aliceblue': PdfColor.fromInt(0xfff0f8ff),
  'lightslategrey': PdfColor.fromInt(0xff778899),
  'lightgreen': PdfColor.fromInt(0xff90ee90),
  'orchid': PdfColor.fromInt(0xffda70d6),
  'gainsboro': PdfColor.fromInt(0xffdcdcdc),
  'mediumseagreen': PdfColor.fromInt(0xff3cb371),
  'lightgray': PdfColor.fromInt(0xffd3d3d3),
  'mediumturquoise': PdfColor.fromInt(0xff48d1cc),
  'lemonchiffon': PdfColor.fromInt(0xfffffacd),
  'cadetblue': PdfColor.fromInt(0xff5f9ea0),
  'lightyellow': PdfColor.fromInt(0xffffffe0),
  'lavenderblush': PdfColor.fromInt(0xfffff0f5),
  'coral': PdfColor.fromInt(0xffff7f50),
  'purple': PdfColor.fromInt(0xff800080),
  'aqua': PdfColor.fromInt(0xff00ffff),
  'whitesmoke': PdfColor.fromInt(0xfff5f5f5),
  'mediumslateblue': PdfColor.fromInt(0xff7b68ee),
  'darkorange': PdfColor.fromInt(0xffff8c00),
  'mediumaquamarine': PdfColor.fromInt(0xff66cdaa),
  'darksalmon': PdfColor.fromInt(0xffe9967a),
  'beige': PdfColor.fromInt(0xfff5f5dc),
  'blueviolet': PdfColor.fromInt(0xff8a2be2),
  'azure': PdfColor.fromInt(0xfff0ffff),
  'lightsteelblue': PdfColor.fromInt(0xffb0c4de),
  'oldlace': PdfColor.fromInt(0xfffdf5e6),
};
