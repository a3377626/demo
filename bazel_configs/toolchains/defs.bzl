load("//platform:defs.bzl", "CPU_NAMES")
load("//toolchains:gcc_x86.bzl", "register_gcc_x86_toolchain")

def register_toolchains():
  register_gcc_x86_toolchain()
  native.cc_toolchain_suite(
      name = "toolchains",
      toolchains = {
          CPU_NAMES.gcc_x86 : "//:cc_toolchain_gcc_x86",
      }
  )
