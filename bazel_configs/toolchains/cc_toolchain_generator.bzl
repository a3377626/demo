load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "artifact_name_pattern",
    "env_entry",
    "env_set",
    "feature",
    "feature_set",
    "flag_group",
    "flag_set",
    "make_variable",
    "tool",
    "tool_path",
    "variable_with_value",
    "with_feature_set",
)

load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    _ASSEMBLE_ACTION_NAME = "ASSEMBLE_ACTION_NAME",
    _CLIF_MATCH_ACTION_NAME = "CLIF_MATCH_ACTION_NAME",
    _CPP_COMPILE_ACTION_NAME = "CPP_COMPILE_ACTION_NAME",
    _CPP_HEADER_PARSING_ACTION_NAME = "CPP_HEADER_PARSING_ACTION_NAME",
    _CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME = "CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME",
    _CPP_LINK_EXECUTABLE_ACTION_NAME = "CPP_LINK_EXECUTABLE_ACTION_NAME",
    _CPP_LINK_NODEPS_DYNAMIC_LIBRARY_ACTION_NAME = "CPP_LINK_NODEPS_DYNAMIC_LIBRARY_ACTION_NAME",
    _CPP_LINK_STATIC_LIBRARY_ACTION_NAME = "CPP_LINK_STATIC_LIBRARY_ACTION_NAME",
    _CPP_MODULE_CODEGEN_ACTION_NAME = "CPP_MODULE_CODEGEN_ACTION_NAME",
    _CPP_MODULE_COMPILE_ACTION_NAME = "CPP_MODULE_COMPILE_ACTION_NAME",
    _C_COMPILE_ACTION_NAME = "C_COMPILE_ACTION_NAME",
    _LINKSTAMP_COMPILE_ACTION_NAME = "LINKSTAMP_COMPILE_ACTION_NAME",
    _LTO_BACKEND_ACTION_NAME = "LTO_BACKEND_ACTION_NAME",
    _LTO_INDEXING_ACTION_NAME = "LTO_INDEXING_ACTION_NAME",
    _PREPROCESS_ASSEMBLE_ACTION_NAME = "PREPROCESS_ASSEMBLE_ACTION_NAME",
    _STRIP_ACTION_NAME = "STRIP_ACTION_NAME",
)

all_compile_actions = [
    _C_COMPILE_ACTION_NAME,
    _CPP_COMPILE_ACTION_NAME,
    _LINKSTAMP_COMPILE_ACTION_NAME,
    _ASSEMBLE_ACTION_NAME,
    _PREPROCESS_ASSEMBLE_ACTION_NAME,
    _CPP_HEADER_PARSING_ACTION_NAME,
    _CPP_MODULE_COMPILE_ACTION_NAME,
    _CPP_MODULE_CODEGEN_ACTION_NAME,
    _CLIF_MATCH_ACTION_NAME,
    _LTO_BACKEND_ACTION_NAME,
]

all_cpp_compile_actions = [
    _CPP_COMPILE_ACTION_NAME,
    _LINKSTAMP_COMPILE_ACTION_NAME,
    _CPP_HEADER_PARSING_ACTION_NAME,
    _CPP_MODULE_COMPILE_ACTION_NAME,
    _CPP_MODULE_CODEGEN_ACTION_NAME,
    _CLIF_MATCH_ACTION_NAME,
]

preprocessor_compile_actions = [
    _C_COMPILE_ACTION_NAME,
    _CPP_COMPILE_ACTION_NAME,
    _LINKSTAMP_COMPILE_ACTION_NAME,
    _PREPROCESS_ASSEMBLE_ACTION_NAME,
    _CPP_HEADER_PARSING_ACTION_NAME,
    _CPP_MODULE_COMPILE_ACTION_NAME,
    _CLIF_MATCH_ACTION_NAME,
]

codegen_compile_actions = [
    _C_COMPILE_ACTION_NAME,
    _CPP_COMPILE_ACTION_NAME,
    _LINKSTAMP_COMPILE_ACTION_NAME,
    _ASSEMBLE_ACTION_NAME,
    _PREPROCESS_ASSEMBLE_ACTION_NAME,
    _CPP_MODULE_CODEGEN_ACTION_NAME,
    _LTO_BACKEND_ACTION_NAME,
]

all_link_actions = [
    _CPP_LINK_EXECUTABLE_ACTION_NAME,
    _CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME,
    _CPP_LINK_NODEPS_DYNAMIC_LIBRARY_ACTION_NAME,
]

binary_link_actions = [
    _CPP_LINK_EXECUTABLE_ACTION_NAME,
]

def genreate_cc_toolchain(
        ctx,
        env_feature,
        users_cpp_only_compilation_flags,
        users_compiles_flags,
        link_flags,
        toolchain_identifier,
        target_cpu,
        host_system_name,
        target_system_name,
        compiler,
        target_libc,
        abi_version,
        abi_libc_version,
        cc_target_os,
        tool_paths,
        cxx_builtin_include_directories,
        builtin_sysroot = None):
    #
    # Generate the cc toolchain given parameters
    #
    objcopy_embed_data_action = action_config(
        action_name = "objcopy_embed_data",
        enabled = True,
        tools = [tool(path = "/usr/bin/objcopy")],
    )

    compile_action = action_config(
        action_name = _C_COMPILE_ACTION_NAME,
        enabled = True,
        tools = [ tool(path = tool_paths[0].path) ],
    )
    cpp_compile_action = action_config(
        action_name = _CPP_COMPILE_ACTION_NAME,
        enabled = True,
        tools = [ tool(path = tool_paths[1].path) ],
    )
    action_configs = [
        objcopy_embed_data_action,
        compile_action,
        cpp_compile_action,
    ]

    random_seed_feature = feature(name = "random_seed", enabled = True)

    compiler_output_flags_feature = feature(
        name = "compiler_output_flags",
        flag_sets = [
            flag_set(
                actions = [_ASSEMBLE_ACTION_NAME],
                flag_groups = [
                    flag_group(
                        flags = ["/Fo%{output_file}", "/Zi"],
                        expand_if_available = "output_file",
                        expand_if_not_available = "output_assembly_file",
                    ),
                ],
            ),
            flag_set(
                actions = [
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["/Fo%{output_file}"],
                        expand_if_available = "output_file",
                        expand_if_not_available = "output_assembly_file",
                    ),
                    flag_group(
                        flags = ["/Fa%{output_file}"],
                        expand_if_available = "output_file",
                    ),
                    flag_group(
                        flags = ["/P", "/Fi%{output_file}"],
                        expand_if_available = "output_file",
                    ),
                ],
            ),
        ],
    )

    default_link_flags_feature = feature(
        name = "default_link_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Wl,-z,relro,-z,now",
                            "-lpthread",
                            "-lrt",
                            "-ldl",
                        ] + link_flags,
                    ),
                ],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = ["-Wl,--gc-sections"])],
                with_features = [with_feature_set(features = ["opt"])],
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = [flag_group(flags = [ ""])],
                with_features = [with_feature_set(features = ["coverage"])],
            ),
            flag_set(
                actions = binary_link_actions,
                flag_groups = [flag_group(flags = ["-no-pie", "-pg"])],
                with_features = [with_feature_set(features = ["dbg"])],
            ),
        ],
    )

    supports_pic_feature = feature(name = "supports_pic", enabled = True)

    compile_flags_with_werror_feature = feature(
        name = "compile_flags_with_werror",
        enabled = False,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = ["-Werror"],
                    ),
                ],
            ),
        ],
    )

    compile_flags_no_canonical_feature = feature(
        name = "compile_flags_no_canonical_feature",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-no-canonical-prefixes",
                            "-fno-canonical-system-headers",
                        ],
                    ),
                ],
            ),
        ],
    )

    default_compile_flags_feature = feature(
        name = "default_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    _ASSEMBLE_ACTION_NAME,
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _LINKSTAMP_COMPILE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                    _LTO_BACKEND_ACTION_NAME,
                    _CLIF_MATCH_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-fPIC",
                            "-U_FORTIFY_SOURCE",
                            "-D_FORTIFY_SOURCE=1",
                            "-Wall",
                            "-Wextra",
                            "-fno-omit-frame-pointer",
                            "-Wno-builtin-macro-redefined",
                            "-D__DATE__=\"redacted\"",
                            "-D__TIMESTAMP__=\"redacted\"",
                            "-D__TIME__=\"redacted\"",
                            "-fdiagnostics-color=always",
                        ] + users_compiles_flags,
                    ),
                ],
            ),
            flag_set(
                actions = [
                    _ASSEMBLE_ACTION_NAME,
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _LINKSTAMP_COMPILE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                    _LTO_BACKEND_ACTION_NAME,
                    _CLIF_MATCH_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-g",
                            # "-pg",
                            "-O2",
                            "-fno-omit-frame-pointer",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["dbg"])],
            ),
            flag_set(
                actions = [
                    _ASSEMBLE_ACTION_NAME,
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _LINKSTAMP_COMPILE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                    _LTO_BACKEND_ACTION_NAME,
                    _CLIF_MATCH_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-g",
                            "-O2",
                            "-DNDEBUG",
                            "-ffunction-sections",
                            "-fdata-sections",
                            "-fno-strict-aliasing",
                            "-fno-common",
                            "-fomit-frame-pointer",
                            "-finline-functions",
                            "-ftree-vectorize",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["opt"])],
            ),
            flag_set(
                actions = [
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-std=c++17",
                            '-std=gnu++17',
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["cxxopt"])],
            ),
            flag_set(
                actions = [
                    _ASSEMBLE_ACTION_NAME,
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _LINKSTAMP_COMPILE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                    _LTO_BACKEND_ACTION_NAME,
                    _CLIF_MATCH_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = [
                            "-g",
                            "-O0",
                            "-fprofile-arcs",
                            "-ftest-coverage",
                            "-DNDEBUG",
                            "-ffunction-sections",
                            "-fdata-sections",
                            "-fno-strict-aliasing",
                            "-fno-common",
                            "-fomit-frame-pointer",
                            "-finline-functions",
                            "-fPIC",
                            "-ftree-vectorize",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["coverage"])],
            ),
            flag_set(
                actions = [
                    _LINKSTAMP_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                    _LTO_BACKEND_ACTION_NAME,
                    _CLIF_MATCH_ACTION_NAME,
                ],
                flag_groups = [flag_group(flags = [
                    "-Wno-reorder",
                ] + users_cpp_only_compilation_flags)],
            ),
        ],
    )

    opt_feature = feature(name = "opt")

    feature_coverage = feature(name = "coverage")

    supports_dynamic_linker_feature = feature(name = "supports_dynamic_linker", enabled = True)

    objcopy_embed_flags_feature = feature(
        name = "objcopy_embed_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = ["objcopy_embed_data"],
                flag_groups = [flag_group(flags = ["-I", "binary"])],
            ),
        ],
    )

    dbg_feature = feature(name = "dbg")

    user_compile_flags_feature = feature(
        name = "user_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    _ASSEMBLE_ACTION_NAME,
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _LINKSTAMP_COMPILE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                    _LTO_BACKEND_ACTION_NAME,
                    _CLIF_MATCH_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["%{user_compile_flags}"],
                        iterate_over = "user_compile_flags",
                        expand_if_available = "user_compile_flags",
                    ),
                ],
            ),
        ],
    )

    include_paths_feature = feature(
        name = "include_paths",
        enabled = False,
        flag_sets = [
            flag_set(
                actions = [
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-I%{quote_include_paths}"],
                        iterate_over = "quote_include_paths",
                    ),
                    flag_group(
                        flags = ["-I%{include_paths}"],
                        iterate_over = "include_paths",
                    ),
                    flag_group(
                        flags = ["-I%{system_include_paths}"],
                        iterate_over = "system_include_paths",
                    ),
                ],
            ),
        ],
    )

    dependency_file_feature = feature(
        name = "dependency_file",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    _ASSEMBLE_ACTION_NAME,
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["/DEPENDENCY_FILE", "%{dependency_file}"],
                        expand_if_available = "dependency_file",
                    ),
                ],
            ),
        ],
    )

    compiler_input_flags_feature = feature(
        name = "compiler_input_flags",
        flag_sets = [
            flag_set(
                actions = [
                    _ASSEMBLE_ACTION_NAME,
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["/c", "%{source_file}"],
                        expand_if_available = "source_file",
                    ),
                ],
            ),
        ],
    )

    fastbuild_feature = feature(name = "fastbuild")

    sysroot = builtin_sysroot

    sysroot_feature = feature(
        name = "sysroot",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = [
                    _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _LINKSTAMP_COMPILE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CPP_MODULE_CODEGEN_ACTION_NAME,
                    _LTO_BACKEND_ACTION_NAME,
                    _CLIF_MATCH_ACTION_NAME,
                    _CPP_LINK_EXECUTABLE_ACTION_NAME,
                    _CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME,
                    _CPP_LINK_NODEPS_DYNAMIC_LIBRARY_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["--sysroot=%{sysroot}", "-L%{sysroot}/lib", "-L%{sysroot}/lib64"],
                        expand_if_available = "sysroot",
                    ),
                ],
            ),
        ],
    )

    external_include_paths_feature = feature(
        name = "external_include_paths",
        enabled = False,
        flag_sets = [
            flag_set(
                actions = [
                   _PREPROCESS_ASSEMBLE_ACTION_NAME,
                    _LINKSTAMP_COMPILE_ACTION_NAME,
                    _C_COMPILE_ACTION_NAME,
                    _CPP_COMPILE_ACTION_NAME,
                    _CPP_HEADER_PARSING_ACTION_NAME,
                    _CPP_MODULE_COMPILE_ACTION_NAME,
                    _CLIF_MATCH_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group(
                        flags = ["-isystem", "%{external_include_paths}"],
                        iterate_over = "external_include_paths",
                        expand_if_available = "external_include_paths",
                    ),
                ],
            ),
        ],
    )

    no_as_needed_feature = feature(
        name = "no_as_needed",
        enabled = False,
        flag_sets = [
            flag_set(
                actions = [
                    _CPP_LINK_EXECUTABLE_ACTION_NAME,
                    _CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME,
                    _CPP_LINK_NODEPS_DYNAMIC_LIBRARY_ACTION_NAME,
                    _CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
                ],
                flag_groups = [
                    flag_group (
                        iterate_over = "libraries_to_link",
                        flag_groups = [
                            flag_group (
                                flags = ["-Wl,--no-as-needed"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "dynamic_library",
                                ),
                            ),
                            flag_group (
                                flags = ["-l%{libraries_to_link.name}"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "dynamic_library",
                                ),
                            ),
                            flag_group (
                                flags = ["-Wl,--as-needed"],
                                expand_if_equal = variable_with_value(
                                    name = "libraries_to_link.type",
                                    value = "dynamic_library",
                                ),
                            ),
                        ],
                    ),
                ],
            )
        ],
    )

    features = [
        no_as_needed_feature,
        feature_coverage,
        env_feature,
        compile_flags_with_werror_feature,
        # include_paths_feature,
        # external_include_paths_feature,
        default_compile_flags_feature,
        default_link_flags_feature,
        supports_dynamic_linker_feature,
        supports_pic_feature,
        objcopy_embed_flags_feature,
        opt_feature,
        dbg_feature,
        user_compile_flags_feature,
        sysroot_feature,
        compile_flags_no_canonical_feature,
    ]

    artifact_name_patterns = []

    make_variables = []

    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.write(out, "Fake executable")

    return [
        cc_common.create_cc_toolchain_config_info(
            ctx = ctx,
            features = features,
            #action_configs = action_configs,
            artifact_name_patterns = artifact_name_patterns,
            cxx_builtin_include_directories = cxx_builtin_include_directories,
            toolchain_identifier = toolchain_identifier,
            host_system_name = host_system_name,
            target_system_name = target_system_name,
            target_cpu = target_cpu,
            target_libc = target_libc,
            compiler = compiler,
            abi_version = abi_version,
            abi_libc_version = abi_libc_version,
            tool_paths = tool_paths,
            make_variables = make_variables,
            builtin_sysroot = builtin_sysroot,
            cc_target_os = cc_target_os,
        ),
        DefaultInfo(
            executable = out,
        ),
    ]
