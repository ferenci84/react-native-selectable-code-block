#pragma once

#include "SelectableCodeBlockViewShadowNode.h"

#include <react/debug/react_native_assert.h>
#include <react/renderer/componentregistry/ComponentDescriptorProviderRegistry.h>
#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {

class SelectableCodeBlockViewComponentDescriptor final
    : public ConcreteComponentDescriptor<SelectableCodeBlockViewShadowNode> {
 public:
  using ConcreteComponentDescriptor::ConcreteComponentDescriptor;

  void adopt(ShadowNode &shadowNode) const override
  {
    react_native_assert(dynamic_cast<SelectableCodeBlockViewShadowNode *>(&shadowNode));
    ConcreteComponentDescriptor::adopt(shadowNode);
  }
};

void SelectableCodeBlockViewSpec_registerComponentDescriptorsFromCodegen(
    std::shared_ptr<const ComponentDescriptorProviderRegistry> registry);

} // namespace facebook::react