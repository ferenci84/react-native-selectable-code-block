#pragma once

#include "SelectableCodeBlockViewMeasurementManager.h"
#include "SelectableCodeBlockViewShadowNode.h"

#include <react/renderer/componentregistry/ComponentDescriptorProviderRegistry.h>
#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {

class SelectableCodeBlockViewComponentDescriptor final
    : public ConcreteComponentDescriptor<SelectableCodeBlockViewShadowNode> {
 public:
  SelectableCodeBlockViewComponentDescriptor(const ComponentDescriptorParameters &parameters)
      : ConcreteComponentDescriptor(parameters),
        measurementsManager_(std::make_shared<SelectableCodeBlockViewMeasurementManager>(contextContainer_))
  {}

  void adopt(ShadowNode &shadowNode) const override
  {
    ConcreteComponentDescriptor::adopt(shadowNode);
    auto &codeBlockShadowNode = static_cast<SelectableCodeBlockViewShadowNode &>(shadowNode);
    codeBlockShadowNode.setMeasurementsManager(measurementsManager_);
  }

 private:
  const std::shared_ptr<SelectableCodeBlockViewMeasurementManager> measurementsManager_;
};

void SelectableCodeBlockViewSpec_registerComponentDescriptorsFromCodegen(
    std::shared_ptr<const ComponentDescriptorProviderRegistry> registry);

} // namespace facebook::react