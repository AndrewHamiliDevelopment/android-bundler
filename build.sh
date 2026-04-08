#!/bin/bash
set -e


PROJECT_DIR="/workspace/project"
OUTPUT_DIR="/workspace/output"

# Build type: debug or release (default: debug)
BUILD_TYPE=${BUILD_TYPE:-debug}
# JKS signing variables for release
JKS_PATH=${JKS_PATH:-}
JKS_ALIAS=${JKS_ALIAS:-}
JKS_PASSWORD=${JKS_PASSWORD:-}
JKS_KEY_PASSWORD=${JKS_KEY_PASSWORD:-}


if [ ! -d "$PROJECT_DIR" ]; then
  echo "Project directory $PROJECT_DIR does not exist. Please mount your Android project to ./project."
  exit 1
fi


cd "$PROJECT_DIR"


# Clean previous builds
if [ -f ./gradlew ]; then
  ./gradlew clean
  if [ "$BUILD_TYPE" = "release" ]; then
    # Check for JKS variables
    if [ -z "$JKS_PATH" ] || [ -z "$JKS_ALIAS" ] || [ -z "$JKS_PASSWORD" ] || [ -z "$JKS_KEY_PASSWORD" ]; then
      echo "JKS_PATH, JKS_ALIAS, JKS_PASSWORD, and JKS_KEY_PASSWORD must be set for release builds."
      exit 1
    fi
    ./gradlew assembleRelease bundleRelease \
      -Pandroid.injected.signing.store.file="$JKS_PATH" \
      -Pandroid.injected.signing.store.password="$JKS_PASSWORD" \
      -Pandroid.injected.signing.key.alias="$JKS_ALIAS" \
      -Pandroid.injected.signing.key.password="$JKS_KEY_PASSWORD"
    cp -v app/build/outputs/apk/release/*.apk "$OUTPUT_DIR" 2>/dev/null || true
    cp -v app/build/outputs/bundle/release/*.aab "$OUTPUT_DIR" 2>/dev/null || true
  else
    ./gradlew assembleDebug bundleDebug
    cp -v app/build/outputs/apk/debug/*.apk "$OUTPUT_DIR" 2>/dev/null || true
    cp -v app/build/outputs/bundle/debug/*.aab "$OUTPUT_DIR" 2>/dev/null || true
  fi
else
  echo "No gradlew found in project. Please ensure this is a valid Android project."
  exit 1
fi

echo "Build complete. APKs and AABs are in $OUTPUT_DIR."
