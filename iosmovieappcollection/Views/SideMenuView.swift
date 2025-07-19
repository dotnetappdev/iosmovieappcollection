//
//  SideMenuView.swift
//  iosmovieappcollection
//
//  Created by david on 19/07/2025.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ZStack {
            if isShowing {
                // Background overlay
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowing = false
                        }
                    }
                
                // Side menu content
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "film.stack.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.accentColor)
                            
                            Text("Movie Collection")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Organize & Discover")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                        .padding(.bottom, 30)
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        // Menu items
                        VStack(alignment: .leading, spacing: 0) {
                            SideMenuRow(
                                icon: "magnifyingglass",
                                title: "Search Movies",
                                action: { /* Navigate to search */ }
                            )
                            
                            SideMenuRow(
                                icon: "heart.fill",
                                title: "Wishlist",
                                action: { /* Navigate to wishlist */ }
                            )
                            
                            SideMenuRow(
                                icon: "star.fill",
                                title: "Favorites",
                                action: { /* Navigate to favorites */ }
                            )
                            
                            SideMenuRow(
                                icon: "clock.fill",
                                title: "Recently Added",
                                action: { /* Navigate to recent */ }
                            )
                            
                            SideMenuRow(
                                icon: "chart.bar.fill",
                                title: "Statistics",
                                action: { /* Navigate to stats */ }
                            )
                            
                            Divider()
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            
                            SideMenuRow(
                                icon: "info.circle.fill",
                                title: "About",
                                action: { /* Show about */ }
                            )
                            
                            SideMenuRow(
                                icon: "questionmark.circle.fill",
                                title: "Help",
                                action: { /* Show help */ }
                            )
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Footer
                        VStack(alignment: .leading, spacing: 4) {
                            if appSettings.isAPIConfigured {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("API Connected")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("API Not Configured")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .frame(maxWidth: 280)
                    .background(Color(.systemBackground))
                    .shadow(radius: 10)
                    
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowing)
    }
}

struct SideMenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.accentColor)
                
                Text(title)
                    .foregroundColor(.primary)
                    .font(.body)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Color.clear
                .contentShape(Rectangle())
        )
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SideMenuView(isShowing: .constant(true))
            .environmentObject(AppSettings())
    }
}