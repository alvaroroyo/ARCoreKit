//
//  ChartAxisX.swift
//  AR Domotics
//
//  Created by Alvaro Royo on 9/3/24.
//

import SwiftUI

@available(iOS 15.0, *)
struct ChartAxisX: View {
    
    var maxValue: Double
    var item: ChartDataModel.ChartItem
    @Binding var selectedBarItem: ChartDataModel.ChartItem?
    
    var didSelectItem: ((ChartDataModel.ChartItem) -> ())? = nil
    
    @State private var offsetAnimate = false
    @State private var stackHeight: CGFloat = 100
    
    private let minimumBarHeigh: CGFloat = 5
    private var isSelected: Bool { selectedBarItem == item }
    
    private var totalPercentage: CGFloat {
        CGFloat(item.totalValue / maxValue)
    }
    
    var body: some View {
        VStack {
            GeometryReader { stackGeometry in
                VStack {
                    Spacer(minLength: 0)
                    GeometryReader { barsGeometry in
                        VStack(spacing: 1) {
                            if maxValue <= 0 || item.totalValue <= 0 {
                                setBarZero()
                            } else {
                                let minimumBarHeighPercentage = minimumBarHeigh / stackGeometry.size.height
                                if totalPercentage < minimumBarHeighPercentage {
                                    setBarZero()
                                } else {
                                    ForEach(Array(item.values.reversed().enumerated()), id: \.offset) { index, value in
                                        let isLast = item.values.count == index + 1
                                        if !isLast {
                                            let percentage = CGFloat(value.value / item.totalValue)
                                            ChartBarView(color: value.legend.color, type: value.legend.type, isSelected: isSelected)
                                                .frame(height: barsGeometry.size.height * percentage)
                                        } else {
                                            ChartBarView(color: value.legend.color, type: value.legend.type, isSelected: isSelected)
                                        }
                                    }
                                }
                            }
                        }
                        .clipShape(BarRoundedCorner(radius: 4, corners: [.topLeft, .topRight]))
                        .offset(y: offsetAnimate ? 0 : stackGeometry.size.height)
                        .clipped()
                        .animation(.easeIn(duration: 0.8), value: offsetAnimate)
                        .onAppear {
                            offsetAnimate.toggle()
                        }
                    }
                    .frame(height: stackHeight)
                    .onAppear {
                        stackHeight = getStackHeigh(with: stackGeometry)
                    }
                }
            }
            .frame(width: 24)
            .clipped()
            
            Spacer().frame(height: 3)
            
            Text(item.axisXTitle)
                .multilineTextAlignment(.center)
                .frame(height: 29)
                .foregroundStyle(isSelected ? Color.black : Color.gray)
                .font(.system(size: 12).bold())
        }.onTapGesture {
            selectedBarItem = item
            didSelectItem?(item)
        }
    }
    
    fileprivate func setBarZero() -> some View {
        return VStack {
            Spacer()
            ChartBarView(color: item.values.first?.legend.color ?? .clear, type: .solid, isSelected: isSelected)
                .frame(height: minimumBarHeigh)
                .clipShape(BarRoundedCorner(radius: 4, corners: [.topLeft, .topRight]))
                .onAppear {
                    stackHeight = 30
                }
        }
    }
    
    fileprivate func getStackHeigh(with geometry: GeometryProxy) -> CGFloat {
        if totalPercentage <= 0 {
            return 30
        } else {
            return geometry.size.height * totalPercentage - 3
        }
    }
}

@available(iOS 15.0, *)
fileprivate struct ChartBarView: View {
    
    var color: Color
    var type: ChartDataModel.ChartLegend.ChartBarStyle
    var isSelected: Bool
    
    private var opacity: CGFloat { isSelected ? 1 : 0.6 }
    
    var body: some View {
        ZStack {
            if type == .lined {
                BarStripes(config:
                            BarStripesConfig(
                                background: color.opacity(0.2),
                                foreground: color.opacity(opacity),
                                degrees: 25,
                                barWidth: 2,
                                barSpacing: 5.5
                            )
                )
            } else {
                color.opacity(opacity)
            }
        }
    }
}

//MARK: - Stripes View
@available(iOS 15.0, *)
fileprivate struct BarStripesConfig {
    var background: Color
    var foreground: Color
    var degrees: Double
    var barWidth: CGFloat
    var barSpacing: CGFloat

    public init(background: Color = Color.pink.opacity(0.5), foreground: Color = Color.pink.opacity(0.8),
                degrees: Double = 30, barWidth: CGFloat = 20, barSpacing: CGFloat = 20) {
        self.background = background
        self.foreground = foreground
        self.degrees = degrees
        self.barWidth = barWidth
        self.barSpacing = barSpacing
    }

    public static let `default` = BarStripesConfig()
}

@available(iOS 15.0, *)
fileprivate struct BarStripes: View {
    var config: BarStripesConfig

    public init(config: BarStripesConfig) {
        self.config = config
    }

    public var body: some View {
        GeometryReader { geometry in
            let longSide = max(geometry.size.width, geometry.size.height)
            let itemWidth = config.barWidth + config.barSpacing
            let items = Int(2 * longSide / itemWidth)
            HStack(spacing: config.barSpacing) {
                ForEach(0..<items, id: \.self) { index in
                    config.foreground
                        .frame(width: config.barWidth, height: 2 * longSide)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .rotationEffect(Angle(degrees: config.degrees), anchor: .center)
            .offset(x: -longSide / 2, y: -longSide / 2)
            .background(config.background)
        }
        .clipped()
    }
}

//MARK: - Rounded Corner Extension
@available(iOS 15.0, *)
fileprivate struct BarRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

//MARK: - Preview
@available(iOS 15.0, *)
private enum ChartAxisXTest {
    case testDefault
    case maxValueZero
    case barValueZero
    case barValueLess
    
    var view: some View {
        switch self {
        case .testDefault: ChartAxisX(maxValue: 400, item: ChartDataModel.default[0], selectedBarItem: .constant(nil))
        case .maxValueZero: ChartAxisX(maxValue: 0, item: ChartDataModel.default[0], selectedBarItem: .constant(nil))
        case .barValueZero:
            ChartAxisX(
                maxValue: 50,
                item: ChartDataModel.ChartItem(
                    axisXTitle: "Aug",
                    values: [
                        .init(value: 0, legend: .init(title: "", color: .blue, type: .lined))
                    ]
                ),
                selectedBarItem: .constant(nil)
            )
        case .barValueLess:
            ChartAxisX(
                maxValue: 50,
                item: ChartDataModel.ChartItem(
                    axisXTitle: "Aug",
                    values: [
                        .init(value: 0.01, legend: .init(title: "", color: .blue, type: .lined))
                    ]
                ),
                selectedBarItem: .constant(nil)
            )
        }
    }
}

@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 110, height: 374)) {
    ChartAxisXTest.testDefault.view
}
