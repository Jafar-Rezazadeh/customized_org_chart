import 'dart:ui';

import 'package:customized_org_chart/org_chart/controller.dart';
import 'package:customized_org_chart/org_chart/line_style.dart';
import 'package:customized_org_chart/org_chart/node.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

///The main Painter for drawing the arrows between the nodes.
class EdgePainter<E> extends CustomPainter {
  /// The graph that contains the nodes we want to draw the arrows for.
  OrgChartController<E> controller;

  /// the path of the arrows
  Path linePath = Path();
  final Map<OrgNode<E>, LineStyle> lineStyles;
  double cornerRadius;

  /// The paint to draw the arrows with
  Paint linePaint;

  EdgePainter({
    required this.controller,
    required this.linePaint,
    this.cornerRadius = 10,
    this.lineStyles = const {},
  });

  LineStyle getStyleForNode(OrgNode<E> node, OrgNode<E>? subNode) {
    // Default to global linePaint style
    return lineStyles[subNode ?? node] ??
        LineStyle(
          color: linePaint.color,
          strokeWidth: linePaint.strokeWidth,
        );
  }

  /// This function is called recursively to draw the arrows for each node and the nodes below it.
  /// i want to add a border radius to the arrows later on, the commented code is a wrong implementation of that.
  /// There is a lot of things i want to change here, the way the arrows are drawn, style, and animations.
  drawArrows(OrgNode<E> node, Canvas canvas) {
    switch (controller.orientation) {
      case OrgChartOrientation.topToBottom:
        drawLineTopToBottom(node, canvas);
        break;
      case OrgChartOrientation.leftToRight:
        drawArrowsLeftToRight(node, canvas);
        break;
      default:
    }
  }

  drawLineTopToBottom(OrgNode<E> node, Canvas canvas) {
    List<OrgNode<E>> subNodes = controller.getSubNodes(node);

    if (node.hideNodes == false) {
      if (allLeaf(subNodes)) {
        _drawLeafNode(subNodes, node, canvas);
      } else {
        _drawNonLeafNodes(subNodes, node, canvas);
      }
    }
  }

  /// returns True if no nodes
  bool allLeaf(List<OrgNode<E>> nodes) {
    return nodes.every((element) =>
        controller.getSubNodes(element).isEmpty || element.hideNodes);
  }

  void _drawLeafNode(
      List<OrgNode<E>> subNodes, OrgNode<E> node, Canvas canvas) {
    for (var n in subNodes) {
      final bool horizontal = n.position.dx > node.position.dx;
      final bool vertical = n.position.dy > node.position.dy;
      final bool c = vertical ? horizontal : !horizontal;

      LineStyle style = getStyleForNode(node, n);
      Paint currentPaint = style.toPaint();
      Path singleLinePath = Path();

      _defineLeafPath(singleLinePath, node, n, vertical, horizontal, c);

      // Draw the single line path with the current paint
      if (style.isDashed) {
        drawDashedPath(canvas, singleLinePath, currentPaint, style.dashWidth,
            style.dashSpace);
      } else {
        canvas.drawPath(singleLinePath, currentPaint);
      }
    }
  }

  void _defineLeafPath(Path singleLinePath, OrgNode<dynamic> node,
      OrgNode<dynamic> n, bool vertical, bool horizontal, bool c) {
    singleLinePath.moveTo(
      node.position.dx + controller.boxSize.width / 2,
      node.position.dy + controller.boxSize.height / 2,
    );
    singleLinePath.lineTo(
      node.position.dx + controller.boxSize.width / 2,
      n.position.dy +
          controller.boxSize.height / 2 +
          (vertical ? -1 : 1) * cornerRadius,
    );

    singleLinePath.arcToPoint(
      Offset(
        node.position.dx +
            controller.boxSize.width / 2 +
            (horizontal ? 1 : -1) * cornerRadius,
        n.position.dy + controller.boxSize.height / 2,
      ),
      radius: Radius.circular(cornerRadius),
      clockwise: !c,
    );

    singleLinePath.lineTo(
      n.position.dx + controller.boxSize.width / 2,
      n.position.dy + controller.boxSize.height / 2,
    );
  }

  void _drawNonLeafNodes(
      List<OrgNode<E>> subNodes, OrgNode<E> node, Canvas canvas) {
    for (var n in subNodes) {
      final minx = math.min(node.position.dx, n.position.dx);
      final maxX = math.max(node.position.dx, n.position.dx);
      final minY = math.min(node.position.dy, n.position.dy);
      final maxY = math.max(node.position.dy, n.position.dy);

      final dy = (maxY - minY) / 2 + controller.boxSize.height / 2;

      bool horizontal = maxX == node.position.dx;
      bool vertical = maxY == node.position.dy;

      bool clockwise = vertical ? !horizontal : horizontal;

      LineStyle style = getStyleForNode(node, n);
      Paint currentPaint = style.toPaint();
      Path singleLinePath = Path();

      drawNonLeafPaths(singleLinePath, node, minY, dy, vertical, maxX, minx,
          horizontal, clockwise, n);

      // Draw the single line path with the current paint
      if (style.isDashed) {
        drawDashedPath(canvas, singleLinePath, currentPaint, style.dashWidth,
            style.dashSpace);
      } else {
        canvas.drawPath(singleLinePath, currentPaint);
      }

      drawLineTopToBottom(n, canvas);
    }
  }

  void drawNonLeafPaths(
      Path singleLinePath,
      OrgNode<dynamic> node,
      double minY,
      double dy,
      bool vertical,
      double maxX,
      double minx,
      bool horizontal,
      bool clockwise,
      OrgNode<dynamic> n) {
    singleLinePath.moveTo(
      node.position.dx + controller.boxSize.width / 2,
      node.position.dy + controller.boxSize.height / 2,
    );

    singleLinePath.lineTo(
      node.position.dx + controller.boxSize.width / 2,
      minY + dy + (vertical ? 1 : -1) * cornerRadius,
    );

    if (maxX - minx > cornerRadius * 2) {
      singleLinePath.arcToPoint(
          Offset(
            node.position.dx +
                controller.boxSize.width / 2 +
                (!(horizontal) ? 1 : -1) * cornerRadius,
            minY + dy,
          ),
          radius: Radius.circular(cornerRadius),
          clockwise: clockwise);

      singleLinePath.lineTo(
        n.position.dx +
            controller.boxSize.width / 2 +
            (horizontal ? 1 : -1) * cornerRadius,
        minY + dy,
      );
      singleLinePath.arcToPoint(
        Offset(
          n.position.dx + controller.boxSize.width / 2,
          minY + dy + (!vertical ? 1 : -1) * cornerRadius,
        ),
        radius: Radius.circular(cornerRadius),
        clockwise: !clockwise,
      );
    }

    singleLinePath.lineTo(
      n.position.dx + controller.boxSize.width / 2,
      n.position.dy + controller.boxSize.height / 2,
    );
  }

  drawArrowsLeftToRight(OrgNode<E> node, Canvas canvas) {
    List<OrgNode<E>> subNodes = controller.getSubNodes(node);
    if (node.hideNodes == false) {
      if (allLeaf(subNodes)) {
        for (var n in subNodes) {
          final bool horizontal = n.position.dx > node.position.dx;
          final bool vertical = n.position.dy > node.position.dy;
          final bool c = vertical ? horizontal : !horizontal;

          linePath.moveTo(
            node.position.dx + controller.boxSize.width / 2,
            node.position.dy + controller.boxSize.height / 2,
          );
          linePath.lineTo(
            n.position.dx +
                controller.boxSize.width / 2 +
                (horizontal ? -1 : 1) * cornerRadius,
            node.position.dy + controller.boxSize.height / 2,
          );
          linePath.arcToPoint(
            Offset(
              n.position.dx + controller.boxSize.width / 2,
              node.position.dy +
                  controller.boxSize.height / 2 +
                  (vertical ? 1 : -1) * cornerRadius,
            ),
            radius: Radius.circular(cornerRadius),
            clockwise: c,
          );
          linePath.lineTo(
            n.position.dx + controller.boxSize.width / 2,
            n.position.dy + controller.boxSize.height / 2,
          );
        }
      } else {
        for (var n in subNodes) {
          final minx = math.min(node.position.dx, n.position.dx);
          final maxx = math.max(node.position.dx, n.position.dx);
          final miny = math.min(node.position.dy, n.position.dy);
          final maxy = math.max(node.position.dy, n.position.dy);

          final dx = (maxx - minx) / 2 + controller.boxSize.width / 2;

          bool horizontal = maxx == node.position.dx;
          bool vertical = maxy == node.position.dy;

          bool clockwise = horizontal ? !vertical : vertical;

          linePath.moveTo(
            node.position.dx + controller.boxSize.width / 2,
            node.position.dy + controller.boxSize.height / 2,
          );

          linePath.lineTo(
            minx + dx + (horizontal ? 1 : -1) * cornerRadius, //
            node.position.dy + controller.boxSize.height / 2,
          );

          if (maxy - miny > cornerRadius * 2) {
            linePath.arcToPoint(
                Offset(
                  minx + dx,
                  node.position.dy +
                      controller.boxSize.height / 2 +
                      (vertical ? -1 : 1) * cornerRadius,
                ),
                radius: Radius.circular(cornerRadius),
                clockwise: !clockwise);

            linePath.lineTo(
              minx + dx,
              n.position.dy +
                  controller.boxSize.height / 2 +
                  (vertical ? 1 : -1) * cornerRadius,
            );

            linePath.arcToPoint(
                Offset(
                  minx + dx + (!horizontal ? 1 : -1) * cornerRadius,
                  n.position.dy + controller.boxSize.height / 2,
                ),
                radius: Radius.circular(cornerRadius),
                clockwise: clockwise);
          }

          linePath.lineTo(
            n.position.dx + controller.boxSize.width / 2,
            n.position.dy + controller.boxSize.height / 2,
          );

          drawArrowsLeftToRight(n, canvas);
        }
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    linePath.reset();
    for (var node in controller.roots) {
      drawArrows(node, canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawDashedPath(Canvas canvas, Path path, Paint paint, double dashWidth,
      double dashSpace) {
    PathMetrics pathMetrics = path.computeMetrics();

    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      bool drawDash = true;

      while (distance < pathMetric.length) {
        final double segmentLength = drawDash ? dashWidth : dashSpace;
        final double nextDistance = distance + segmentLength;

        if (drawDash) {
          final Path segment = pathMetric.extractPath(
              distance, nextDistance.clamp(0, pathMetric.length));
          canvas.drawPath(segment, paint);
        }

        distance = nextDistance;
        drawDash = !drawDash;
      }
    }
  }

  void drawDashedLine(
      {required Canvas canvas,
      required Offset p1,
      required Offset p2,
      required int dashWidth,
      required int dashSpace,
      required Paint paint}) {
    // Get normalized distance vector from p1 to p2
    var dx = p2.dx - p1.dx;
    var dy = p2.dy - p1.dy;
    final magnitude = math.sqrt(dx * dx + dy * dy);
    dx = dx / magnitude;
    dy = dy / magnitude;

    // Compute number of dash segments
    final steps = magnitude ~/ (dashWidth + dashSpace);

    var startX = p1.dx;
    var startY = p1.dy;

    for (int i = 0; i < steps; i++) {
      final endX = startX + dx * dashWidth;
      final endY = startY + dy * dashWidth;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      startX += dx * (dashWidth + dashSpace);
      startY += dy * (dashWidth + dashSpace);
    }
  }
}
