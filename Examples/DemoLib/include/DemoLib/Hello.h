// sample public header for a library.

#ifndef HELLO_H
#define HELLO_H

#include "DemoLib/LIB_export.h"
#include <memory>
#include <string>

namespace DemoLib {
/**
 * @brief Example class.
 *
 */
class DemoLibLIB_EXPORT HelloBase {
public:
  /**
   * @brief Factory function to create a localized instance of the hello class
   *
   * @param type the language to use
   * @return HelloBase* instance of the hello class
   */
  static std::shared_ptr<HelloBase> create(const std::string type);

  // Pure virtual base class //
  virtual ~HelloBase() = default;

  /**
   * @brief say hello
   *
   */
  virtual void hello() = 0;
};
} // namespace DemoLib

#endif // HELLO_H