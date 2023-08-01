//
//  LocationViewModel.swift
//  sampleMotionSensor
//
//  Created by 平野裕貴 on 2023/08/01.
//

import Foundation
import CoreLocation
import CoreMotion

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
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
}
