
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';


//https://stackoverflow.com/questions/50320479/flutter-how-would-one-save-a-canvas-custompainter-to-an-image-file
// USE THIS
void main() => runApp(MyApp());

loadModel() async {
  String res = await Tflite.loadModel(
      model: "assets/converted_model.tflite",
      labels: "assets/labels.txt",
      numThreads: 1 // defaults to 1
      );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Offset> points = <Offset>[];



  getImage() async {
    final PictureRecorder recorder = PictureRecorder();
    // print(points);
    Sketcher(points).paint(Canvas(recorder), Size(280,280));
    final Picture picture = recorder.endRecording();
    final image = await picture.toImage(280,280);
    final image_2 = await image.toByteData(format: ImageByteFormat.png);
    // WORKS!!!!!!!!!!!!!!!!!!!!
    print(image_2.buffer.asInt8List());
  }

  @override
  Widget build(BuildContext context) {

    final Container sketchArea = Container(
      margin: EdgeInsets.all(1.0),
      alignment: Alignment.topLeft,
      color: Colors.blueGrey[50],
      child: ClipRect(
              child: CustomPaint(
          size: Size(280, 280),
          painter: Sketcher(points),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Sketcher'),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.all(16),
          color: Colors.red,
          alignment: Alignment.center,
          child: Text('Header'),
        ),
      ),
            Container(
              width: 280,
              height: 280,
              color: Colors.blue,
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    RenderBox box = context.findRenderObject();
                    Offset point = box.globalToLocal(details.globalPosition);
                    point = point.translate(0.0, -(AppBar().preferredSize.height));

                    points = List.from(points)..add(point);
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  points.add(null);
                },
                child:sketchArea,
              ),
            ),
            Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.all(16),
          color: Colors.red,
          alignment: Alignment.center,
          child: Text('Footer'),
        ),
      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'clear Screen',
        backgroundColor: Colors.red,
        child: Icon(Icons.refresh),
        onPressed: () {
          // print(points);
          setState(() {
            getImage();
            points.clear();
          });
          ;
        },
      ),
    );
  }
}

class Sketcher extends CustomPainter {
  final List<Offset> points;

  Sketcher(this.points);

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return oldDelegate.points != points;
  }
  Size size = Size(280, 280);
  void paint(Canvas canvas, size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }
}
