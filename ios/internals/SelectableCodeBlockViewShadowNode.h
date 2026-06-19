#pragma once

#include <react/renderer/components/SelectableCodeBlockViewSpec/EventEmitters.h>
#include <react/renderer/components/SelectableCodeBlockViewSpec/Props.h>
#include <react/renderer/components/SelectableCodeBlockViewSpec/States.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>
#include <react/renderer/core/LayoutConstraints.h>

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

  Size measureContent(
      const LayoutContext &layoutContext,
      const LayoutConstraints &layoutConstraints) const override;
};

} // namespace facebook::react