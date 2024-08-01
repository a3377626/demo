package(default_visibility = ["//visibility:public"])

# export the executable files to make them available for direct use.
exports_files(glob([
    "bin/*gcc*",
    "lib/gcc/**/*",
]))

filegroup(
    name = "all_files",
    srcs = [
        ":ar_files",
        ":compiler_files",
        ":linker_files",
    ] + glob(["**/*"]),
)

filegroup(
    name = "compiler_files",
    srcs = [
        ":gcc",
        ":compiler_pieces"
    ],
)

filegroup(
    name = "linker_files",
    srcs = [
        ":ar",
        ":gcc",
        ":ld",
    ],
)

filegroup(
    name = "objcopy_files",
    srcs = [
        ":objcopy",
    ],
)

filegroup(
    name = "strip_files",
    srcs = [
        ":strip",
    ],
)

filegroup(
    name = "ar_files",
    srcs = [
        ":ar",
    ],
)

# cc executables.
filegroup(
    name = "gcc",
    srcs = glob(["bin/*gcc*", "libexec/gcc/**", "lib/**"]),
)

# ar executables.
filegroup(
    name = "ar",
    srcs = glob(["bin/*ar*"]),
)

# ld executables.
filegroup(
    name = "ld",
    srcs = glob(["bin/*ld*"]),
)

# nm executables.
filegroup(
    name = "nm",
    srcs = glob(["bin/*nm*"]),
)

# objcopy executables.
filegroup(
    name = "objcopy",
    srcs = glob(["bin/*objcopy*"]),
)

# objdump executables.
filegroup(
    name = "objdump",
    srcs = glob(["bin/*objdump*"]),
)

# strip executables.
filegroup(
    name = "strip",
    srcs = glob(["bin/*strip*"]),
)

# as executables.
filegroup(
    name = "as",
    srcs = glob(["bin/*as*"]),
)

# size executables.
filegroup(
    name = "size",
    srcs = glob(["bin/*size*"]),
)

# libraries and headers.
filegroup(
    name = "compiler_pieces",
    srcs = glob([
        "lib/gcc/**/*",
        "x86_64-buildroot-linux-gnu/**",
        "sysroot/**",
    ], exclude = [ "x86_64-buildroot-linux-gnu/sysroot/**", ]),
)

# collection of executables.
filegroup(
    name = "compiler_components",
    srcs = [
        ":ar",
        ":as",
        ":gcc",
        ":ld",
        ":nm",
        ":objcopy",
        ":objdump",
        ":strip",
    ],
)

filegroup(
    name = "empty",
)
