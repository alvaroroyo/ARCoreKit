//
//  ChartDataSource.swift
//  AR Domotics
//
//  Created by Alvaro Royo on 15/3/24.
//

import SwiftUI

@available(iOS 17.0, *)
public struct ChartViewManager: View {
    var step: Step
    @State var items: [ChartDataModel.ChartItem] = []
    @State var numberOfAxisY: ChartDataModel.AxisY
    @State var typeAxisY: ChartDataModel.ValueType
    var isPaginated: Bool
    var didBecameLastIndex: (() -> ())? = nil
    
    @State private var displayedItems: [ChartDataModel.ChartItem] = []
    @State private var afterButtonDisabled: Bool = true
    @State private var beforeButtonDisabled: Bool = true
    @State private var showLoading: Bool = true
    @State private var showEmpty: Bool = false
    @State private var index: Int? = 0
    
    public init(
        step: Step = .default,
        items: [ChartDataModel.ChartItem] = [],
        numberOfAxisY: ChartDataModel.AxisY = .five,
        typeAxisY: ChartDataModel.ValueType = .euro,
        isPaginated: Bool = false,
        didBecameLastIndex: ( () -> Void)? = nil
    ) {
        self.step = step
        self.items = items
        self.numberOfAxisY = numberOfAxisY
        self.typeAxisY = typeAxisY
        self.isPaginated = isPaginated
        self.didBecameLastIndex = didBecameLastIndex
    }
    
    public var body: some View {
        ChartView(
            items: $displayedItems,
            numberOfAxisY: $numberOfAxisY,
            typeAxisY: $typeAxisY,
            afterButtonDisabled: $afterButtonDisabled,
            beforeButtonDisabled: $beforeButtonDisabled,
            showLoading: $showLoading,
            loadingView: { EmptyView() },
            showEmpty: $showEmpty,
            emptyView: { EmptyView() },
            didSelectAfter: {
                index = getNextIndex()
            },
            didSelectBefore: {
                index = getPreviousIndex()
            },
            didSelectItem: { item in
                
            }
        )
        .onChange(of: items, initial: true) { oldValue, newValue in
            showLoading = false
            print(showLoading)
            if newValue.isEmpty {
                showEmpty = true
            } else {
                if oldValue.count == newValue.count {
                    beforeButtonDisabled = true
                    afterButtonDisabled = newValue.count > step.value
                    index = 0
                } else if oldValue.count > newValue.count {
                    let newIndex = index
                    index = newIndex
                } else if oldValue.count < newValue.count {
                    guard let newIndex = updateIndex() else { return }
                    index = newIndex
                }
            }
        }
        .onChange(of: index, initial: true) { _, _ in
            didEditIndex()
        }
    }
}

@available(iOS 17.0, *)
public extension ChartViewManager {
    enum Step {
        case `default`
        case custom(Int)
        
        private var defaultStep: Int { 5 }
        var value: Int {
            switch self {
            case .default: return defaultStep
            case .custom(let step):
                guard step > 0 else { return defaultStep }
                return step
            }
        }
    }
}

@available(iOS 17.0, *)
private extension ChartViewManager {
    func didEditIndex() {
        guard let index else {
            afterButtonDisabled = true
            beforeButtonDisabled = true
            return
        }
        if (getNextIndex() ?? 0) > index {
            afterButtonDisabled = false
        } else {
            if isPaginated {
                afterButtonDisabled = false
                didBecameLastIndex?()
            } else {
                afterButtonDisabled = true
            }
        }
        if (getPreviousIndex() ?? 0) < index {
            beforeButtonDisabled = false
        } else {
            beforeButtonDisabled = true
        }
        
        var dif = items.count - index
        if dif > step.value {
            dif = step.value
        }
        displayedItems = Array(items[index..<index + dif])
    }
    
    func updateIndex(_ index: Int? = nil) -> Int? {
        let index = index ?? self.index ?? 0
        guard !items.isEmpty else { return nil }
        let count = items.count
        let dif = count - index
        let update = index - (step.value - dif)
        if dif >= step.value {
            return index
        } else if update <= 0 {
            return 0
        } else {
            return update
        }
    }
    
    func getNextIndex() -> Int? {
        guard !items.isEmpty else { return nil }
        let count = items.count
        let next = (index ?? 0) + step.value
        let dif = count - next
        if dif >= step.value {
            return next
        } else if dif <= 0 {
            return index
        } else {
            return next - (step.value - dif)
        }
    }
    
    func getPreviousIndex() -> Int? {
        guard !items.isEmpty else { return nil }
        let previous = (index ?? 0) - step.value
        if previous <= 0 {
            return 0
        } else {
            return previous
        }
    }
}

@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 400, height: 200)) {
    ChartViewManager(items: ChartDataModel.default)
}
