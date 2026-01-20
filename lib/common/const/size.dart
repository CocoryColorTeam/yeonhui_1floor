import 'package:sizer/sizer.dart';

class CocorySize {
  static double width(double x) {
    return (x / 2160 * 100).w;
  }  static double height(double y) {
    return (y / 3840 * 100).h;
  }
}
