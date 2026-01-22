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
    static let desert = Image("desert", bundle: .module)
    static let bakery = Image("bakery", bundle: .module)
    static let total = Image("more", bundle: .module)
    static let more = Image(systemName: "ellipsis")
    
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
 
    // Video
    static let gearshapeFill = Image(systemName: "gearshape.fill")
    static let views = Image(systemName: "eye.fill")
    static let captionsBubbleFill = Image(systemName: "captions.bubble.fill")
    static let captionsBubbleEmpty = Image(systemName: "captions.bubble")
    static let xmark = Image(systemName: "xmark")
    
    // Map
    static let startPin = UIImage(named: "StartPin", in: .module, with: nil)
    static let endPin = UIImage(named: "EndPin", in: .module, with: nil)
    static let currentPin = {
        let config = UIImage.SymbolConfiguration(paletteColors: [.white, .systemOrange])
        return UIImage(systemName: "figure.walk.circle.fill", withConfiguration: config)
    }()
    
    // etc.
    static let kakao = Image("kakao", bundle: .module)
    static let xmarkCircle = Image(systemName: "xmark.circle.fill")
    static let up = Image(systemName: "chevron.up")
    static let exclamationMark = Image(systemName: "exclamationmark.triangle.fill")
    static let photo = Image(systemName: "photo")
    static let checkMarkFill = Image(systemName: "checkmark.square.fill")
    static let checkMarkEmpty = Image(systemName: "checkmark.square")
    static let minusSquare = Image(systemName: "minus.square")
    static let plusSquare = Image(systemName: "plus.square")
    static let cart = Image(systemName: "cart")
    static let trash = Image(systemName: "trash")
    static let playCircle = Image(systemName: "play.circle")
    static let pencil = Image(systemName: "pencil.line")
    static let video = Image(systemName: "video.fill")
    static let chat = Image(systemName: "message.fill")
    static let paperplane = Image(systemName: "paperplane.fill")
    static let photoPlus = Image(systemName: "photo.badge.plus")
}
