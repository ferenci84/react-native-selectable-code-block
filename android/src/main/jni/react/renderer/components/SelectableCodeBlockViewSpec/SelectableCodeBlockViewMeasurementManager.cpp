#include "SelectableCodeBlockViewMeasurementManager.h"

#include <fbjni/fbjni.h>
#include <react/jni/ReadableNativeMap.h>
#include <react/renderer/core/conversions.h>

#include <cstring>

using namespace facebook::jni;

namespace facebook::react {

static Size yogaMeasureToSize(jlong measureOutput)
{
  int32_t widthBits = static_cast<int32_t>(0xFFFFFFFF & (measureOutput >> 32));
  int32_t heightBits = static_cast<int32_t>(0xFFFFFFFF & measureOutput);
  float width;
  float height;
  std::memcpy(&width, &widthBits, sizeof(float));
  std::memcpy(&height, &heightBits, sizeof(float));
  return Size{width, height};
}

Size SelectableCodeBlockViewMeasurementManager::measure(
    SurfaceId surfaceId,
    const SelectableCodeBlockViewProps &props,
    LayoutConstraints layoutConstraints) const
{
  const jni::global_ref<jobject> &fabricUIManager =
      contextContainer_->at<jni::global_ref<jobject>>("FabricUIManager");

  static const auto measure =
      facebook::jni::findClassStatic("com/facebook/react/fabric/FabricUIManager")
          ->getMethod<jlong(
              jint,
              jstring,
              ReadableMap::javaobject,
              ReadableMap::javaobject,
              ReadableMap::javaobject,
              jfloat,
              jfloat,
              jfloat,
              jfloat)>("measure");

  local_ref<JString> componentName = make_jstring("SelectableCodeBlockView");
  folly::dynamic serializedProps = toDynamic(props);
  local_ref<ReadableNativeMap::javaobject> propsRNM = ReadableNativeMap::newObjectCxxArgs(serializedProps);
  local_ref<ReadableMap::javaobject> propsRM =
      make_local(reinterpret_cast<ReadableMap::javaobject>(propsRNM.get()));

  auto minimumSize = layoutConstraints.minimumSize;
  auto maximumSize = layoutConstraints.maximumSize;

  return yogaMeasureToSize(measure(
      fabricUIManager,
      surfaceId,
      componentName.get(),
      nullptr,
      propsRM.get(),
      nullptr,
      minimumSize.width,
      maximumSize.width,
      minimumSize.height,
      maximumSize.height));
}

} // namespace facebook::react