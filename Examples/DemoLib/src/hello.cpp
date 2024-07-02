#include "DemoLib/Hello.h"

int main() {
  auto speaker = DemoLib::HelloBase::create("English");
  speaker->hello();
}