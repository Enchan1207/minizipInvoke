// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "minizipPackage",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "minizipPackage",
            targets: ["minizipPackage"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "minizipPackage",
            dependencies: ["Minizip"]),
        .target(
            name: "Minizip",
            dependencies: [],
            path: "Sources/minizip-ng",
            exclude: [
                "code/test", "code/doc", "code/cmake",
                "code/mz_strm_os_win32.c", "code/mz_os_win32.c", "code/mz_crypt_winxp.c", "code/mz_crypt_winvista.c"
            ],
            publicHeadersPath: "code",
            cSettings: [
                .define("HAVE_INTTYPES_H"),
                .define("HAVE_PKCRYPT"),
                .define("HAVE_STDINT_H"),
                .define("HAVE_WZAES"),
                .define("HAVE_ZLIB"),
                .define("ZLIB_COMPAT")
            ],
            linkerSettings: [
                .linkedLibrary("z")
            ]),
        .testTarget(
            name: "minizipPackageTests",
            dependencies: ["minizipPackage"]),
    ]
)
