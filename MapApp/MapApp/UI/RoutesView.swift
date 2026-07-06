//
//  RoutesView.swift
//  MapApp
//
//  Saved-routes tab. Search, favorite, delete, and tap to reload any route
//  straight onto the Build tab.
//

import SwiftUI
import CoreData

struct RoutesView: View {
    @EnvironmentObject private var model: AppModel

    @State private var routes: [SavedRoute] = []
    @State private var search = ""
    @State private var favoritesOnly = false

    var body: some View {
        NavigationStack {
            Group {
                if filtered.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Routes")
            .searchable(text: $search, prompt: "Search routes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        favoritesOnly.toggle()
                    } label: {
                        Image(systemName: favoritesOnly ? "star.fill" : "star")
                            .foregroundStyle(Theme.sun)
                    }
                }
            }
        }
        .onAppear(perform: refresh)
    }

    // MARK: - Data

    private var filtered: [SavedRoute] {
        routes.filter { route in
            if favoritesOnly && !route.isFavorite { return false }
            guard !search.isEmpty else { return true }
            let haystack = [
                displayName(route),
                typeName(route),
                String(format: "%.1f", route.targetDistance)
            ].joined(separator: " ").lowercased()
            return haystack.contains(search.lowercased())
        }
    }

    private func refresh() {
        routes = CoreDataManager.shared.fetchAllRoutes()
    }

    // MARK: - List

    private var list: some View {
        List {
            ForEach(filtered, id: \.objectID) { route in
                row(route)
            }
            .onDelete(perform: delete)
        }
        .scrollContentBackground(.hidden)
    }

    private func row(_ route: SavedRoute) -> some View {
        Button {
            model.load(route)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: typeIcon(route))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.denim)
                    .frame(width: 40, height: 40)
                    .background(Theme.denimSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(displayName(route))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle(route))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    toggleFavorite(route)
                } label: {
                    Image(systemName: route.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(route.isFavorite ? Theme.sun : .secondary)
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: favoritesOnly ? "star" : "bookmark")
                .font(.system(size: 40))
                .foregroundStyle(Theme.denim)
            Text(favoritesOnly ? "No favorites yet" : "No saved routes")
                .font(.title3.weight(.semibold))
            Text(favoritesOnly
                 ? "Star a route and it will show up here."
                 : "Build a route, hit Save, and it will live here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Actions

    private func delete(at offsets: IndexSet) {
        let items = filtered
        for index in offsets {
            CoreDataManager.shared.deleteRoute(items[index])
        }
        refresh()
    }

    private func toggleFavorite(_ route: SavedRoute) {
        route.isFavorite.toggle()
        CoreDataManager.shared.saveContext()
        refresh()
    }

    // MARK: - Formatting

    private func displayName(_ route: SavedRoute) -> String {
        if let name = route.name, !name.isEmpty { return name }
        return "Route #\(route.routeNumber)"
    }

    private func typeName(_ route: SavedRoute) -> String {
        switch RouteConfig.RouteType(rawValue: Int(route.routeType)) {
        case .oneWay:     return "One-way"
        case .outAndBack: return "Out & back"
        case .loop:       return "Loop"
        case .none:       return "Route"
        }
    }

    private func typeIcon(_ route: SavedRoute) -> String {
        switch RouteConfig.RouteType(rawValue: Int(route.routeType)) {
        case .oneWay:     return "arrow.up.forward"
        case .outAndBack: return "arrow.left.and.right"
        case .loop, .none: return "arrow.triangle.2.circlepath"
        }
    }

    private func subtitle(_ route: SavedRoute) -> String {
        var parts = [String(format: "%.1f mi", route.targetDistance), typeName(route)]
        if let date = route.createdDate {
            parts.append(date.formatted(date: .abbreviated, time: .omitted))
        }
        return parts.joined(separator: " · ")
    }
}

#Preview {
    RootTabView()
}
