//
//  WeatherViewController.swift
//  Weather
//
//  Created by Nathan Lambson on 11/26/16.
//  Copyright © 2016 Nathan Lambson. All rights reserved.
//

import Foundation
import UIKit


class WeatherViewController: UIViewController, JBLineChartViewDataSource, JBLineChartViewDelegate, WeatherSnapshotDataSource {
    
    @IBOutlet weak var aView: UIView!
    let networkManager = NetworkingManager.sharedInstance
    var snapshots = [WeatherSnapshot]()
    let chartView = JBLineChartView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chartView.dataSource = self
        chartView.delegate = self
        chartView.showsLineSelection = true
        chartView.showsVerticalSelection = true
        
        view.addSubview(chartView)
        view.backgroundColor = UIColor(patternImage: UIImage(named: "cloudPattern")!)
        
        networkManager.weatherDelegate = self
        networkManager.beginPollingCurrentWeather()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = view.bounds
        gradientLayer.backgroundColor = UIColor(red:0.49, green:0.68, blue:0.71, alpha:0.5).cgColor
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        let buffer: CGFloat = 20.0
        let chartHeight = (view.frame.height / 3) - buffer * 2
        let y = view.frame.height - chartHeight - buffer * 2
        chartView.frame = CGRect(x: buffer, y: y, width: view.frame.width - buffer * 2, height: chartHeight)
        view.bringSubview(toFront: chartView)
        chartView.reloadData()
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
        
        switch(lineIndex) {
            case 0:
                let value = snapshots[Int(horizontalIndex)].temperature
                print("Temperature: \(value)")
                break
            case 1:
                let value = snapshots[Int(horizontalIndex)].precipProbability * 100
                print("Chance of Precipitation: \(value)")
                break
            case 2:
                let value = snapshots[Int(horizontalIndex)].humidity * 100
                print("Humidity: \(value)")
            case 3:
                let value = snapshots[Int(horizontalIndex)].windSpeed
                print("Wind speed: \(value)")
            case 4:
                let value = snapshots[Int(horizontalIndex)].cloudCover * 100
                print("Cloud Cover: \(value)")
            default:
                break
        }
        
//        [self.informationView setValueText:[NSString stringWithFormat:@"%.2f", [valueNumber floatValue]] unitText:kJBStringLabelMm];
//        [self.informationView setTitleText:lineIndex == JBLineChartLineSolid ? kJBStringLabelMetropolitanAverage : kJBStringLabelNationalAverage];
//        [self.informationView setHidden:NO animated:YES];
//        [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
//        [self.tooltipView setText:[[self.daysOfWeek objectAtIndex:horizontalIndex] uppercaseString]];

    }
    
    func didDeselectLine(in lineChartView: JBLineChartView!) {
        print("hide the things")
    }
    
    
    func lineChartView(_ lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }

    func lineChartView(_ lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }

    func lineChartView(_ lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(8.0)
    }
    
    
    // horizontal index 0: Temperature
    // 1: Chance of Precipitation
    // 2: humidity
    // 3: wind speed
    // 4: cloud cover
    func lineChartView(_ lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        switch(lineIndex) {
        case 0:
            return UIColor.red.withAlphaComponent(0.7)
        case 1:
            return UIColor.blue.withAlphaComponent(0.7)
        case 2:
            return UIColor.green.withAlphaComponent(0.7)
        case 3:
            return UIColor.lightGray.withAlphaComponent(0.7)
        case 4:
            return UIColor.darkGray.withAlphaComponent(0.7)
        default:
            break
        }
        
        return UIColor.brown.withAlphaComponent(0.7)
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        switch(lineIndex) {
        case 0:
            return UIColor.red
        case 1:
            return UIColor.blue
        case 2:
            return UIColor.green
        case 3:
            return UIColor.lightGray
        case 4:
            return UIColor.darkGray
        default:
            break
        }
        
        return UIColor.brown
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, dotRadiusForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(5.0)
    }
    
//
//    func lineChartView(_ lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
//        
//    }
//    
//    func lineChartView(_ lineChartView: JBLineChartView!, gradientForLineAtLineIndex lineIndex: UInt) -> CAGradientLayer! {
//        
//    }
//    
////    func lineChartView(_ lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
////        
////    }
//    
//    func lineChartView(_ lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
//        
//    }
//    
//    func lineChartView(_ lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
//        
//    }
//    
//    func lineChartView(_ lineChartView: JBLineChartView!, selectionColorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
//        
//    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, lineStyleForLineAtLineIndex lineIndex: UInt) -> JBLineChartViewLineStyle {
        return JBLineChartViewLineStyle.dashed
    }
    

    
    //MARK: WeatherSnapshotDataSource
    func next(latest: WeatherSnapshot) {
        if(snapshots.last?.time != latest.time || snapshots.count == 0) {
            snapshots.append(latest)
            chartView.reloadData()
            print(snapshots)
            print("=================================================")
        } else {
            print("================Already Exists===================")
        }
    }
    
}
