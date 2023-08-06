//
//  AccelerationGraph.swift
//  sampleMotionSensor
//
//  Created by 平野裕貴 on 2023/08/03.
//

import SwiftUI

struct AccelerationGraph: View {
    var graphPointsX: [Double]
    var graphPointsY: [Double]
    var graphPointsZ: [Double]
    var graphPointsCombined: [Double]
    
    func generatePath(from points: [Double], in geometry: GeometryProxy) -> Path {
        var path = Path()
        
        guard let maxVal = points.max(), let minVal = points.min() else {
            return path
        }
        
        let verticalAdjustment = (maxVal - minVal) != 0 ? (maxVal - minVal) : 1
        let scale = geometry.size.height / CGFloat(verticalAdjustment)
        
        for (index, point) in points.enumerated() {
            let xPosition = geometry.size.width * CGFloat(index) / CGFloat(points.count)
            let yPosition = geometry.size.height - CGFloat(point - minVal) * scale
            if index == 0 {
                path.move(to: CGPoint(x: xPosition, y: yPosition))
            } else {
                path.addLine(to: CGPoint(x: xPosition, y: yPosition))
            }
        }
        
        return path
    }
    
    var body: some View {
        GeometryReader { geometry in
            generatePath(from: graphPointsX, in: geometry)
                .stroke(Color.blue, lineWidth: 2)
            generatePath(from: graphPointsY, in: geometry)
                .stroke(Color.green, lineWidth: 2)
            generatePath(from: graphPointsZ, in: geometry)
                .stroke(Color.red, lineWidth: 2)
            generatePath(from: graphPointsCombined, in: geometry)
                .stroke(Color.purple, lineWidth: 2)
        }
        .frame(height: 100)
    }
}
