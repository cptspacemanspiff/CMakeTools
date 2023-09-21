// sample public header for a library.

#ifndef HELLO_H
#define HELLO_H

#include <DemoLib/Hello_export.h>
#include <memory>
#include <string>

namespace DemoLib {
/**
 * @brief Example class that greets the world.
 *
 * Provides a public api to a abstract base class that simply prints 'hello
 * world' in a given language. The language is determined by the type passed to
 * the static factory method on the base class.
   @startuml
      actor Alice
      actor Bob
      component World
      Alice -r-> World: Hello!
      Bob -r-> World: Hola!
      Bob -[hidden]u-> Alice: Hi!
   @enduml
 */
class DemoLibHello_EXPORT HelloBase {
public:
  /**
   * @brief Factory function to create a localized instance of the hello class.
   *
   *
   * @param type The language to use.
   * @return std::shared_ptr<HelloBase> Instance of the hello class.
   */
  static std::shared_ptr<HelloBase> create(const std::string type);

  // Pure virtual base class //
  virtual ~HelloBase() = default;

  /**
   * @brief say hello 👋.
   *
   */
  virtual void hello() = 0;

protected:
  /**
   * @brief Protected constructor to prevent creation of the base class in
   * isolation.
   *
   */
  HelloBase() = default;
};
} // namespace DemoLib

#endif // HELLO_H