source /dev/stdin <<< "$(curl -s https://raw.githubusercontent.com/pytgcalls/build-toolkit/refs/heads/master/build-toolkit.sh)"

import libraries.properties
import setup-clang.sh

sysroot=""

if is_linux; then
  build_and_install "libcxx" clone
  build_and_install "buildtools" clone

  cp "$DEFAULT_BUILD_FOLDER/buildtools/third_party/libc++/__config_site" "$DEFAULT_BUILD_FOLDER/libcxx/include/"
  cp "$DEFAULT_BUILD_FOLDER/buildtools/third_party/libc++/__assertion_handler" "$DEFAULT_BUILD_FOLDER/libcxx/include/"
elif is_macos; then
  sysroot="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null | tr -d '[:space:]')"
fi

build_and_install "boost" b2-static \
    --update-submodules \
    --linux="target-os=linux \
      cxxflags=\"-D_LIBCPP_ABI_NAMESPACE=Cr -D_LIBCPP_ABI_VERSION=2 -D_LIBCPP_DISABLE_AVAILABILITY -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_EXTENSIVE -nostdinc++ -isystem$DEFAULT_BUILD_FOLDER/libcxx/include\"" \
    --windows="target-os=windows toolset=msvc
      runtime-link=static
      cxxflags=\"-D_ITERATOR_DEBUG_LEVEL=0\"" \
    --macos="cflags=\"--sysroot=$sysroot -target aarch64-apple-darwin -mmacosx-version-min=12.0\" \
      cxxflags=\"--sysroot=$sysroot -std=gnu++17 -target aarch64-apple-darwin -mmacosx-version-min=12.0\" \
      visibility=hidden" \
    --linux-macos="runtime-link=shared toolset=clang --pre-build-commands=\"setup_clang\"" \
    --linux-windows="visibility=global" \
    address-model=64 \
    --ignore-site-config \
    threading=multi \
    --with-atomic \
    --with-context \
    --with-date_time \
    --with-system \
    --with-filesystem \
    --with-process \
    architecture="$(normalize_arch "default" "short")"

copy_libs "boost" "artifacts" "boost_atomic" "boost_context" "boost_date_time" "boost_filesystem" "boost_process" "boost_system"