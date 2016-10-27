#include <stdio.h>
#include <stdint.h>

void test_1(int i, uint32_t dividend, uint32_t divisor, uint32_t quotient, uint32_t remainder)
{
  printf("---\n");
  printf("- I  : [{SAY: \"Test 1.%d : 0x%08X / 0x%08X => 0x%08X, 0x%08X (%d / %d => %d, %d %% %d => %d)\"}]\n", i, dividend, divisor, quotient, remainder, dividend, divisor, quotient, dividend, divisor, remainder);
  printf("- I  : [{XFER: {DATA: [0x%08X, 0x%08X]}}]\n", dividend, divisor  );
  printf("- O  : [{XFER: {DATA: [0x%08X, 0x%08X]}}]\n", quotient, remainder);
}

void test_2(int i, uint32_t dividend, uint32_t divisor, uint32_t quotient, uint32_t remainder)
{
  printf("- I  : [{SAY: \"Test 2.%d : 0x%08X / 0x%08X => 0x%08X, 0x%08X (%d / %d => %d, %d %% %d => %d)\"}]\n", i, dividend, divisor, quotient, remainder, dividend, divisor, quotient, dividend, divisor, remainder);
  printf("- I  : [{XFER: {DATA: [0x%08X, 0x%08X]}}]\n", dividend, divisor  );
  printf("- O  : [{XFER: {DATA: [0x%08X, 0x%08X]}}]\n", quotient, remainder);
}

int main(argc, argv)
{
  int      i;
  uint32_t dividend;
  uint32_t divisor;
  uint32_t quotient;
  uint32_t remainder;
  int      max_snr = 1000;

  printf("---\n");
  printf("- MARCHAL  : \n");
  printf("  - SAY    : Div TEST 1 Start.\n");
  
  i = 1;
  dividend  = 1;
  divisor   = 1;
  quotient  = 1;
  remainder = 0;
  test_1(i, dividend, divisor, quotient, remainder);
  i++;
  while (i <= max_snr) {
    dividend  = (((uint32_t)rand() << 16) & 0x7FFF0000) | ((uint32_t)rand() & 0x0000FFFF);
    divisor   = (((uint32_t)rand()   + 1) & 0x0000FFFF);
    quotient  = dividend / divisor;
    remainder = dividend % divisor;
    test_1(i, dividend, divisor, quotient, remainder);
    i++;
  }
  printf("---\n");
  printf("- MARCHAL  : \n");
  printf("  - SAY    : Div TEST 1 Done.\n");

  printf("---\n");
  printf("- MARCHAL  : \n");
  printf("  - SAY    : Div TEST 2 Start.\n");
  i = 1;
  while (i <= max_snr) {
    dividend  = (((uint32_t)rand() << 16) & 0x7FFF0000) | ((uint32_t)rand() & 0x0000FFFF);
    divisor   = (((uint32_t)rand()   + 1) & 0x0000FFFF);
    quotient  = dividend / divisor;
    remainder = dividend % divisor;
    test_2(i, dividend, divisor, quotient, remainder);
    i++;
  }
  printf("---\n");
  printf("- MARCHAL  : \n");
  printf("  - SAY    : Div TEST 2 Done.\n");
  printf("---\n");
}
