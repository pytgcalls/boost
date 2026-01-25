source /dev/stdin <<< "$(curl -s https://raw.githubusercontent.com/pytgcalls/build-toolkit/refs/heads/master/build-toolkit.sh)"

if is_macos || (is_linux && ! is_arm64) || is_android; then
  require clang-21

  if is_android; then
    require ndk
  fi
fi

import libraries.properties
import setup-clang.sh

sysroot=""

if is_linux || is_macos || is_android; then
  build_and_install "libcxx" clone
  build_and_install "buildtools" clone

  cp "$DEFAULT_BUILD_FOLDER/buildtools/third_party/libc++/__config_site" "$DEFAULT_BUILD_FOLDER/libcxx/include/"
  cp "$DEFAULT_BUILD_FOLDER/buildtools/third_party/libc++/__assertion_handler" "$DEFAULT_BUILD_FOLDER/libcxx/include/"

  if is_macos; then
    sysroot="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null | tr -d '[:space:]')"
  elif is_android; then
    sysroot="$(android_tool sysroot)"
  fi
fi

arch_builds=("default")

if is_android; then
  arch_builds=(
    "x86_64"
    "x86"
    "arm64-v8a"
    "armv7-a"
  )
fi

for arch in "${arch_builds[@]}"; do
  build_and_install "boost" b2-static \
      --update-submodules \
      --linux="target-os=linux cxxflags=\"$(libcxx_flags)\"" \
      --windows="target-os=windows toolset=msvc
        runtime-link=static
        cxxflags=\"-D_ITERATOR_DEBUG_LEVEL=0\"" \
      --macos="cflags=\"--sysroot=$sysroot -target aarch64-apple-darwin -mmacosx-version-min=14.0\" \
        cxxflags=\"--sysroot=$sysroot -std=gnu++17 -target aarch64-apple-darwin -mmacosx-version-min=14.0 $(libcxx_flags)\" \
        visibility=hidden" \
      --linux-macos-android="runtime-link=shared toolset=clang --pre-build-commands=\"setup_clang\"" \
      --linux-windows-android="visibility=global" \
      --android="target-os=android \
        cflags=\"--sysroot=$sysroot -fPIC --target=$(android_tool target "$arch")\" \
        cxxflags=\"--sysroot=$sysroot -fPIC --target=$(android_tool target "$arch") $(libcxx_flags)\"" \
      address-model="$(if [[ "$arch" == "armv7-a" || "$arch" == "x86" ]]; then echo "32"; else echo "64"; fi)" \
      --ignore-site-config \
      threading=multi \
      --linux-windows-macos="
        --with-atomic
        --with-context
        --with-date_time
        --with-system
        --with-filesystem
        --with-process" \
      --with-json \
      architecture="$(normalize_arch "$arch" "short")"
  if ! is_android; then
    copy_libs "boost" "artifacts" "boost_atomic" "boost_context" "boost_date_time" "boost_filesystem" "boost_process" "boost_json"
  fi
  copy_libs "boost" "artifacts" "boost_json" --arch="$arch"
done