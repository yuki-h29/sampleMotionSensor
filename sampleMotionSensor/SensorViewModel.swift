//
//  LocationViewModel.swift
//  sampleMotionSensor
//
//  Created by 平野裕貴 on 2023/08/01.
//

import Foundation
import CoreMotion
import CoreLocation


class SensorViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var motionManager = CMMotionManager()
    
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var accelerationX: Double = 0.0
    @Published var accelerationY: Double = 0.0
    @Published var accelerationZ: Double = 0.0
    @Published var combinedAcceleration: Double = 0.0
    @Published var isMoving: Bool = false
    @Published var isMovingCount: Int = 0 // 動いているカウント
    
    private var previousAccelerationX: Double? = nil // 以前のX軸の加速度値
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startMonitoring() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let acceleration = data?.acceleration {
                DispatchQueue.main.async {
                    if let previous = self.previousAccelerationX {
                        let change = abs(acceleration.x - previous) // X軸の変化量
                        self.isMoving = change > 0.05 // 例: 変化量が0.05以上なら「動いている」と判断
                    }
                    self.previousAccelerationX = acceleration.x
                    self.accelerationX = acceleration.x
                    self.accelerationY = acceleration.y
                    self.accelerationZ = acceleration.z
                    self.combinedAcceleration = acceleration.x * acceleration.y * acceleration.z // 3つの値を掛けた合計加速度
                    
                    if self.isMoving {
                        self.isMovingCount += 1
                    }
                }
            }
        }
    }
    
    // 動いているFLGのカウント
    func resetMovingCount() {
        isMovingCount = 0
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
    
    // カウントダウンの残り時間
    @Published var timeRemaining: Int = 0
    private var timer: Timer?
    
    // CSVに書き込むデータ
    private var csvData: [String] = []
    
    
    private var currentCSVFileURL: URL?
    
    func restartMonitoring(timeInterval: Int) {
        
        // 既存のタイマーを無効にする
        timer?.invalidate()
        
        // 既存のCSVファイルを保存
        saveToCSV()
        
        // 新しいCSVファイルの作成
        createNewCSVFile()
        
        // 残り時間の初期化
        self.timeRemaining = timeInterval
        
        // タイマーのセットアップ
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            
            if self.timeRemaining <= 0 {
                // カウントダウンが0になったときの処理
                self.recordData()
                self.timeRemaining = 10
            }
        }
    }
    
    // CSVファイルを作成する
    func createNewCSVFile() {
        
        let fileManager = FileManager.default
        let documentsDir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileName = "data-\(Date().timeIntervalSince1970).csv"
        let fileURL = documentsDir.appendingPathComponent(fileName)
        
        // ファイルの作成
        fileManager.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        
        // 新しいURLを設定
        currentCSVFileURL = fileURL
        
        // 既存のデータのクリア
        csvData = []
    }
    
    // CSVデータを追加する
    func recordData() {
        let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .medium)
        let record = "\(dateString), \(latitude), \(longitude)\n"
        csvData.append(record)
    }
    
    // CSVをファイルに保存する
    func saveToCSV() {
        guard let fileURL = currentCSVFileURL else {
            print("No CSV file to write to.")
            return
        }
        
        // データをファイルに追記
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile() // ファイルの末尾に移動
            let csvLine = csvData.joined(separator: "") // データを一行ずつCSVフォーマットに
            if let data = csvLine.data(using: .utf8) {
                fileHandle.write(data) // データの書き込み
            }
            fileHandle.closeFile()
        } catch {
            print("Error writing to file: \(error)")
        }
        
        // データのリセット
        csvData = []
    }
    
    func stopMonitoring() {
        // ここでセンサーの読み取りを停止するコードを書く。
        // 加速度センサーの場合は、通常はCMMotionManagerのstopAccelerometerUpdates()メソッドを使用します。
        motionManager.stopAccelerometerUpdates()
        
        // タイマーを停止します
        timer?.invalidate()
        timer = nil
    }
    
    func setSelectedTime(minutes: Int, seconds: Int) {
        timeRemaining = minutes * 60 + seconds
    }
}
