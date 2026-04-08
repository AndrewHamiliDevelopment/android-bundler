# Android Bundler Container

This project provides a Docker container for building Android APK and AAB files from any Android project. Just place your project in the `project` folder and run the container to generate builds in the `output` folder.

## Features
- No need to install Android SDK or Java locally
- Builds both APK and AAB files
- Simple usage with Docker Compose


## Usage

1. **Place your Android project:**
   - Copy your entire Android project into the `project` folder in this directory.

2. **Choose build type:**
   - By default, the container builds a debug APK/AAB.
   - To build a release APK/AAB, set the `BUILD_TYPE` environment variable to `release` and provide your JKS signing credentials (see below).

3. **Build and run the container:**
   - For debug build (default):
     ```sh
     docker-compose up --build
     ```
   - For release build (with signing):
     ```sh
     docker-compose run -e BUILD_TYPE=release \
       -e JKS_PATH=/workspace/keystore/my-release-key.jks \
       -e JKS_ALIAS=your_alias \
       -e JKS_PASSWORD=your_store_password \
       -e JKS_KEY_PASSWORD=your_key_password \
       android-bundler
     ```
     - Mount your JKS file into the container (e.g., place it in a `keystore` folder and mount it via Docker Compose or bind mount).

4. **Retrieve your builds:**
   - After the build completes, find your APK and AAB files in the `output` folder.

## Folder Structure
- `project/` — Place your Android project here (not included in repo)
- `output/` — APK and AAB files will be saved here after build
- `Dockerfile` — Container setup
- `docker-compose.yml` — Compose configuration
- `build.sh` — Build script run inside the container


## Build Types & Signing

- **Debug build:**
   - No signing required. Produces debug APK/AAB.
- **Release build:**
   - Requires a Java Keystore (JKS) for signing.
   - Set the following environment variables:
      - `BUILD_TYPE=release`
      - `JKS_PATH` — Path to your JKS file inside the container
      - `JKS_ALIAS` — Alias for your key
      - `JKS_PASSWORD` — Keystore password
      - `JKS_KEY_PASSWORD` — Key password
   - Example: see usage above.

## Notes
- The container expects a Gradle-based Android project with a `gradlew` script.
- The `project` folder is mounted read-only; the `output` folder is writable.
- The container always pulls the latest project contents on each run.


## Troubleshooting
- If you see errors about missing `gradlew`, ensure your project is complete and in the correct folder.
- For release builds, ensure all JKS environment variables are set and the JKS file is accessible inside the container.
- Check the `output` folder for build artifacts and logs.

---

**Author:** Andrew Hamili
