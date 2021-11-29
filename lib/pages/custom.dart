import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../data.dart';

List<Figure> simpleTooltip(
  Offset anchor,
  List<Tuple> selectedTuples,
) {
  List<Figure> figures;

  String textContent = '';
  final fields = selectedTuples.first.keys.toList();
  if (selectedTuples.length == 1) {
    final original = selectedTuples.single;
    var field = fields.first;
    textContent += '$field: ${original[field]}';
    for (var i = 1; i < fields.length; i++) {
      field = fields[i];
      textContent += '\n$field: ${original[field]}';
    }
  } else {
    for (var original in selectedTuples) {
      final domainField = fields.first;
      final measureField = fields.last;
      textContent += '\n${original[domainField]}: ${original[measureField]}';
    }
  }

  const textStyle = TextStyle(fontSize: 12);
  const padding = EdgeInsets.all(5);
  const align = Alignment.topRight;
  const offset = Offset(5, -5);
  const radius = Radius.circular(6);
  const elevation = 1.0;
  const backgroundColor = Color(0xFF404040);

  final painter = TextPainter(
    text: TextSpan(text: textContent, style: textStyle),
    textDirection: TextDirection.ltr,
  );
  painter.layout();

  final width = padding.left + painter.width + padding.right;
  final height = padding.top + painter.height + padding.bottom;

  final paintPoint = getPaintPoint(
    anchor + offset,
    width,
    height,
    align,
  );

  final widow = Rect.fromLTWH(
    paintPoint.dx,
    paintPoint.dy,
    width,
    height,
  );

  final widowPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(widow, radius),
    );

  figures = <Figure>[];

  figures.add(ShadowFigure(
    widowPath,
    backgroundColor,
    elevation,
  ));
  figures.add(PathFigure(
    widowPath,
    Paint()..color = backgroundColor,
  ));
  figures.add(TextFigure(
    painter,
    paintPoint + padding.topLeft,
  ));

  return figures;
}

class CustomPage extends StatelessWidget {
  const CustomPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: basicData,
                  variables: {
                    'data': Variable(
                      accessor: (Map map) => map['data'] as String,
                    ),
                    'sold': Variable(accessor: (Map map) => map['sold'] as num, scale: LinearScale(min: 0,tickInterval: 100)),
                  },
                  elements: [
                    IntervalElement(
                      shape: ShapeAttr(
                          value: RectShape(
                              borderRadius:
                                  const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)))),
                      label: LabelAttr(encoder: (tuple) => Label(tuple['sold'].toString())),
                      color: ColorAttr(value: const Color(0xFF404040)),
                    ),
                  ],
                  axes: [
                    AxisGuide(
                      line: StrokeStyle(
                        color: Colors.blue,
                      ),
                      label: LabelStyle(
                        const TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                        ),
                        offset: const Offset(0, 7.5),
                      ),
                    ),
                    AxisGuide(
                      line: StrokeStyle(
                        color: Colors.blue,
                      ),
                      label: LabelStyle(
                        const TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                        ),
                        offset: const Offset(0, 7.5),
                      ),
                    ),
                  ],
                  selections: {'tap': PointSelection(dim: 1)},
                  tooltip: TooltipGuide(renderer: simpleTooltip),
                  crosshair: CrosshairGuide(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
