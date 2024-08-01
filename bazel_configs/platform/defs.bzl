CPU_NAMES = struct(
    gcc_x86 = 'k8',
)

CPU_CONFIGS = {
    CPU_NAMES.gcc_x86: struct(
        fast_cpp_compilation_flags = [
            "-std=c++17",
            "-DHAVE_CXX0X",
        ],
        fast_linker_dependencies = [
        ],
        default_cpp_only_compilation_flags = [
            "-std=c++17",
        ],
        default_compilation_flags = [
            "-Wall",
            "-fPIC",
            "-m64",
            "-Wall",
            "-D_LINUX_SOURCE",
            "-DBAZEL_COMPILE",
        ],
        default_linker_flags = [
            "-fuse-ld=gold", # use gold-linker
            "-lpthread",
            "-lstdc++",
            "-ldl",
            "-lrt",
            "-lm",
            "-lrt",
        ],
    ),
}


def register_platforms():
    declare_constraints()
    declare_platforms()
    declare_config_settings()


def declare_constraints():
    pass


def declare_platforms():
    native.platform(
        name = "linux-x86",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ]
    )

    native.platform(
        name = "linux-aarch64",
        constraint_values = [
            "@platforms//os:linux",
            "@platforms//cpu:aarch64",
        ]
    )

def declare_config_settings():
    native.config_setting(
        name = CPU_NAMES.gcc_x86,
        values = {"cpu": CPU_NAMES.gcc_x86},
    )
