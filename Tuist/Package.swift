// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "Alamofire": .framework,
            "ComposableArchitecture": .staticFramework,
            "KakaoSDKUser": .staticFramework,
            "KakaoSDKAuth": .staticFramework,
            "KakaoSDKCommon": .staticFramework,
            "Kingfisher": .staticFramework,
            "iamport-ios": .staticFramework
        ]
    )
#endif

let package = Package(
    name: "FoodPick",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.10.2"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.23.1"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.26.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.2"),
        .package(url: "https://github.com/iamport/iamport-ios.git", from: "1.4.7")
    ]
)
