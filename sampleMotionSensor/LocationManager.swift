//
//  LocationManager.swift
//  sampleMotionSensor
//
//  Created by 平野裕貴 on 2023/08/02.
//

import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var csvText = "Latitude,Longitude\n" // CSVのヘッダー

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            csvText += "\(latitude),\(longitude)\n" // 位置情報をCSV形式に追加
        }
    }

    func saveAndExportCSV() {
        // ドキュメントディレクトリへのパスを取得
        let fileName = "locations.csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        do {
            // CSVテキストをファイルに書き込み
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            
            // ファイルを共有するための処理（オプション）
            let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
            UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true, completion: nil)
        } catch {
            print("Failed to write file: \(error)")
        }
    }
}
