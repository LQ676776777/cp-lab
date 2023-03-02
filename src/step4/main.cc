#include <iostream>
#include <string>

#include "helloworld.hh"

int main() {
  auto hello_str = helloworld::say_hello();
  std::cout << hello_str << std::endl;
  return 0;
}