load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

TOOLCHAIN_LOCATION_X86_GCC = "/opt/gcc/x86-64--glibc--stable-2022.08-1/"

def bazel_configs_deps():
    # toolchains
    maybe(
        http_archive,
        name = "gcc_x86",
        urls = [ "https://toolchains.bootlin.com/downloads/releases/toolchains/x86-64/tarballs/x86-64--glibc--stable-2023.11-1.tar.bz2" ],
        build_file = "@bazel_configs//toolchains:gcc_x86.BUILD",
        strip_prefix = "x86-64--glibc--stable-2023.11-1",
        sha256 = "e3c0ef1618df3a3100a8a167066e7b19fdd25ee2c4285cf2cfe3ef34f0456867"
    )
    maybe(
        native.new_local_repository,
        name = "gcc_x86",
        build_file = "@bazel_configs//toolchains:gcc_x86.BUILD",
        path = TOOLCHAIN_LOCATION_X86_GCC,
    )
