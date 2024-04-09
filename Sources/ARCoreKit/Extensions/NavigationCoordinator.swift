//
//  NavigationCoordinator.swift
//

import SwiftUI

public struct NavigationCoordinator<Path: Hashable, Content: View>: View {
    @ObservedObject var coordinator: Coordinator<Path>
    private var content: (Path) -> Content
    
    public init(
        coordinator: Coordinator<Path>,
        @ViewBuilder content: @escaping (Path) -> Content
    ) {
        self.coordinator = coordinator
        self.content = content
    }
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content(coordinator.root)
                .navigationDestination(for: Path.self) { path in
                    content(path)
                }
        }
        .environmentObject(coordinator)
    }
}

open class Coordinator<Path: Hashable>: ObservableObject {
    @Published private(set) var root: Path
    @Published var path: NavigationPath = .init()
    
    public init(root: Path) {
        self.root = root
    }
    
    open func append(_ path: Path) {
        self.path.append(path)
    }
    
    open func pop() {
        path.removeLast()
    }
    
    open func popToRoot() {
        path = .init()
    }
}
