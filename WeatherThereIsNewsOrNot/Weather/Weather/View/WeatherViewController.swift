//
//  WeatherViewController.swift
//  Weather
//
//  Created by Nathan Lambson on 11/26/16.
//  Copyright © 2016 Nathan Lambson. All rights reserved.
//

import Foundation
import UIKit


class WeatherViewController: UIViewController, JBLineChartViewDataSource, JBLineChartViewDelegate, WeatherDataSource {
    
    @IBOutlet weak var aView: UIView!
    let networkManager = NetworkingManager.sharedInstance
    var snapshots = [WeatherSnapshot]()
    var futureSnapshots = [MinuteForecast]()
    let chartView = JBLineChartView.init()
    let orderedColors: [UIColor] = [UIColor.red, UIColor.blue, UIColor.green, UIColor.purple, UIColor.darkGray]
    let orderedImageViews: [UIView] = [UIImageView(image:UIImage(named: "temperature")!),
                                       UIImageView(image:UIImage(named: "precipitation")!),
                                       UIImageView(image:UIImage(named: "humidity")!),
                                       UIImageView(image:UIImage(named: "windSpeed")!),
                                       UIImageView(image:UIImage(named: "cloudCover")!)]

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
        let chartHeight = (view.frame.height / 2) - buffer * 2
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
        //TODO if it is in the future do something to the circleView to be less prominent
        
        if (horizontalIndex > 0 && Int(horizontalIndex) < snapshots.count - 1) {
            let circleView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            circleView.asCircle()
            circleView.alpha = 0.8
            circleView.backgroundColor = orderedColors[Int(lineIndex)]
            return circleView
        }
        
        return orderedImageViews[Int(lineIndex)]
    }
    
    func lineChartView(_ lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return orderedColors[Int(lineIndex)]
    }

    func lineChartView(_ lineChartView: JBLineChartView!, selectionColorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return orderedColors[Int(lineIndex)]
    }

    
    func lineChartView(_ lineChartView: JBLineChartView!, lineStyleForLineAtLineIndex lineIndex: UInt) -> JBLineChartViewLineStyle {
        //TODO if it is in the future, make the line dashed
        
        return JBLineChartViewLineStyle.solid
    }
    
    //MARK: WeatherDataSource
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
    
    func future(minutely: [MinuteForecast]) {
        futureSnapshots = minutely
        chartView.reloadData()
    }
}

extension UIView{
    func asCircle(){
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
    }
}
