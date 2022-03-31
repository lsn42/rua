int main() {
  register int a = 0, b = 1;
  for (; b < 100;) {
    a += b;
    // output a
    b += a;
    // output b
  }
}