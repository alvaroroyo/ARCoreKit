//
//  ChartView.swift
//  AR Domotics
//
//  Created by Alvaro Royo on 9/3/24.
//

import SwiftUI

@available(iOS 15.0, *)
public struct ChartView<LoadingView: View, EmptyView: View>: View {
    
    public typealias DidSelectChevrons = () -> ()
    
    private let maxYValue = MaxYValue()
    @State private var maxLineWidth: CGFloat = .infinity
    @State private var selectedBarItem: ChartDataModel.ChartItem? {
        didSet {
            guard let selectedBarItem else { return }
            didSelectItem?(selectedBarItem)
        }
    }
    
    @Binding var items: [ChartDataModel.ChartItem]
    @Binding var numberOfAxisY: ChartDataModel.AxisY
    @Binding var typeAxisY: ChartDataModel.ValueType
    @Binding var afterButtonHidden: Bool
    @Binding var afterButtonDisabled: Bool
    @Binding var beforeButtonHidden: Bool
    @Binding var beforeButtonDisabled: Bool
    @Binding var showLoading: Bool
    @ViewBuilder var loadingView: () -> LoadingView
    @Binding var showEmpty: Bool
    @ViewBuilder var emptyView: () -> EmptyView
    var didSelectAfter: DidSelectChevrons? = nil
    var didSelectBefore: DidSelectChevrons? = nil
    var didSelectItem: ((ChartDataModel.ChartItem) -> ())? = nil
    
    private var framePadding: CGFloat {
        numberOfAxisY.rawValue == 0 ? 48 : (beforeButtonHidden ? 0 : 24)
    }
    
    private var maxValue: Double {
        items.reduce(into: 0) { partialResult, item in
            partialResult = .maximum(partialResult, item.totalValue)
        }
    }
    
    public init(
        items: Binding<[ChartDataModel.ChartItem]>,
        numberOfAxisY: Binding<ChartDataModel.AxisY> = .constant(.five),
        typeAxisY: Binding<ChartDataModel.ValueType> = .constant(.euro),
        afterButtonHidden: Binding<Bool> = .constant(false),
        afterButtonDisabled: Binding<Bool> = .constant(false),
        beforeButtonHidden: Binding<Bool> = .constant(false),
        beforeButtonDisabled: Binding<Bool> = .constant(false),
        showLoading: Binding<Bool> = .constant(false),
        loadingView: @escaping () -> LoadingView = { ProgressView() },
        showEmpty: Binding<Bool> = .constant(false),
        emptyView: @escaping () -> EmptyView = { ZStack {} },
        didSelectAfter: DidSelectChevrons? = nil,
        didSelectBefore: DidSelectChevrons? = nil,
        didSelectItem: ((ChartDataModel.ChartItem) -> Void)? = nil
    ) {
        _items = items
        _numberOfAxisY = numberOfAxisY
        _typeAxisY = typeAxisY
        _afterButtonHidden = afterButtonHidden
        _afterButtonDisabled = afterButtonDisabled
        _beforeButtonHidden = beforeButtonHidden
        _beforeButtonDisabled = beforeButtonDisabled
        _showLoading = showLoading
        self.loadingView = loadingView
        _showEmpty = showEmpty
        self.emptyView = emptyView
        self.didSelectAfter = didSelectAfter
        self.didSelectBefore = didSelectBefore
        self.didSelectItem = didSelectItem
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            if showLoading {
                loadingView()
            } else if showEmpty {
                emptyView()
            } else {
                VStack {
                    VStack {
                        configureYAxis()
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: -5, trailing: 0))
                    
                    Spacer(minLength: 0)
                    
                    chevronsView()
                }
                configureXAxis()
            }
        }
    }
    
    fileprivate func chevronsView() -> some View {
        HStack {
            if !beforeButtonHidden {
                Button(action: {
                    didSelectBefore?()
                }, label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 24, height: 24)
                }).disabled(beforeButtonDisabled)
            }
            
            Spacer()
            
            if !afterButtonHidden {
                Button(action: {
                    didSelectAfter?()
                }, label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 24, height: 24)
                }).disabled(afterButtonDisabled)
            }
        }.frame(height: 30)
    }
}

//MARK: - X Axis
@available(iOS 15.0, *)
private extension ChartView {
    func configureXAxis() -> some View {
        HStack(spacing: 0) {
            let bars = Array(items.enumerated())
            ForEach(bars, id: \.offset) { index, bar in
                ChartAxisX(
                    maxValue: maxYValue.value,
                    item: bar,
                    selectedBarItem: $selectedBarItem,
                    didSelectItem: { didSelectItem?($0) }
                ).frame(width: (maxLineWidth - framePadding) / CGFloat(bars.count))
            }.onAppear {
                if selectedBarItem == nil {
                    selectedBarItem = items.first
                }
            }
        }
        .frame(width: maxLineWidth - framePadding)
        .offset(x: beforeButtonHidden ? 0 : 24)
        
    }
}

//MARK: - Y Axis
@available(iOS 15.0, *)
private extension ChartView {
    func configureYAxis() -> some View {
        VStack {
            let validAxisDivider = numberOfAxisY.rawValue
            if validAxisDivider == 0 {
                let _ = setZeroAxisY()
                VStack {
                    Spacer()
                    ChartAxisY(viewModel: .init(position: .whole, value: ""), maxLineWidth: $maxLineWidth)
                }
            } else {
                let axisY = Array(generateAxisY(validAxisDivider: validAxisDivider).reversed().enumerated())
                VStack {
                    ForEach(axisY, id: \.offset) { index, value in
                        if index > 0 {
                            Spacer()
                        }
                        let value = "\(value)\(typeAxisY.type)"
                        ChartAxisY(viewModel: .init(value: value), maxLineWidth: $maxLineWidth)
                    }
                }
            }
        }
    }
    
    func generateAxisY(validAxisDivider: Int) -> [Int] {
        var multiple: Double
        switch maxValue {
        case let x where x == 0: return generateZeroArray(with: validAxisDivider)
        case let x where x >= 0 && x < 25: multiple = 1
        case let x where x >= 25 && x < 100: multiple = 5
        case let x where x >= 100 && x < 1000: multiple = 10
        default: multiple = 50
        }
        var result = [Int]()
        let factor = round(number: maxValue / Double(validAxisDivider - 1), multiple: multiple)
        for i in 0...(validAxisDivider - 1) {
            let value = factor * i
            result.append(value)
        }
        maxYValue.value = Double(result.last ?? 0)
        return result
    }
    
    func setZeroAxisY() {
        maxYValue.value = maxValue
    }
    
    func generateZeroArray(with divider: Int) -> [Int] {
        var array = [Int]()
        for _ in 0..<divider {
            array.append(0)
        }
        return array
    }
    
    func round(number: Double, multiple: Double) -> Int {
        Int(ceil((number + (multiple / 2)) / multiple) * multiple)
    }
}

//MARK: - MaxYView
@available(iOS 15.0, *)
extension ChartView {
    final class MaxYValue {
        var value: Double = 0.0
    }
}

@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 400, height: 200)) {
    ChartView(
        items: .constant(ChartDataModel.default),
        numberOfAxisY: .constant(.five),
        typeAxisY: .constant(.euro),
        afterButtonHidden: .constant(false),
        afterButtonDisabled: .constant(false),
        beforeButtonHidden: .constant(false),
        beforeButtonDisabled: .constant(false),
        showLoading: .constant(false),
        showEmpty: .constant(false)
    )
}
