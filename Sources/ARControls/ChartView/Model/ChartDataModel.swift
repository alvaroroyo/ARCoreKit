//
//  ChartDataModel.swift
//  AR Domotics
//
//  Created by Alvaro Royo on 10/3/24.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
public struct ChartDataModel {
    public enum AxisY: Int {
        case empty = 0
        case three = 3
        case four = 4
        case five = 5
    }
    
    public enum ValueType {
        case euro
        case percentage
        case custom(String)
        
        var type: String {
            switch self {
            case .euro: return "€"
            case .percentage: return "%"
            case .custom(let type): return type
            }
        }
    }
    
    internal static var `default`: [ChartItem] {
        [
            //Cuotas pasadas .default[0]
            ChartItem(
                axisXTitle: "Agosto 2025",
                values: [
                    //Capital .types[1]
                    ChartItemValue(
                        value: 290,
                        legend: ChartLegendGroup.default[0].types[1]
                    ),
                    //Iteres .types[0]
                    ChartItemValue(
                        value: 90,
                        legend: ChartLegendGroup.default[0].types[0]
                    )
                ]
            ),
            //Cuotas Futuras .default[1]
            ChartItem(
                axisXTitle: "Sep",
                values: [
                    //Capital .types[1]
                    ChartItemValue(
                        value: 120,
                        legend: ChartLegendGroup.default[1].types[1]
                    ),
                    //Interes .types[0]
                    ChartItemValue(
                        value: 30,
                        legend: ChartLegendGroup.default[1].types[0]
                    )
                ]
            ),
            ChartItem(
                axisXTitle: "Oct",
                values: [
                    //Capital .types[1]
                    ChartItemValue(
                        value: 210,
                        legend: ChartLegendGroup.default[1].types[1]
                    ),
                    //Interes .types[0]
                    ChartItemValue(
                        value: 70,
                        legend: ChartLegendGroup.default[1].types[0]
                    )
                ]
            ),
            ChartItem(
                axisXTitle: "Nov",
                values: [
                    //Capital .types[1]
                    ChartItemValue(
                        value: 180,
                        legend: ChartLegendGroup.default[1].types[1]
                    ),
                    //Interes .types[0]
                    ChartItemValue(
                        value: 50,
                        legend: ChartLegendGroup.default[1].types[0]
                    )
                ]
            ),
            ChartItem(
                axisXTitle: "Dec",
                values: [
                    //Capital .types[1]
                    ChartItemValue(
                        value: 170,
                        legend: ChartLegendGroup.default[1].types[1]
                    ),
                    //Interes .types[0]
                    ChartItemValue(
                        value: 30,
                        legend: ChartLegendGroup.default[1].types[0]
                    )
                ]
            ),
        ]
    }
}

@available(iOS 15.0, *)
public extension ChartDataModel {
    struct ChartItem: Equatable, Identifiable {
        public let id = UUID().uuidString
        let axisXTitle: String
        let values: [ChartItemValue]
        
        var totalValue: Double {
            values.reduce(into: 0) { partialResult, value in
                partialResult += value.value
            }
        }
        
        public init(axisXTitle: String, values: [ChartItemValue]) {
            self.axisXTitle = axisXTitle
            self.values = values
        }
        
        public static func == (lhs: ChartItem, rhs: ChartItem) -> Bool {
            lhs.id == rhs.id
        }
    }
}

@available(iOS 15.0, *)
public extension ChartDataModel {
    struct ChartItemValue: Identifiable {
        public let id: String = UUID().uuidString
        let value: Double
        let legend: ChartLegend
        
        public init(value: Double, legend: ChartLegend) {
            self.value = value
            self.legend = legend
        }
    }
}

@available(iOS 15.0, *)
public extension ChartDataModel {
    struct ChartLegendGroup {
        let title: String
        let types: [ChartLegend]
        
        static var `default`: [ChartLegendGroup] {
            [
                ChartLegendGroup(
                    title: "Cuotas Pasadas",
                    types: [
                        ChartLegend(title: "Itereses", color: .blue, type: .lined),
                        ChartLegend(title: "Capital", color: .blue, type: .solid)
                    ]
                ),
                ChartLegendGroup(
                    title: "Cuotas Futuras",
                    types: [
                        ChartLegend(title: "Itereses", color: .gray, type: .lined),
                        ChartLegend(title: "Capital", color: .gray, type: .solid)
                    ]
                )
            ]
        }
        
        public init(title: String, types: [ChartLegend]) {
            self.title = title
            self.types = types
        }
    }
}

@available(iOS 15.0, *)
public extension ChartDataModel {
    struct ChartLegend {
        public enum ChartBarStyle {
            case solid, lined
        }
        
        let title: String
        let color: Color
        let type: ChartBarStyle
        
        public init(title: String, color: Color, type: ChartBarStyle) {
            self.title = title
            self.color = color
            self.type = type
        }
    }
}
