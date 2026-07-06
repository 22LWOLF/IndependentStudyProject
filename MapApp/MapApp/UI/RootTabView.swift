//
//  RootTabView.swift
//  MapApp
//
//  App root: the four-tab shell. Build is the launch tab.
//

import SwiftUI

struct RootTabView: View {
    @StateObject private var model = AppModel()

    var body: some View {
        TabView(selection: $model.selectedTab) {
            BuildView()
                .tabItem { Label("Build", systemImage: "plus.circle.fill") }
                .tag(AppTab.build)

            ActiveView()
                .tabItem { Label("Active", systemImage: "figure.walk") }
                .tag(AppTab.active)

            RoutesView()
                .tabItem { Label("Routes", systemImage: "bookmark.fill") }
                .tag(AppTab.routes)

            YouView()
                .tabItem { Label("You", systemImage: "person.fill") }
                .tag(AppTab.you)
        }
        .environmentObject(model)
        .tint(Theme.denim)
    }
}

#Preview {
    RootTabView()
}
