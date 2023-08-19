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

import 'annotation.dart';
import 'data_types.dart';
import 'document.dart';
import 'graphic_stream.dart';
import 'graphics.dart';
import 'object.dart';
import 'object_stream.dart';
import 'page_format.dart';

/// Page object, which will hold any contents for this page.
class PdfPage extends PdfObject with PdfGraphicStream {
  /// This constructs a Page object, which will hold any contents for this
  /// page.
  PdfPage(PdfDocument pdfDocument, {this.pageFormat = PdfPageFormat.standard})
      : super(pdfDocument, '/Page') {
    pdfDocument.pdfPageList.pages.add(this);
  }

  /// This is this page format, ie the size of the page, margins, and rotation
  PdfPageFormat pageFormat;

  /// This holds the contents of the page.
  List<PdfObjectStream> contents = <PdfObjectStream>[];

  /// Object ID that contains a thumbnail sketch of the page.
  /// -1 indicates no thumbnail.
  PdfObject thumbnail;

  /// This holds any Annotations contained within this page.
  List<PdfAnnot> annotations = <PdfAnnot>[];

  /// This returns a [PdfGraphics] object, which can then be used to render
  /// on to this page. If a previous [PdfGraphics] object was used, this object
  /// is appended to the page, and will be drawn over the top of any previous
  /// objects.
  PdfGraphics getGraphics() {
    final stream = PdfObjectStream(pdfDocument);
    final g = PdfGraphics(this, stream.buf);
    contents.add(stream);
    return g;
  }

  /// This adds an Annotation to the page.
  void addAnnotation(PdfObject ob) {
    annotations.add(ob);
  }

  @override
  void prepare() {
    super.prepare();

    // the /Parent pages object
    params['/Parent'] = pdfDocument.pdfPageList.ref();

    // the /MediaBox for the page size
    params['/MediaBox'] =
        PdfArray.fromNum(<double>[0, 0, pageFormat.width, pageFormat.height]);

    // Rotation (if not zero)
//        if(rotate!=0) {
//            os.write("/Rotate ");
//            os.write(Integer.toString(rotate).getBytes());
//            os.write("\n");
//        }

    // the /Contents pages object
    if (contents.isNotEmpty) {
      if (contents.length == 1) {
        params['/Contents'] = contents.first.ref();
      } else {
        params['/Contents'] = PdfArray.fromObjects(contents);
      }
    }

    // The thumbnail
    if (thumbnail != null) {
      params['/Thumb'] = thumbnail.ref();
    }

    // The /Annots object
    if (annotations.isNotEmpty) {
      params['/Annots'] = PdfArray.fromObjects(annotations);
    }
  }
}
