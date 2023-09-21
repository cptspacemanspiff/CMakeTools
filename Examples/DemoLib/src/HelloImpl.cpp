#include <iostream>
#include <memory>

#include "DemoLib/Hello.h"
#include "HelloImpl.h"
// implement the factory object:
namespace DemoLib {

std::shared_ptr<HelloBase> HelloBase::create(const std::string type) {
  if (type == "English") {
    return std::make_shared<EnglishImpl>();
  } else if (type == "Spanish") {
    return std::make_shared<SpanishImpl>();
  } else {
    throw std::runtime_error("Invalid Hello Type");
  }
}

void EnglishImpl::hello() { std::cout << "Hello World!" << std::endl; }

void SpanishImpl::hello() { std::cout << "Hola Mundo!" << std::endl; }

} // namespace DemoLib