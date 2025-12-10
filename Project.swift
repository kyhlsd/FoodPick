import ProjectDescription

let project = Project(
    name: "FoodPick",
    targets: [
        .target(
            name: "FoodPick",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.FoodPick",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["FoodPick/Sources/**"],
            resources: ["FoodPick/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "FoodPickTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.FoodPickTests",
            infoPlist: .default,
            sources: ["FoodPick/Tests/**"],
            resources: [],
            dependencies: [.target(name: "FoodPick")]
        ),
    ]
)
