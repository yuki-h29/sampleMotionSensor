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
    var defaultTimerCount: Int?
    
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var accelerationX: Double = 0.0
    @Published var accelerationY: Double = 0.0
    @Published var accelerationZ: Double = 0.0
    @Published var combinedAcceleration: Double = 0.0
    @Published var isMoving: Bool = false
    @Published var isMovingCount: Int = 0 // 動いているカウント
    @Published var graphPoints: [Double] = []
    
    private var previousAccelerationX: Double? = nil // 以前のX軸の加速度値
    private var previousAccelerationSum: Double? = nil // 以前のX軸の加速度値
    
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
                    if let previous = self.previousAccelerationSum {
                        let change = abs(acceleration.z - previous) // X軸の変化量
                        self.isMoving = change > 0.3 // 例: 変化量が0.05以上なら「動いている」と判断
                        
                        // 合計加速度をグラフデータに追加
                        self.graphPoints.append(self.accelerationZ)
                        
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
    @Published var timeRemaining: Int = 10
    private var timer: Timer?
    
    // CSVに書き込むデータ
    private var csvData: [String] = []
    // CSVファイルのパス
    private var currentCSVFileURL: URL?
    
    // 移動中に切り替わった時の処理
    func restartMonitoring(timeInterval: Int) {
        
        // 既存のタイマーを無効にする(多重起動防止)
        timer?.invalidate()
        
        // 新しいCSVファイルの作成
        createNewCSVFile()
        
        // 残り時間の初期化
        self.timeRemaining = timeInterval
        
        // タイマーのセットアップ 1秒間隔で呼び出す
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            
            // カウントダウンが0になったときの処理
            if self.timeRemaining <= 0 {
                // CSVデータに追記する
                self.recordData()
                self.timeRemaining = self.defaultTimerCount ?? 10
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
        // エラーチェック Pathの存在
        guard let fileURL = currentCSVFileURL else {
            print("CSVファイルのパスが見つかりませんでした")
            return
        }
        
        // エラーチェック CSV配列データの数(0なら保存しない)
        if csvData.count == 0 {
            return
        }
        
        // データをCSVファイルに追記する
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile() // ファイルの末尾に移動
            let csvLine = csvData.joined(separator: "") // データを一行ずつCSVフォーマットに
            if let data = csvLine.data(using: .utf8) {
                fileHandle.write(data) // データの書き込み
            }
            fileHandle.closeFile()
        } catch {
            print("書き込み中にエラーが発生しました: \(error)")
        }
        
        // データのリセット
        csvData = []
    }
    
    // 停止ボタンを押した時の処理
    func stopMonitoring() {
        // 加速度センサーを停止
        motionManager.stopAccelerometerUpdates()
        
        // タイマーを停止
        timer?.invalidate()
        timer = nil
    }
    
    // GPSデータを書き込む更新タイミングを更新
    func setSelectedTime(minutes: Int, seconds: Int) {
        self.timeRemaining = minutes * 60 + seconds
        // 繰り返す時間を設定
        self.defaultTimerCount = self.timeRemaining
    }
}
