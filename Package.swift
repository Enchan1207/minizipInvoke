// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "minizipEx",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        // executable configuration
        .executable(
            name: "minizipExample",
            targets: ["minizipExample"]),
    ],
    targets: [
        // target for generate executable
        .executableTarget(
            name: "minizipExample",
            dependencies: ["Minizip"]),
        
        // target for build minizip-ng as Swift module
        .target(
            name: "Minizip",
            dependencies: [],
            path: "Sources/minizip-ng",
            exclude: [
                "code/test", "code/doc", "code/cmake",
                "code/mz_strm_os_win32.c", "code/mz_os_win32.c", "code/mz_crypt_winxp.c", "code/mz_crypt_winvista.c",
                "code/minizip.c", "code/minigzip.c", "code/mz_crypt_openssl.c", "code/mz_strm_bzip.c", "code/mz_strm_lzma.c", "code/mz_strm_zstd.c", "code/mz_strm_zlib.c"
            ],
            publicHeadersPath: "code",
            cSettings: [
                .define("HAVE_WZAES")
            ],
            linkerSettings: [
                .linkedLibrary("compression"),
                .linkedFramework("Security")
            ]),
    ]
)
