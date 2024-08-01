load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "env_set",
    "feature",
    "tool_path",
)
load("@bazel_configs//platform:defs.bzl", "CPU_CONFIGS", "CPU_NAMES")
load("@bazel_configs//toolchains:cc_toolchain_generator.bzl", "all_compile_actions", "all_link_actions", "genreate_cc_toolchain")

def wrap_path(prefix, name, path):
    target_path = "{}/{}".format(prefix, path)
    return tool_path(name = name, path = target_path)

def _impl_gcc_x86_toolchain(ctx):
    prefix = ctx.attr.toolchain_reference.label.workspace_root
    tool_paths = [
        wrap_path(prefix, name = "gcc", path = "bin/x86_64-buildroot-linux-gnu-gcc"),
        wrap_path(prefix, name = "g++", path = "bin/x86_64-buildroot-linux-gnu-g++"),
        wrap_path(prefix, name = "ld", path = "bin/x86_64-buildroot-linux-gnu-ld"),
        wrap_path(prefix, name = "compat-ld", path = "bin/x86_64-buildroot-linux-gnu-ld"),
        wrap_path(prefix, name = "ar", path = "bin/x86_64-buildroot-linux-gnu-ar"),
        wrap_path(prefix, name = "cpp", path = "bin/x86_64-buildroot-linux-gnu-cpp"),
        wrap_path(prefix, name = "dwp", path = "bin/x86_64-buildroot-linux-gnu-dwp"),
        wrap_path(prefix, name = "gcov", path = "bin/x86_64-buildroot-linux-gnu-gcov"),
        wrap_path(prefix, name = "nm", path = "bin/x86_64-buildroot-linux-gnu-nm"),
        wrap_path(prefix, name = "objdump", path = "bin/x86_64-buildroot-linux-gnu-objdump"),
        wrap_path(prefix, name = "objcopy", path = "bin/x86_64-buildroot-linux-gnu-objcopy"),
        wrap_path(prefix, name = "strip", path = "bin/x86_64-buildroot-linux-gnu-strip"),
    ]

    gcc_x86_compiles_flags = CPU_CONFIGS[CPU_NAMES.gcc_x86].default_compilation_flags
    gcc_x86_cpponly_compiles_flags = CPU_CONFIGS[CPU_NAMES.gcc_x86].default_cpp_only_compilation_flags

    gcc_x86_link_flags = CPU_CONFIGS[CPU_NAMES.gcc_x86].default_linker_flags

    cxx_builtin_include_directories = [
        prefix + "/include",
        prefix + "/lib/gcc/",
        prefix + "/x86_64-buildroot-linux-gnu/include",
        prefix + "/x86_64-buildroot-linux-gnu/sysroot/usr/include/",
    ]

    sysroot = prefix + "/x86_64-buildroot-linux-gnu/sysroot"
    print('cxx_builtin_include_directories: {}'.format(cxx_builtin_include_directories))

    env_feature = feature(
        name = "gcc_x86_env",
        enabled = True,
        env_sets = [
            env_set(
                actions = all_compile_actions + all_link_actions,
            ),
        ],
    )

    return genreate_cc_toolchain(
        ctx = ctx,
        env_feature = env_feature,
        users_cpp_only_compilation_flags = gcc_x86_cpponly_compiles_flags,
        users_compiles_flags = gcc_x86_compiles_flags,
        link_flags = gcc_x86_link_flags,
        toolchain_identifier = "gcc_x86_toolchain_config",
        target_cpu = CPU_NAMES.gcc_x86,
        host_system_name = "linux",
        target_system_name = "linux",
        compiler = "gcc",
        target_libc = "unknown",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        cc_target_os = "linux",
        tool_paths = tool_paths,
        cxx_builtin_include_directories = cxx_builtin_include_directories,
        builtin_sysroot = sysroot,
    )

cc_gcc_x86_toolchain_config = rule(
    attrs = {
        "cpu": attr.string(
            mandatory = True,
            values = [
                CPU_NAMES.gcc_x86,
            ],
        ),
        "toolchain_reference" : attr.label(mandatory=True, allow_files=True),
    },
    provides = [CcToolchainConfigInfo],
    implementation = _impl_gcc_x86_toolchain,
)

def register_gcc_x86_toolchain():
    cc_gcc_x86_toolchain_config(
        name = "gcc_x86_toolchain_config",
        cpu = CPU_NAMES.gcc_x86,
        toolchain_reference = "@gcc_x86//:empty",
    )

    native.cc_toolchain(
      name = "cc_toolchain_gcc_x86",
      all_files = "@gcc_x86//:all_files",
      ar_files = "@gcc_x86//:ar_files",
      compiler_files = "@gcc_x86//:compiler_files",
      dwp_files = "@gcc_x86//:empty",
      linker_files = "@gcc_x86//:linker_files",
      objcopy_files = "@gcc_x86//:objcopy_files",
      strip_files = "@gcc_x86//:strip_files",
      toolchain_config = ":gcc_x86_toolchain_config",
      toolchain_identifier = "gcc_x86_toolchain_config",
    )

    native.toolchain(
      name  ="gcc_x86_toolchain",
      target_compatible_with = [
          "@bazel_configs//:linux-x86",
      ],
      exec_compatible_with = [
          "@bazel_configs//:linux-x86"
      ],
      toolchain = ":cc_toolchain_gcc_x86",
      toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )
