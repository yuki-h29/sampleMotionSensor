//
//  AccelerationGraph.swift
//  sampleMotionSensor
//
//  Created by 平野裕貴 on 2023/08/03.
//

import SwiftUI

struct AccelerationGraph: View {
    let graphPoints: [Double]

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let scale = geometry.size.height / (graphPoints.max() ?? 1)
                for (index, point) in graphPoints.enumerated() {
                    let xPosition = geometry.size.width * CGFloat(index) / CGFloat(graphPoints.count)
                    let yPosition = geometry.size.height - CGFloat(point) * scale
                    if index == 0 {
                        path.move(to: CGPoint(x: xPosition, y: yPosition))
                    } else {
                        path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
        .frame(height: 100)
    }
}
