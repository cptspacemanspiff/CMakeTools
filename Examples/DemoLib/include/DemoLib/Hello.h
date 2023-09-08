// sample public header for a library.

#ifndef HELLO_H
#define HELLO_H

#include "DemoLib/LIB_export.h"
#include <memory>

namespace DemoLib {
/**
 * @brief Example class.
 *
 */
class DemoLibLIB_EXPORT HelloBase {
public:
  static HelloBase *create(const std::string type);

  virtual ~HelloBase() = 0;
  virtual void hello() = 0;
};
}


#endif // HELLO_H