import ProjectDescription

let iOSVersion = "16.0"
let teamID = "4QUWH828P3"

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
                    "NSLocationWhenInUseUsageDescription": "내 주위 가게 정보를 받아오기 위해 위치 정보를 사용합니다."
                ]
            ),
            sources: ["FoodPick/Sources/**"],
            resources: ["FoodPick/Resources/**"],
            dependencies: [
                .target(name: "Presentation"),
                .target(name: "Domain"),
                .target(name: "Data")
            ],
            settings: .settings(
                base: [
                    "DEVELOPMENT_TEAM": .string(teamID),
                    "SWIFT_VERSION": "6.2"
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
                        "SWIFT_VERSION": "6.2"
                    ]
                )
            ),
        
            .target(name: "Core",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Core",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Core/Sources/**"],
                    dependencies: [],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID),
                            "SWIFT_VERSION": "6.2"
                        ]
                    )
                   ),
        
            .target(name: "Domain",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Domain",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Domain/Sources/**"],
                    dependencies: [
                        .target(name: "Core")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID),
                            "SWIFT_VERSION": "6.2"
                        ]
                    )
                   ),
        
            .target(name: "Data",
                    destinations: [.iPhone],
                    product: .framework,
                    bundleId: "com.kyh.Data",
                    deploymentTargets: .iOS(iOSVersion),
                    sources: ["Data/Sources/**"],
                    dependencies: [
                        .target(name: "Core"),
                        .target(name: "Domain")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID),
                            "SWIFT_VERSION": "6.2"
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
                    dependencies: [
                        .target(name: "Domain"),
                        .target(name: "Data"),
                        .target(name: "Core")
                    ],
                    settings: .settings(
                        base: [
                            "DEVELOPMENT_TEAM": .string(teamID),
                            "SWIFT_VERSION": "6.2"
                        ]
                    )
                   ),
    ]
)
