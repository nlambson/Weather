//
//  WeatherViewController.swift
//  Weather
//
//  Created by Nathan Lambson on 11/26/16.
//  Copyright © 2016 Nathan Lambson. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class WeatherViewController: UIViewController, JBLineChartViewDataSource, JBLineChartViewDelegate, WeatherDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var temperatureImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var precipitationImageView: UIImageView!
    @IBOutlet weak var precipitationLabel: UILabel!
    
    @IBOutlet weak var humidityImageView: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var windSpeedImageView: UIImageView!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var cloudCoverImageView: UIImageView!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    
    let networkManager = NetworkingManager.sharedInstance
    var snapshots = [WeatherSnapshot]()
    var futureSnapshots = [MinuteForecast]()
    var locationManager: CLLocationManager!
    let chartView = JBLineChartView.init()
    
    let orderedColors: [UIColor] = [UIColor(red:0.79, green:0.11, blue:0.09, alpha:1.00),
                                    UIColor(red:0.12, green:0.61, blue:0.97, alpha:1.00),
                                    UIColor(red:0.26, green:0.35, blue:0.76, alpha:1.00),
                                    UIColor(red:0.56, green:0.58, blue:0.91, alpha:1.00),
                                    UIColor(red:0.20, green:0.31, blue:0.33, alpha:1.00)]
    let orderedImageViews: [UIView] = [UIImageView(image:UIImage(named: "temperature")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)),
                                       UIImageView(image:UIImage(named: "precipitation")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)),
                                       UIImageView(image:UIImage(named: "humidity")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)),
                                       UIImageView(image:UIImage(named: "windSpeed")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)),
                                       UIImageView(image:UIImage(named: "cloudCover")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        chartView.dataSource = self
        chartView.delegate = self
        chartView.showsLineSelection = true
        chartView.showsVerticalSelection = true
        
        view.addSubview(chartView)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "cloudPattern")!)
        
        temperatureImageView.image = temperatureImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        temperatureImageView.tintColor = orderedColors[0]
        precipitationImageView.image = precipitationImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        precipitationImageView.tintColor = orderedColors[1]
        humidityImageView.image = humidityImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        humidityImageView.tintColor = orderedColors[2]
        windSpeedImageView.image = windSpeedImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        windSpeedImageView.tintColor = orderedColors[3]
        cloudCoverImageView.image = cloudCoverImageView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cloudCoverImageView.tintColor = orderedColors[4]
        
        networkManager.weatherDelegate = self
        networkManager.beginPollingCurrentWeather()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let bleachLayer = CAGradientLayer.init()
        bleachLayer.frame = view.bounds
        bleachLayer.backgroundColor = UIColor.white.withAlphaComponent(0.7).cgColor
        view.layer.insertSublayer(bleachLayer, at: 0)
        
        let buffer: CGFloat = 20.0
        let chartHeight = (view.frame.height / 2) - buffer * 2
        let y = view.frame.height - chartHeight - buffer * 2
        chartView.frame = CGRect(x: buffer, y: y, width: view.frame.width - buffer * 2, height: chartHeight)
        view.bringSubview(toFront: chartView)
        chartView.reloadData()
    }
    
    func updateView(for current: WeatherSnapshot) {
        let date = Date(timeIntervalSince1970: TimeInterval(current.time))
        let dayPeriodFormatter = DateFormatter()
        let timePeriodFormatter = DateFormatter()
        dayPeriodFormatter.dateFormat = "MMM dd YYYY"
        timePeriodFormatter.dateFormat = "hh:mm a"
        dateLabel.text = dayPeriodFormatter.string(from: date)
        timeLabel.text = timePeriodFormatter.string(from: date)
        temperatureLabel.text = String(format: "%.0f°F", current.temperature)
        precipitationLabel.text = String(format: "%.0f%%", current.precipProbability * 100)
        humidityLabel.text = String(format: "%.0f%%", current.humidity * 100)
        windSpeedLabel.text = String(format: "%.0fmph", current.windSpeed)
        cloudCoverLabel.text = String(format: "%.0f%%", current.cloudCover * 100)
    }
    
    //MARK: JBLineChartViewDataSource
    func numberOfLines(in lineChartView: JBLineChartView!) -> UInt {
        return 5
    }
    
    
    func lineChartView(_ lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(snapshots.count)
    }
    
    //MARK: JBLineChartViewDelegate
    // horizontal index 0: Temperature
    // 1: Chance of Precipitation
    // 2: humidity
    // 3: wind speed
    // 4: cloud cover
    
    func lineChartView(_ lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        
        switch(lineIndex) {
            case 0:
                return CGFloat(snapshots[Int(horizontalIndex)].temperature)
            case 1:
                return CGFloat(snapshots[Int(horizontalIndex)].precipProbability * 100)
            case 2:
                return CGFloat(snapshots[Int(horizontalIndex)].humidity * 100)
            case 3:
                return CGFloat(snapshots[Int(horizontalIndex)].windSpeed)
            case 4:
                return CGFloat(snapshots[Int(horizontalIndex)].cloudCover * 100)
            default:
                break
        }
        
        return 0
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, didSelectLineAt lineIndex: UInt, horizontalIndex: UInt) {
        updateView(for: snapshots[Int(horizontalIndex)])
    }
    
    func didDeselectLine(in lineChartView: JBLineChartView!) {
        updateView(for: snapshots[snapshots.count - 1])
    }
    

    func lineChartView(_ lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }

    func lineChartView(_ lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(4.0)
    }
    
    
    // horizontal index 0: Temperature
    // 1: Chance of Precipitation
    // 2: humidity
    // 3: wind speed
    // 4: cloud cover
    func lineChartView(_ lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return orderedColors[Int(lineIndex)].withAlphaComponent(0.7)
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, dotViewAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIView! {
        //TODO consider adding future predictions, make a visible change showing it is different and less prominent
        
        if (horizontalIndex > 0 && Int(horizontalIndex) < snapshots.count - 1) {
            let circleView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            circleView.asCircle()
            circleView.alpha = 0.8
            circleView.backgroundColor = orderedColors[Int(lineIndex)]
            return circleView
        }
        
        let image = orderedImageViews[Int(lineIndex)]
        image.tintColor = orderedColors[Int(lineIndex)]
        return image
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return orderedColors[Int(lineIndex)]
    }

    func lineChartView(_ lineChartView: JBLineChartView!, selectionColorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return orderedColors[Int(lineIndex)]
    }

    
    func lineChartView(_ lineChartView: JBLineChartView!, lineStyleForLineAtLineIndex lineIndex: UInt) -> JBLineChartViewLineStyle {
        //TODO If you implement future predicitions, make the future line dashed. Unfortunately only precip chance is available from minutely forecast
        
        return JBLineChartViewLineStyle.solid
    }
    
    //MARK: WeatherDataSource
    func next(current: WeatherSnapshot, minutely: [MinuteForecast]) {
        if(snapshots.last?.time != current.time || snapshots.count == 0) {
            if snapshots.count > 15 {
                snapshots.remove(at: snapshots.count - 1)
            }
            
            snapshots.append(current)
            futureSnapshots = minutely
            chartView.reloadData()

            updateView(for: current)
        } else {
            print("================Already Exists===================")
        }
    }
   
    //MARK: LocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        
        let firstTime = networkManager.lat == 0 && networkManager.long == 0
        
        networkManager.lat = CGFloat(userLocation.coordinate.latitude)
        networkManager.long = CGFloat(userLocation.coordinate.longitude)
        
        if firstTime {
            networkManager.getCurrentWeather()
        }
        
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            if (error != nil) {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if let pm = placemarks?[0] {
                self.title = "\(pm.locality!), \(pm.administrativeArea!)"
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
}

extension UIView{
    func asCircle(){
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
    }
}
