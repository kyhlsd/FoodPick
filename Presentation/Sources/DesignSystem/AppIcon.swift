//
//  AppIcon.swift
//  Presentation
//
//  Created by 김영훈 on 12/12/25.
//

import SwiftUI

enum AppIcon {
    
    static let chevron = Image("chevron", bundle: .module).renderingMode(.template)
    static let search = Image("search", bundle: .module).renderingMode(.template)
    static let likeEmpty = Image("like_empty", bundle: .module).renderingMode(.template)
    static let likeFill = Image("like_fill", bundle: .module).renderingMode(.template)
    static let starEmpty = Image("star_empty", bundle: .module).renderingMode(.template)
    static let starFill = Image("star_fill", bundle: .module).renderingMode(.template)
    static let glint = Image("glint", bundle: .module).renderingMode(.template)
    static let list = Image("list", bundle: .module).renderingMode(.template)
    static let time = Image("time", bundle: .module).renderingMode(.template)
    static let distance = Image("distance", bundle: .module).renderingMode(.template)
    static let run = Image("run", bundle: .module).renderingMode(.template)
    static let parking = Image("parking", bundle: .module).renderingMode(.template)
    static let check = Image("check", bundle: .module).renderingMode(.template)
    static let write = Image("write", bundle: .module).renderingMode(.template)
    static let leaf = Image("leaf", bundle: .module).renderingMode(.template)
    static let location = Image("location", bundle: .module).renderingMode(.template)
    static let detail = Image("detail", bundle: .module).renderingMode(.template)
    
    // Category
    static let coffee = Image("coffee", bundle: .module)
    static let fastfood = Image("fastfood", bundle: .module)
    static let dessert = Image("dessert", bundle: .module)
    static let bakery = Image("bakery", bundle: .module)
    static let more = Image("more", bundle: .module)
    
    // TabBar
    static let homeFill = Image("home_fill", bundle: .module).renderingMode(.template)
    static let homeEmpty = Image("home_empty", bundle: .module).renderingMode(.template)
    static let orderFill = Image("order_fill", bundle: .module).renderingMode(.template)
    static let orderEmpty = Image("order_empty", bundle: .module).renderingMode(.template)
    static let pickFill = Image("pick_fill", bundle: .module).renderingMode(.template)
    static let pickEmpty = Image("pick_empty", bundle: .module).renderingMode(.template)
    static let communityFill = Image("community_fill", bundle: .module).renderingMode(.template)
    static let communityEmpty = Image("community_empty", bundle: .module).renderingMode(.template)
    static let profileFill = Image("profile_fill", bundle: .module).renderingMode(.template)
    static let profileEmpty = Image("profile_empty", bundle: .module).renderingMode(.template)
}
