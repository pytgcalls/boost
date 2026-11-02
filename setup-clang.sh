function setup_clang() {
    echo "using clang : : $(if ! is_linux; then echo "$CLANG_BIN/"; fi)clang++ : ;" > "$DEFAULT_BUILD_FOLDER/boost/project-config.jam"
}

function libcxx_flags() {
    local flags="-D_LIBCPP_ABI_NAMESPACE=Cr -D_LIBCPP_ABI_VERSION=2 -D_LIBCPP_DISABLE_AVAILABILITY -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_EXTENSIVE -nostdinc++ -isystem$DEFAULT_BUILD_FOLDER/libcxx/include"
    if is_musl; then
        flags="$flags -D_LIBCPP_PROVIDES_DEFAULT_RUNE_TABLE"
    fi
    echo "$flags"
}

function setup_clang_win() {
    echo "using clang-win : : $(cygpath -m "$CLANG_BIN/clang-cl.exe") ;" > "$DEFAULT_BUILD_FOLDER/boost/project-config.jam"
}

function libcxx_flags_win() {
    echo "-D_LIBCPP_ABI_NAMESPACE=Cr -D_LIBCPP_ABI_VERSION=2 -D_LIBCPP_DISABLE_AVAILABILITY -D_LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_EXTENSIVE -I$(cygpath -m "$DEFAULT_BUILD_FOLDER/libcxx/include")"
}
