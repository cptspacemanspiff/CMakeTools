#include <DemoLib/Hello.h>

int main() {
  DemoLib::HelloBase::create("English")->hello();
  DemoLib::HelloBase::create("Spanish")->hello();
  return 0;
}