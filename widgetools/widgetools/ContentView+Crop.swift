//
//  ContentView+Crop.swift
//  widgetools
//
//  Created by wyw on 2022/5/13.
//

import SwiftUI
import WidgetKit

extension ContentView {
    @ViewBuilder func AutoPlusSymbol(for object: UIImage?) -> some View {
        if object == nil {
            VStack {
                Image(systemName: "plus.circle")
                    .font(.system(size: 40, weight: .regular, design: .monospaced))
                    .foregroundColor(.gray)
                Text("Wallpaper")
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
        } else {Spacer()}
    }
    
    @ViewBuilder var LightModeWallpaper: some View {
        Image(uiImage: bgBright ?? UIImage())
            .resizable()
            .aspectRatio(UIScreen.main.bounds.width / UIScreen.main.bounds.height, contentMode: .fit)
            .overlay(AutoPlusSymbol(for: bgBright))
            .background(Color(white: 0.9))
            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .onTapGesture {
                isPickingLight = true
                showsPicker = true
            }.padding()
    }
    
    @ViewBuilder var DarkModeWallpaper: some View {
        Image(uiImage: bgDark ?? UIImage())
            .resizable()
            .aspectRatio(UIScreen.main.bounds.width / UIScreen.main.bounds.height, contentMode: .fit)
            .overlay(AutoPlusSymbol(for: bgDark))
            .background(Color(white: 0.3))
            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .onTapGesture {
                isPickingLight = false
                showsPicker = true
            }.padding()
    }
    
    func updateWallpaperSave() {
        if isPickingLight {
            // Save light wallpaper -----------------------------------------------------------
            if let brightImg = bgBright {
                //full wallpaper
                try! brightImg.jpegData(compressionQuality: 1.0)?.write(to: URL(fileURLWithPath: "\(wallPath)/imgB.jpg"), options: .atomic)
                //cropped wallpaper
                for pos in 1...11 {
                    if let img = cropImage(brightImg, toRect: WidgetCropPostion(rawValue: pos - 1)!.getRect()) {
                        try! img.jpegData(compressionQuality: 1.0)!.write(to: URL(fileURLWithPath: "\(wallPath)/imgB\(pos).jpg"), options: .atomic)
                    } else {
                        //error and cleanup
                        try? FileManager.default.removeItem(atPath: "\(wallPath)/imgB.jpg")
                        bgBright = nil
                        errAlert = true
                        return
                    }
                }
            }
            
        } else {
            // Save dark wallpaper -----------------------------------------------------------
            if let darkImg = bgDark {
                //full wallpaper
                try! darkImg.jpegData(compressionQuality: 1.0)?.write(to: URL(fileURLWithPath: "\(wallPath)/imgD.jpg"), options: .atomic)
                //cropped wallpaper
                for pos in 1...11 {
                    if let img = cropImage(darkImg, toRect: WidgetCropPostion(rawValue: pos - 1)!.getRect()) {
                        try! img.jpegData(compressionQuality: 1.0)!.write(to: URL(fileURLWithPath: "\(wallPath)/imgD\(pos).jpg"), options: .atomic)
                    } else {
                        //error and cleanup
                        try? FileManager.default.removeItem(atPath: "\(wallPath)/imgD.jpg")
                        bgDark = nil
                        errAlert = true
                        return
                    }
                }
            }
            
        }
        //print(imgPath)
        postSaveWall()
    }
    
    func postSaveWall() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
