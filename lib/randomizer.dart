 import 'dart:math';

int randomInt({int? max = 5}) {
Random random = Random();
var count = random.nextInt((max ?? 5)) + 1;
return count;
}