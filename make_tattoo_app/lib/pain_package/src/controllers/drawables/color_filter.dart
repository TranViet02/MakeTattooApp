import 'package:flutter/material.dart';

ColorFilter createColorFilterFromMatrix(List<double> matrix) {
  assert(matrix.length == 20, "Ma trận màu phải có 20 phần tử.");
  return ColorFilter.matrix(matrix);
}
