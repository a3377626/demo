workspace(name="demo")

local_repository(
    name = "bazel_configs",
    path = "./bazel_configs"
)

load("@bazel_configs//:defs.bzl", "bazel_configs_deps")
bazel_configs_deps()
