import 'dart:ui';
import 'package:flame/components.dart';

class HornetSpriteRects {
  static final List<Rect> all = [
    Rect.fromLTWH(7, 12, 29, 34),
    Rect.fromLTWH(175, 14, 31, 32),
    Rect.fromLTWH(235, 15, 29, 31),
    Rect.fromLTWH(297, 15, 24, 31),
    Rect.fromLTWH(118, 17, 31, 30),
    Rect.fromLTWH(63, 18, 31, 29),
  ];

  // ⚠️ У тебя всего 6 кадров, значит максимум можно брать до индекса 6
  static final List<Rect> idle = all.sublist(0, 2); // кадры 0–1
  static final List<Rect> run = all.sublist(2, 4); // кадры 2–3
  static final List<Rect> jump = all.sublist(4, 6); // кадры 4–5

  static List<_FrameData> get idleFrames => _toFrameData(idle);
  static List<_FrameData> get runFrames => _toFrameData(run);
  static List<_FrameData> get jumpFrames => _toFrameData(jump);

  static List<_FrameData> _toFrameData(List<Rect> rects) {
    return rects
        .map(
          (r) => _FrameData(Vector2(r.left, r.top), Vector2(r.width, r.height)),
        )
        .toList();
  }
}

class _FrameData {
  final Vector2 position;
  final Vector2 size;
  _FrameData(this.position, this.size);
}
