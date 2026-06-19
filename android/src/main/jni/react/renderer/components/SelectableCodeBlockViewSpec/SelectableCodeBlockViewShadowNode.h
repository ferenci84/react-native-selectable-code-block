#pragma once

#include "SelectableCodeBlockViewMeasurementManager.h"

#include <react/renderer/components/SelectableCodeBlockViewSpec/EventEmitters.h>
#include <react/renderer/components/SelectableCodeBlockViewSpec/Props.h>
#include <react/renderer/components/SelectableCodeBlockViewSpec/States.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>

namespace facebook::react {

extern const char SelectableCodeBlockMeasuredViewComponentName[];

class SelectableCodeBlockViewShadowNode final
    : public ConcreteViewShadowNode<SelectableCodeBlockMeasuredViewComponentName,
                                    SelectableCodeBlockViewProps,
                                    SelectableCodeBlockViewEventEmitter,
                                    SelectableCodeBlockViewState> {
 public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;

  static ShadowNodeTraits BaseTraits()
  {
    auto traits = ConcreteViewShadowNode::BaseTraits();
    traits.set(ShadowNodeTraits::Trait::LeafYogaNode);
    traits.set(ShadowNodeTraits::Trait::MeasurableYogaNode);
    return traits;
  }

  void setMeasurementsManager(
      const std::shared_ptr<SelectableCodeBlockViewMeasurementManager> &measurementsManager);

  Size measureContent(
      const LayoutContext &layoutContext,
      const LayoutConstraints &layoutConstraints) const override;

 private:
  std::shared_ptr<SelectableCodeBlockViewMeasurementManager> measurementsManager_;
};

} // namespace facebook::react