#pragma once

#include <react/renderer/components/SelectableCodeBlockViewSpec/Props.h>
#include <react/renderer/core/LayoutConstraints.h>
#include <react/utils/ContextContainer.h>

namespace facebook::react {

class SelectableCodeBlockViewMeasurementManager {
 public:
  explicit SelectableCodeBlockViewMeasurementManager(
      const std::shared_ptr<const ContextContainer> &contextContainer)
      : contextContainer_(contextContainer)
  {}

  Size measure(
      SurfaceId surfaceId,
      const SelectableCodeBlockViewProps &props,
      LayoutConstraints layoutConstraints) const;

 private:
  const std::shared_ptr<const ContextContainer> contextContainer_;
};

} // namespace facebook::react