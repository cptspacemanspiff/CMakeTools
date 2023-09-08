#include <iostream>

#include "DemoLib/Hello.h"
#include "HelloImpl.h"
// implement the factory object:
namespace DemoLib {

HelloBase *HelloBase::create(const std::string type) {
  if (type == "English") {
    return new EnglishImpl();
  } else if (type == "Spanish") {
    return new SpanishImpl();
  } else {
    return nullptr;
  }
}
} // namespace DemoLib