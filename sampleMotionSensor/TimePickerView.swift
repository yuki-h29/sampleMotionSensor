//
//  TimePickerView.swift
//  sampleMotionSensor
//
//  Created by 平野裕貴 on 2023/08/02.
//

import Foundation
import SwiftUI

struct TimePickerView: View {
    @Binding var selectedMinutes: Int
        @Binding var selectedSeconds: Int
        @Binding var showingTimePickerModal: Bool
        @ObservedObject var sensorViewModel: SensorViewModel
    
    var body: some View {
        VStack {
            Text("選択時間を設定してください")
            HStack {
                Picker("分:", selection: $selectedMinutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute) 分").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Picker("秒:", selection: $selectedSeconds) {
                    ForEach(0..<60) { second in
                        Text("\(second) 秒").tag(second)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            Button("完了") {
                sensorViewModel.setSelectedTime(minutes: selectedMinutes, seconds: selectedSeconds)
                showingTimePickerModal.toggle()
            }
        }
    }
}
