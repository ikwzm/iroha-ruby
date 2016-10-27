#include <stdio.h>
#include <stdint.h>

void test(char* tag, int i, int op, float a, float b, float z)
{
  uint32_t *a_ptr  = (uint32_t*)&a;
  uint32_t *b_ptr  = (uint32_t*)&b;
  uint32_t *z_ptr  = (uint32_t*)&z;
  uint32_t  z_out;
  char*    op_str  = (op) ? "-" : "+";

  // printf("---\n");
  if       ((((*a_ptr & 0x7F800000) == 0x00000000) && ((*a_ptr & 0x007FFFFF) != 0x00000000)) ||
            (((*b_ptr & 0x7F800000) == 0x00000000) && ((*b_ptr & 0x007FFFFF) != 0x00000000)))
  {
      printf("- I  : [{SAY: \"%s.%d : 0x%08X %s 0x%08X => ---- (xxxx %s xxxx => ----)\"}]\n", tag, i, *a_ptr, op_str, *b_ptr, op_str);
      printf("- I  : [{XFER: {DATA: [0x%08X, 0x%08X]}}]\n", *a_ptr, *b_ptr);
      printf("- O  : [{XFER: {DATA: [0x--------]}}]\n");
  } else {
      if        (((*z_ptr & 0x7F800000) == 0x00000000)) {
          z_out = (*z_ptr & 0x80000000);
      } else if (((*z_ptr & 0x7F800000) == 0x7F800000) && ((*z_ptr & 0x007FFFFF) == 0x00000000)) {
          z_out = (*z_ptr & 0x80000000) | 0x7F800000;
      } else if (((*z_ptr & 0x7F800000) == 0x7F800000) && ((*z_ptr & 0x007FFFFF) != 0x00000000)) {
          z_out = 0x7FA00000;
      } else {
          z_out = *z_ptr;
      }
      printf("- I  : [{SAY: \"%s.%d : 0x%08X %s 0x%08X => 0x%08X (%g %s %g => %g)\"}]\n", tag, i, *a_ptr, op_str, *b_ptr, z_out, a, op_str, b, z);
      printf("- I  : [{XFER: {DATA: [0x%08X, 0x%08X]}}]\n", *a_ptr, *b_ptr);
      printf("- O  : [{XFER: {DATA: [0x%08X]}}]\n", z_out);
  }
}

int main(argc, argv)
{
  int      i;
  float    a,b,z;
  int      max_snr = 10000;
  uint32_t *a_ptr  = (uint32_t*)&a;
  uint32_t *b_ptr  = (uint32_t*)&b;
  int      op      = 0;
  char*    tag;

  tag = "Test 1";
  printf("---\n");
  printf("- MARCHAL  : \n");
  printf("  - SAY    : Fadd %s Start.\n", tag);
  printf("- I : [{OUT: {GPO(0): %d}}]\n", op);
  
  i = 1;
  a = 0;b = 0;z = 0;
  test(tag, i, op, a, b, z);
  i++;
  a = 1.0;b = 1.0;z = 2.0;
  test(tag, i, op, a, b, z);
  i++;
  while (i <= max_snr) {
    *a_ptr = (((uint32_t)rand() << 16) & 0xFFFF0000) | ((uint32_t)rand() & 0x0000FFFF);
    *b_ptr = (((uint32_t)rand() << 16) & 0xFFFF0000) | ((uint32_t)rand() & 0x0000FFFF);
    z = a+b;
    test(tag, i, op, a, b, z);
    i++;
  }
  printf("---\n");
  printf("- MARCHAL  : \n");
  printf("  - SAY    : Fadd %s Done.\n", tag);

  tag = "Test 2";
  op  = 1;
  printf("---\n");
  printf("- MARCHAL  : \n");
  printf("  - SAY    : Fadd %s Start.\n", tag);
  printf("- I : [{OUT: {GPO(0): %d}}]\n", op);
  
  i = 1;
  a = 0;b = 0;z = 0;
  test(tag, i, op, a, b, z);
  i++;
  a = 1.0;b = 1.0;z = 0.0;
  test(tag, i, op, a, b, z);
  i++;
  while (i <= max_snr) {
    *a_ptr = (((uint32_t)rand() << 16) & 0xFFFF0000) | ((uint32_t)rand() & 0x0000FFFF);
    *b_ptr = (((uint32_t)rand() << 16) & 0xFFFF0000) | ((uint32_t)rand() & 0x0000FFFF);
    z = a-b;
    test(tag, i, op, a, b, z);
    i++;
  }
  printf("---\n");
  printf("- MARCHAL  : \n");
  printf("  - SAY    : Fadd %s Done.\n", tag);
  printf("---\n");
}
