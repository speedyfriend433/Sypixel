//
//  MainTabView.swift
//  Sypixel
//
//  Created by 이지안 on 5/30/25.
//

import SwiftUI

struct MainTabView: View {

    init() {
        let tabBarAppearance = UITabBarAppearance()
        
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.sypixelDarkGray.opacity(0.95))
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.sypixelGold)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.sypixelGold)
            // .font: UIFont(name: "YourPixelFontName", size: 10) ?? UIFont.systemFont(ofSize: 10)
        ]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.sypixelLightGray.opacity(0.7))
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.sypixelLightGray.opacity(0.7))
            // .font: UIFont(name: "YourPixelFontName", size: 10) ?? UIFont.systemFont(ofSize: 10)
        ]
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        // UITabBar.appearance().shadowImage = UIImage()
        // UITabBar.appearance().backgroundImage = UIImage()
        // tabBarAppearance.shadowColor = .clear
    }

    var body: some View {
        TabView {
            PlayerSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(1)
            // Text("Resources (Coming Soon)")
            //    .minecraftFont(size: 20).foregroundColor(.white)
            //    .frame(maxWidth: .infinity, maxHeight: .infinity)
            //    .background(Color.sypixelDarkGray.ignoresSafeArea())
            //    .tabItem {
            //        Label("Resources", systemImage: "books.vertical.fill")
            //    }
            //    .tag(2)
        }
        .accentColor(.sypixelGold)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .preferredColorScheme(.dark) 
    }
}
