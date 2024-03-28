import XCTest
import SnapshotTesting
import SwiftUI

enum SnapshotError: Error {
    case failed(String)
}

public extension XCTestCase {

    @MainActor
    func verify<T: View>(view: T, record: Bool = false, testName: String = #function, file: StaticString = #file) throws {
        try verify(viewController: UIHostingController(rootView: view.ignoresSafeArea(edges: .all)), record: record, testName: testName, file: file)
    }

    @MainActor
    func verify<T: UIViewController>(viewController: T, record: Bool = false, testName: String = #function, file: StaticString = #file) throws {

        let fileUrl = URL(fileURLWithPath: "\(file)", isDirectory: false)
        let fileName = fileUrl.deletingPathExtension().lastPathComponent

        let snapshotDirectoryUrl = fileUrl
            .deletingLastPathComponent() // remove class name
            .deletingLastPathComponent() // remove "habitacliaTests" folder
            .appendingPathComponent("__Snapshots__")
            .appendingPathComponent(fileName)

        if let message = verifySnapshot(
            of: viewController,
            as: .image(
                precision: 0.97,
                perceptualPrecision: 0.97,
                size: CGSize(width: 400, height: 800),
                traits: .init(displayScale: 1.0)
            ),
            snapshotDirectory: snapshotDirectoryUrl.path,
            testName: testName
        ) {
            throw SnapshotError.failed(message)
        }
    }
}
