//
//  MainTabView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var selectedTab = 0
    @State private var showingSideMenu = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main Tab View
                TabView(selection: $selectedTab) {
                    MovieListView()
                        .tabItem {
                            Image(systemName: "film.fill")
                            Text("Movies")
                        }
                        .tag(0)
                    
                    BarcodeScannerView()
                        .tabItem {
                            Image(systemName: "barcode.viewfinder")
                            Text("Scan")
                        }
                        .tag(1)
                    
                    NowPlayingView()
                        .tabItem {
                            Image(systemName: "play.circle.fill")
                            Text("Now Playing")
                        }
                        .tag(2)
                    
                    CollectionsView()
                        .tabItem {
                            Image(systemName: "folder.fill")
                            Text("Collections")
                        }
                        .tag(3)
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .tag(4)
                }
                .accentColor(.primary)
                
                // Side Menu
                SideMenuView(isShowing: $showingSideMenu)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingSideMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.primary)
                    }
                }
                
                if appSettings.showMovieCount {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        MovieCountView()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures single view on iPhone
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppSettings())
    }
}