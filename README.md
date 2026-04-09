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
    - To build a release APK/AAB, set `BUILD_TYPE=release` in a `.env` file and provide your JKS signing credentials (see below).

3. **Build and run the container:**
    - Create a `.env` file in this directory (same level as `docker-compose.yml`). Docker Compose loads it automatically.
    - Example `.env` for debug build (default):
       ```env
       BUILD_TYPE=debug
       ```
    - Run in the background:
     ```sh
          docker compose up -d --build
     ```
    - Example `.env` for release build (with signing):
       ```env
       BUILD_TYPE=release
       JKS_PATH=/workspace/project/keystore/my-release-key.jks
       JKS_ALIAS=your_alias
       JKS_PASSWORD=your_store_password
       JKS_KEY_PASSWORD=your_key_password
     ```
      - Then run in the background:
       ```sh
             docker compose up -d --build
       ```
    - Make sure your JKS file is accessible inside the container. A simple option is to place it under `project/keystore/` so it is available at `/workspace/project/keystore/...`.

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
   - Set the following variables in `.env`:
      - `BUILD_TYPE=release`
      - `JKS_PATH` — Path to your JKS file inside the container
      - `JKS_ALIAS` — Alias for your key
      - `JKS_PASSWORD` — Keystore password
      - `JKS_KEY_PASSWORD` — Key password
   - Example: see `.env` example in usage above.

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
