import ProjectDescription

let iOSVersion = "16.0"
let swiftVersion = "6.2"
let teamID = "4QUWH828P3"

// SwiftLint 스크립트
let swiftLintScript: TargetScript = .pre(
    script: """
    export PATH="$PATH:/opt/homebrew/bin:/usr/local/bin"
    if which swiftlint >/dev/null; then
        swiftlint || true
    else
        echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    fi
    """,
    name: "SwiftLint",
    basedOnDependencyAnalysis: false
)

let project = Project(
    name: "FoodPick",
    targets: [
        .target(
            name: "FoodPick",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.kyh.FoodPick",
            deploymentTargets: .iOS(iOSVersion),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "FoodPick",
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UIUserInterfaceStyle": "Light",
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait"
                    ],
                    "NSLocationWhenInUseUsageDescription": "내 주위 가게 정보를 받아오기 위해 위치 정보를 사용합니다.",
                    "NSAppTransportSecurity": [
                        "NSAllowsArbitraryLoads": true
                    ],
                    "UIBackgroundModes": ["remote-notification"],
                    "LSApplicationQueriesSchemes": [
                        "kakaokompassauth",
                        "kakaolink",
                        "kftc-bankpay",
                        "ispmobile",
                        "itms-apps",
                        "hdcardappcardansimclick",
                        "smhyundaiansimclick",
                        "shinhan-sr-ansimclick",
                        "smshinhanansimclick",
                        "kb-acp",
                        "kb-auth",
                        "kb-screen",
                        "kbbank",
                        "liivbank",
                        "newliiv",
                        "mpocket.online.ansimclick",
                        "ansimclickscard",
                        "ansimclickipcollect",
                        "vguardstart",
                        "samsungpay",
                        "scardcertiapp",
                        "lottesmartpay",
                        "lotteappcard",
                        "cloudpay",
                        "nhappcardansimclick",
                        "nonghyupcardansimclick",
                        "citispay",
                        "citicardappkr",
                        "citimobileapp",
                        "kakaotalk",
                        "payco",
                        "chaipayment",
                        "hyundaicardappcardid",
                        "com.wooricard.wcard",
                        "lmslpay",
                        "lguthepay-xpay",
                        "supertoss",
                        "newsmartpib",
                        "kakaobank"
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["kakao$(KAKAO_APP_KEY)"]
                        ],
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["foodpick", "iamport"]
                        ]
                    ],
                    "KAKAO_APP_KEY": "$(KAKAO_APP_KEY)"
                ]
            ),
            sources: ["FoodPick/Sources/**"],
            resources: ["FoodPick/Resources/**"],
            entitlements: "FoodPick/FoodPick.entitlements",
            scripts: [swiftLintScript],
            dependencies: [
                .target(name: "Presentation"),
                .target(name: "Domain"),
                .target(name: "Data")
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": .string(teamID),
                    "SWIFT_VERSION": .string(swiftVersion)
                ],
                configurations: [
                    .debug(name: "Debug", xcconfig: "Config/Secrets/Secrets.xcconfig"),
                    .release(name: "Release", xcconfig: "Config/Secrets/Secrets.xcconfig")
                ]
            )
        ),
        
            .target(
                name: "FoodPickTests",
                destinations: .iOS,
                product: .unitTests,
                bundleId: "io.tuist.FoodPickTests",
                infoPlist: .default,
                sources: ["FoodPick/Tests/**"],
                resources: [],
                dependencies: [.target(name: "FoodPick")],
                settings: .settings(
                    base: [
                        "DEVELOPMENT_TEAM": .string(teamID),
                        "SWIFT_VERSION": .string(swiftVersion)
                    ]
                )
            ),
        
            .target(name: "Core",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Core",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Core/Sources/**"],
                    scripts: [swiftLintScript],
                    dependencies: [],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID),
                            "SWIFT_VERSION": .string(swiftVersion)
                        ]
                    )
                   ),
        
            .target(name: "Domain",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Domain",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Domain/Sources/**"],
                    scripts: [swiftLintScript],
                    dependencies: [
                        .target(name: "Core")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID),
                            "SWIFT_VERSION": .string(swiftVersion)
                        ]
                    )
                   ),
        
            .target(name: "Data",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Data",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Data/Sources/**"],
                    scripts: [swiftLintScript],
                    dependencies: [
                        .target(name: "Core"),
                        .target(name: "Domain"),
                        .external(name: "Alamofire"),
                        .external(name: "KakaoSDKCommon"),
                        .external(name: "KakaoSDKUser"),
                        .external(name: "KakaoSDKAuth"),
                        .external(name: "iamport-ios")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID),
                            "SWIFT_VERSION": .string(swiftVersion)
                        ]
                    )
                   ),
        
            .target(name: "Presentation",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Presentation",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Presentation/Sources/**"],
                    resources: ["Presentation/Resources/**"],
                    scripts: [swiftLintScript],
                    dependencies: [
                        .target(name: "Domain"),
                        .target(name: "Data"),
                        .target(name: "Core"),
                        .external(name: "ComposableArchitecture"),
                        .external(name: "Kingfisher")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID),
                            "SWIFT_VERSION": .string(swiftVersion)
                        ]
                    )
                   )
    ]
)
