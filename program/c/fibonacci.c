int main() {
  int a = 0, b = 1, i = 100;
  for (; b < i; ++b) {
    a += b;
    // output a
    b += a;
    // output b
  }
}