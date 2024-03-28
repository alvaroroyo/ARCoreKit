//
//  ChartAxisY.swift
//  AR Domotics
//
//  Created by Alvaro Royo on 9/3/24.
//

import SwiftUI

struct ChartAxisYViewModel {
    enum Position {
        case middle
        case whole
    }
    
    var position: Position = .middle
    var value: String
}

@available(iOS 15.0, *)
struct ChartAxisY: View {
    
    var viewModel: ChartAxisYViewModel
    @Binding var maxLineWidth: CGFloat
    
    private var isWhole: Bool { viewModel.position == .whole }
    
    var body: some View {
        HStack(spacing: 0) {
            GeometryReader { lineGeometry in
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                        .frame(width: maxLineWidth, height: 1)
                        .foregroundStyle(Color.gray)
                    Spacer(minLength: 0)
                }.onAppear {
                    maxLineWidth = .minimum(maxLineWidth, lineGeometry.size.width)
                }
            }.frame(width: maxLineWidth)
            
            if viewModel.position == .middle {
                Text(viewModel.value)
                    .font(.system(size: 12))
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0))
                    .foregroundStyle(Color.gray)
                
                Spacer(minLength: 0)
            }
        }.frame(height: 13)
    }
}

@available(iOS 15.0, *)
private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 400, height: 18)) {
    ChartAxisY(viewModel: ChartAxisYViewModel(position: .middle, value: "100€"), maxLineWidth: .constant(.infinity))
}
