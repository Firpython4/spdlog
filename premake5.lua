-- premake5.lua

-- Minimum Premake version
premake.minimum_version("5.0")

-- Project information
project("spdlog")
version("1.9.3") -- Update with the actual version

-- Set the C++ standard
cppdialect("C++11")

-- Compiler configurations
if os.host() == "windows" then
    buildoptions { "/Zc:__cplusplus", "/MP" }
end

-- Set the build type to Release if not specified
if not (buildtype and buildtype ~= "") then
    buildtype "Release"
end

-- Options
option("SPDLOG_BUILD_ALL", "Build all artifacts", "OFF")
option("SPDLOG_BUILD_SHARED", "Build shared library", "OFF")
option("SPDLOG_ENABLE_PCH", "Build with precompiled header", "OFF")
option("SPDLOG_BUILD_PIC", "Build position independent code (-fPIC)", "OFF")
option("SPDLOG_BUILD_EXAMPLE", "Build example", "ON")
option("SPDLOG_BUILD_EXAMPLE_HO", "Build header only example", "OFF")
option("SPDLOG_BUILD_TESTS", "Build tests", "OFF")
option("SPDLOG_BUILD_TESTS_HO", "Build tests using header only version", "OFF")
option("SPDLOG_BUILD_BENCH", "Build benchmarks", "OFF")
option("SPDLOG_SANITIZE_ADDRESS", "Enable address sanitizer in tests", "OFF")
option("SPDLOG_BUILD_WARNINGS", "Enable compiler warnings", "OFF")
option("SPDLOG_SYSTEM_INCLUDES", "Include as system headers", "OFF")
option("SPDLOG_INSTALL", "Generate the install target", "OFF")
option("SPDLOG_USE_STD_FORMAT", "Use std::format instead of fmt library", "OFF")
option("SPDLOG_FMT_EXTERNAL", "Use external fmt library instead of bundled", "OFF")
option("SPDLOG_FMT_EXTERNAL_HO", "Use external fmt header-only library instead of bundled", "OFF")
option("SPDLOG_NO_EXCEPTIONS", "Compile with -fno-exceptions. Call abort() on any spdlog exceptions", "OFF")

-- Set the C++ standard based on configuration
if _OPTIONS["SPDLOG_USE_STD_FORMAT"] then
    cppdialect "C++20"
else
    cppdialect "C++11"
end

-- Set compiler flags based on platform
filter { "system:windows", "action:gmake", "toolset:gcc" }
    buildoptions { "-fPIC" }

-- Set preprocessor definitions based on options
if _OPTIONS["SPDLOG_SYSTEM_INCLUDES"] then
    defines { "SPDLOG_INCLUDES_LEVEL=SYSTEM" }
else
    defines { "SPDLOG_INCLUDES_LEVEL=" }
end

-- Project configuration
project("spdlog")
    targetdir("bin/%{cfg.buildcfg}")

-- Add source files
files {
    "src/spdlog.cpp",
    "src/stdout_sinks.cpp",
    "src/color_sinks.cpp",
    "src/file_sinks.cpp",
    "src/async.cpp",
    "src/cfg.cpp",
}

-- Header-only version
project("spdlog_header_only")
    kind("None")

-- Configure build type-specific settings
filter "configurations:Debug"
    defines { "DEBUG" }
    symbols "On"

filter "configurations:Release"
    defines { "NDEBUG" }
    optimize "On"

-- Add example projects if specified
if _OPTIONS["SPDLOG_BUILD_EXAMPLE"] or _OPTIONS["SPDLOG_BUILD_EXAMPLE_HO"] or _OPTIONS["SPDLOG_BUILD_ALL"] then
    project("example")
    kind("ConsoleApp")
    files { "example/example.cpp" }
    links { "spdlog" }
    filter "configurations:Debug"
        symbols "On"
    filter "configurations:Release"
        optimize "On"

    if _OPTIONS["SPDLOG_BUILD_EXAMPLE_HO"] then
        project("example_header_only")
        kind("ConsoleApp")
        files { "example/example.cpp" }
        links { "spdlog_header_only" }
        filter "configurations:Debug"
            symbols "On"
        filter "configurations:Release"
            optimize "On"
    end
end

-- Add test projects if specified
if _OPTIONS["SPDLOG_BUILD_TESTS"] or _OPTIONS["SPDLOG_BUILD_TESTS_HO"] or _OPTIONS["SPDLOG_BUILD_ALL"] then
    project("tests")
    kind("ConsoleApp")
    files { "tests/*.cpp" }
    links { "spdlog" }
    filter "configurations:Debug"
        symbols "On"
    filter "configurations:Release"
        optimize "On"

    if _OPTIONS["SPDLOG_BUILD_TESTS_HO"] then
        project("tests_header_only")
        kind("ConsoleApp")
        files { "tests/*.cpp" }
        links { "spdlog_header_only" }
        filter "configurations:Debug"
            symbols "On"
        filter "configurations:Release"
            optimize "On"
    end
end

-- Add benchmark projects if specified
if _OPTIONS["SPDLOG_BUILD_BENCH"] or _OPTIONS["SPDLOG_BUILD_ALL"] then
    project("bench")
    kind("ConsoleApp")
    files { "bench/*.cpp" }
    links { "spdlog" }
    filter "configurations:Debug"
        symbols "On"
    filter "configurations:Release"
        optimize "On"
end

-- Add sanitizers if specified
if _OPTIONS["SPDLOG_SANITIZE_ADDRESS"] then
    sanitize("Address")
end

-- Install targets if specified
if _OPTIONS["SPDLOG_INSTALL"] then
    -- TODO: Add installation rules
end
