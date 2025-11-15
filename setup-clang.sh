function setup_clang() {
    echo "using clang : : $(if ! is_arm64; then echo "$CLANG_BIN/"; fi)clang++ : ;" > "$DEFAULT_BUILD_FOLDER/boost/project-config.jam"
}

function libcxx_flags() {
    echo "-D_LIBCPP_ABI_NAMESPACE=Cr -D_LIBCPP_ABI_VERSION=2 -D_LIBCPP_DISABLE_AVAILABILITY -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_EXTENSIVE -nostdinc++ -isystem$DEFAULT_BUILD_FOLDER/libcxx/include"
}