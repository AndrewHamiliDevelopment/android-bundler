#!/bin/bash
set -e


PROJECT_DIR="/workspace/project"
OUTPUT_DIR="/workspace/output"

# Build type: debug or release (default: debug)
BUILD_TYPE=${BUILD_TYPE:-debug}
# Whether to run ./gradlew clean before assemble/bundle (default: false)
RUN_GRADLE_CLEAN=${RUN_GRADLE_CLEAN:-false}
# Whether to clear Gradle transform caches before build (default: false)
RESET_GRADLE_TRANSFORMS_CACHE=${RESET_GRADLE_TRANSFORMS_CACHE:-false}
# Whether to exclude known problematic native clean tasks during assemble/bundle (default: true)
EXCLUDE_NATIVE_CLEAN_TASKS=${EXCLUDE_NATIVE_CLEAN_TASKS:-true}
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

if [ "$RESET_GRADLE_TRANSFORMS_CACHE" = "true" ]; then
  echo "RESET_GRADLE_TRANSFORMS_CACHE=true, deleting Gradle transforms cache..."
  rm -rf /root/.gradle/caches/transforms-* 2>/dev/null || true
fi

# Detect if this is an Expo project
IS_EXPO=false
if [ -f "app.json" ] || [ -f "app.config.js" ] || [ -f "app.config.ts" ]; then
  if grep -q '"expo"' app.json 2>/dev/null || [ -f "app.config.js" ] || [ -f "app.config.ts" ]; then
    IS_EXPO=true
  fi
fi

if [ "$IS_EXPO" = "true" ]; then
  echo "Expo project detected. Running npm install..."
  npm install --verbose
  npx expo prebuild --clean
  npx expo prebuild --platform android
  echo "npm install complete. Switching to android directory for Gradle build..."
  cd android
fi

GRADLE_EXTRA_ARGS=""
if [ "$EXCLUDE_NATIVE_CLEAN_TASKS" = "true" ]; then
  # Some RN/Expo native modules register clean tasks that fail when transformed prefab cache entries are stale.
  GRADLE_EXTRA_ARGS="-x clean -x externalNativeBuildCleanDebug -x externalNativeBuildCleanRelease -x cleanCmakeCache"
  echo "Excluding native clean tasks: $GRADLE_EXTRA_ARGS"
fi

# Clean previous builds
if [ -f ./gradlew ]; then
  if [ "$RUN_GRADLE_CLEAN" = "true" ]; then
    ./gradlew clean
  else
    echo "Skipping ./gradlew clean (set RUN_GRADLE_CLEAN=true to enable)."
  fi
  if [ "$BUILD_TYPE" = "release" ]; then
    # Check for JKS variables
    if [ -z "$JKS_PATH" ] || [ -z "$JKS_ALIAS" ] || [ -z "$JKS_PASSWORD" ] || [ -z "$JKS_KEY_PASSWORD" ]; then
      echo "JKS_PATH, JKS_ALIAS, JKS_PASSWORD, and JKS_KEY_PASSWORD must be set for release builds."
      exit 1
    fi
    ./gradlew assembleRelease bundleRelease $GRADLE_EXTRA_ARGS \
      -Pandroid.injected.signing.store.file="$JKS_PATH" \
      -Pandroid.injected.signing.store.password="$JKS_PASSWORD" \
      -Pandroid.injected.signing.key.alias="$JKS_ALIAS" \
      -Pandroid.injected.signing.key.password="$JKS_KEY_PASSWORD"
    cp -v app/build/outputs/apk/release/*.apk "$OUTPUT_DIR" 2>/dev/null || true
    cp -v app/build/outputs/bundle/release/*.aab "$OUTPUT_DIR" 2>/dev/null || true
  else
    ./gradlew assembleDebug bundleDebug $GRADLE_EXTRA_ARGS
    cp -v app/build/outputs/apk/debug/*.apk "$OUTPUT_DIR" 2>/dev/null || true
    cp -v app/build/outputs/bundle/debug/*.aab "$OUTPUT_DIR" 2>/dev/null || true
  fi
else
  echo "No gradlew found in project. Please ensure this is a valid Android project."
  exit 1
fi

echo "Build complete. APKs and AABs are in $OUTPUT_DIR."
