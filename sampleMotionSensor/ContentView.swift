//
//  ContentView.swift
//  sampleMotionSensor
//
//  Created by 平野裕貴 on 2023/08/01.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sensorViewModel = SensorViewModel()

    var body: some View {
        VStack {
            Text("緯度: \(sensorViewModel.latitude)")
            Text("経度: \(sensorViewModel.longitude)")
            Text("加速度 X: \(sensorViewModel.accelerationX)") // 加速度X
            Text("加速度 Y: \(sensorViewModel.accelerationY)") // 加速度Y
            Text("加速度 Z: \(sensorViewModel.accelerationZ)") // 加速度Z
            Text("合計加速度 XYZ: \(sensorViewModel.combinedAcceleration)") // 3つの値を掛けた合計加速度
            Text("状態: \(sensorViewModel.isMoving ? "動いている" : "止まっている")")
        }
        .onAppear {
            sensorViewModel.requestLocationPermission()
            sensorViewModel.startMonitoring()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
