#include "SelectableCodeBlockViewShadowNode.h"

#include <react/renderer/core/LayoutContext.h>

namespace facebook::react {

const char SelectableCodeBlockMeasuredViewComponentName[] = "SelectableCodeBlockView";

void SelectableCodeBlockViewShadowNode::setMeasurementsManager(
    const std::shared_ptr<SelectableCodeBlockViewMeasurementManager> &measurementsManager)
{
  ensureUnsealed();
  measurementsManager_ = measurementsManager;
}

Size SelectableCodeBlockViewShadowNode::measureContent(
    const LayoutContext & /*layoutContext*/,
    const LayoutConstraints &layoutConstraints) const
{
  return measurementsManager_->measure(getSurfaceId(), getConcreteProps(), layoutConstraints);
}

} // namespace facebook::react