//
//  NavigationCoordinator.swift
//

import SwiftUI

public typealias CoordinatorDismiss = () -> Void
public typealias Pathable = Hashable & Identifiable

public struct NavigationCoordinator<Path: Pathable, Content: View>: View {
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
        .fullScreenCover(item: $coordinator.fullScreen, onDismiss: coordinator.onDismiss) { fullScreen in
            content(fullScreen)
        }
        .sheet(item: $coordinator.sheet, onDismiss: coordinator.onDismiss) { sheet in
            content(sheet)
        }
    }
}

open class Coordinator<Path: Pathable>: ObservableObject {
    @Published private(set) var root: Path
    @Published var path: NavigationPath = .init()
    @Published var fullScreen: Path?
    @Published var sheet: Path?
    
    private var onDismissCompletion: CoordinatorDismiss?
    
    public init(root: Path) {
        self.root = root
    }
    
    open func append(_ path: Path) {
        self.path.append(path)
    }
    
    open func pop() {
        guard path.count > 0 else { return }
        path.removeLast()
    }
    
    open func popToRoot() {
        path = .init()
    }
    
    open func show(sheet: Path) {
        self.sheet = sheet
    }
    
    open func show(fullScreen: Path) {
        self.fullScreen = fullScreen
    }
    
    open func dismiss(completion: CoordinatorDismiss?) {
        guard sheet != nil || fullScreen != nil else {
            completion?()
            return
        }
        self.onDismissCompletion = completion
        sheet = nil
        fullScreen = nil
    }
    
    open func onDismiss() {
        self.onDismissCompletion?()
        self.onDismissCompletion = nil
    }
}
