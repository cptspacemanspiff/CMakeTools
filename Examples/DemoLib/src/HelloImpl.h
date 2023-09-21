#ifndef HELLOIMPL_H
#define HELLOIMPL_H

#include "DemoLib/Hello.h"
namespace DemoLib {
/**
 * @brief Implementation of the public hello interface.
 *
 */
class EnglishImpl : public HelloBase {
public:
  void hello() override;
};

/**
 * @brief Implementation of the public hello interface.
 *
 */
class SpanishImpl : public HelloBase {
public:
  void hello() override;
};
} // namespace DemoLib
#endif // HELLOIMPL_H