import 'package:flutter/material.dart';
import 'package:webunicamp/src/widgets/custom_appbar.dart';

class Building {
  final String name;
  final List<Offset> points;
  final Color color;

  Building({required this.name, required this.points, required this.color});
}

class BuildingPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  BuildingPainter(this.points, {this.color = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BuildingScreen extends StatelessWidget {
  final List<Building> buildings;

  BuildingScreen({required this.buildings});

  @override
  Widget build(BuildContext context) {
    // Calculate the screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Calculate the overall bounding box for all buildings
    final overallBounds = _calculateOverallBounds();

    // Scale factor based on 70% of the screen size
    final scaleFactor = 0.75;
    final scaledWidth = overallBounds.width * scaleFactor;  
    final scaledHeight = overallBounds.height * scaleFactor;

    // Find the scaling factor based on the aspect ratio
    final widthScaleFactor = screenWidth * scaleFactor / overallBounds.width;
    final heightScaleFactor = screenHeight * scaleFactor / overallBounds.height;

    // Select the smaller scaling factor to maintain aspect ratio
    final finalScaleFactor = widthScaleFactor < heightScaleFactor
        ? widthScaleFactor
        : heightScaleFactor;

    // Calculate the scaled map dimensions
    final finalScaledWidth = overallBounds.width * finalScaleFactor;
    final finalScaledHeight = overallBounds.height * finalScaleFactor;

    // Calculate offsets to center the map on the screen
    final dxOffset = (screenWidth - finalScaledWidth) / 2 - overallBounds.left * finalScaleFactor;
    final dyOffset = (screenHeight - finalScaledHeight) / 2 - overallBounds.top * finalScaleFactor;

    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/mainpage.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: buildings.map((building) {
            // Scale and adjust each building's points based on scaleFactor and offsets
            final scaledPoints = building.points
                .map((point) => Offset(
                      point.dx * finalScaleFactor + dxOffset,
                      point.dy * finalScaleFactor + dyOffset,
                    ))
                .toList();

            // Calculate adjusted bounding box for the scaled building
            final bounds = _calculateBounds(scaledPoints);

            return Positioned(
              left: bounds.left,
              top: bounds.top,
              width: bounds.width,
              height: bounds.height,
              child: GestureDetector(
                onTapDown: (details) {
                if (_isPointInsidePolygon(details.localPosition, scaledPoints, bounds)) {
                  showCustomDialog(context, building.name);
                }
              },
                child: CustomPaint(
                  painter: BuildingPainter(
                    scaledPoints.map((point) => Offset(
                          point.dx - bounds.left,
                          point.dy - bounds.top,
                        )).toList(),
                  color: building.color,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Calculate bounding box for all buildings
  Rect _calculateOverallBounds() {
    final allPoints = buildings.expand((building) => building.points).toList();
    return _calculateBounds(allPoints);
  }

  // Helper method to calculate bounding box
  Rect _calculateBounds(List<Offset> points) {
    final left = points.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final top = points.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    final right = points.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    final bottom = points.map((p) => p.dy).reduce((a, b) => a > b ? a : b);

    return Rect.fromLTRB(left, top, right, bottom);
  }

  // Helper method to check if a point is inside a polygon
  bool _isPointInsidePolygon(Offset point, List<Offset> polygon, Rect bounds) {
    final adjustedPoint = Offset(point.dx + bounds.left, point.dy + bounds.top);
    bool isInside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      if ((polygon[i].dy > adjustedPoint.dy) !=
              (polygon[j].dy > adjustedPoint.dy) &&
          (adjustedPoint.dx <
              (polygon[j].dx - polygon[i].dx) *
                      (adjustedPoint.dy - polygon[i].dy) /
                      (polygon[j].dy - polygon[i].dy) +
                  polygon[i].dx)) {
        isInside = !isInside;
      }
    }
    return isInside;
  }
}

void showCustomDialog(BuildContext context, String buildingName) {
  showDialog(
    context: context,
    barrierDismissible: true, // Allows closing the dialog by tapping outside of it
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Tapped on $buildingName',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    },
  );
}