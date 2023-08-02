//
//  ContentView.swift
//  sampleMotionSensor
//
//  Created by 平野裕貴 on 2023/08/01.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sensorViewModel = SensorViewModel()
    
    // 分と秒の選択用の変数
    @State private var selectedMinutes: Int = 0
    @State private var selectedSeconds: Int = 0
    @State private var showingTimePickerModal: Bool = false
    
    
    var body: some View {
        VStack(spacing: 10) {
            // 上部: 緯度、経度表示
            VStack {
                Text("緯度: \(sensorViewModel.latitude)")
                    .padding(.top, 50) // 上部から50ポイントのスペースを取る
                Text("経度: \(sensorViewModel.longitude)")
                
                // 残り時間を表示
                Text("残り時間: \(sensorViewModel.timeRemaining) 秒")
                    .onTapGesture {
                        showingTimePickerModal.toggle()
                    }
                    .sheet(isPresented: $showingTimePickerModal) {
                        TimePickerView(selectedMinutes: $selectedMinutes, selectedSeconds: $selectedSeconds, showingTimePickerModal: $showingTimePickerModal, sensorViewModel: sensorViewModel)
                    }
            }
            .onAppear {
                sensorViewModel.requestLocationPermission()
            }
            .padding()
            
            // 中断: 加速度と状態表示
            VStack {
                Text("加速度 X: \(sensorViewModel.accelerationX)") // 加速度X
                    .padding(.top, 50) // 上部から50ポイントのスペースを取る
                Text("加速度 Y: \(sensorViewModel.accelerationY)") // 加速度Y
                Text("加速度 Z: \(sensorViewModel.accelerationZ)") // 加速度Z
                Text("合計加速度 XYZ: \(sensorViewModel.combinedAcceleration)") // 3つの値を掛けた合計加速度
                Text("状態: \(sensorViewModel.isMoving ? "動いている" : "止まっている")")
                
                if sensorViewModel.isMovingCount >= 20 {
                    movingText
                        .onAppear {
                            // 移動中になった際のタイマーの起動処理
                            let timeInterval = selectedMinutes * 60 + selectedSeconds
                            sensorViewModel.restartMonitoring(timeInterval: timeInterval)
                            // CSVファイルを作成する
                            sensorViewModel.createNewCSVFile()
                        }
                } else {
                    stationaryText
                }
            }
            
            .padding(.bottom, 10) // 下部との間隔を調整
            
            HStack {
                // 停止ボタン
                Button("停止") {
                    // センサーとタイマーを停止
                    sensorViewModel.stopMonitoring()
                    // モーションセンサーカウントを0へ　自動で停車中に戻る
                    sensorViewModel.isMovingCount = 0
                    // CSVファイルを記録する
                    sensorViewModel.recordData()
                    // CSVファイルを保存する
                    sensorViewModel.saveToCSV()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
                
                // 発車待機ボタン
                Button("発車待機") {
                    
                    sensorViewModel.startMonitoring() // センサーの監視を開始
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            .padding() // 画面全体の間隔を調整
        }
    }
    
    private var movingText: some View {
        Text("移動中")
            .font(.largeTitle)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .padding(.top, 50)
    }
}

private var stationaryText: some View {
    
    
    Text("停車中")
        .font(.largeTitle)
        .padding() // テキストの周りにパディングを追加
        .background(Color.blue) // 背景色を青に
        .foregroundColor(.white) // 文字色を白に
        .padding(.top, 50) // 上部から50ポイントのスペースを取る
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
