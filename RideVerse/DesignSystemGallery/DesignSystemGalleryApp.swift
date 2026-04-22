//
//  DesignSystemGalleryApp.swift
//  DesignSystemGallery
//
//  Created by Василий on 22.04.2026.
//

import SwiftUI
import DesignSystem

@main
struct DesignSystemGalleryApp: App {
    var body: some Scene {
            WindowGroup {
                NavigationStack {
                    DesignSystemGallery()
                }
                .preferredColorScheme(.dark)
            }
        }
}
