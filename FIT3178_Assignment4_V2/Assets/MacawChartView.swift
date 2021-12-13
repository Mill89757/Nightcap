//
//  MacawChartView.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 5/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

/**
 Reference:
 
 Youtube Tutorial:
 Title: How To Create a Bar Chart in Swift - Swift 5 - Xcode 10.2
 Author:    Sean Allen
 Link:
    https://www.youtube.com/watch?v=hMyExC9swz8&list=LLUCU7YsO_Fz4r_8crwV8pOA&index=37&t=1448s
    
 Github Link: https://github.com/exyte/Macaw
 
 */


import Foundation
import Macaw

class MacawChartView: MacawView{

    // Used to updated DummyData
    static func updateAnimations(){
        
        MacawChartView.self.lastSevenShows = MacawChartView.createDummyData()
        MacawChartView.self.adjustedData = MacawChartView.lastSevenShows.map({ $0.viewCount * MacawChartView.dataDivisor})
        
        animations = []
        let fill = LinearGradient(degree: 90, from: Color(val: 0x449899), to: Color(val: 0x449899).with(a: 0.33))
        let items = adjustedData.map { _ in Group() }
        
        
        animations = items.enumerated().map { (i: Int, item: Group) in
            item.contentsVar.animation(delay: Double(i) * 0.1) { t in
                let height  = adjustedData[i] * t
                let rect    = Rect(x: Double(i) * 50 + 25, y: 200 - height, w: 30, h: height)
                return [rect.fill(with: fill)]
            }
        }
        
        playAnimations()
    }
    
    static var lastSevenShows           = createDummyData()
    static let maxValue                 = 12
    static let maxValueLineHeight       = 180
    static let lineWidth: Double        = 375
    static let dataDivisor              = Double(maxValueLineHeight/maxValue)
    static var adjustedData: [Double]   = lastSevenShows.map({ $0.viewCount * dataDivisor})
    static var animations: [Animation]  = []
    
    
    
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var databaseController: DatabaseProtocol?
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(node: MacawChartView.createChart(), coder: aDecoder)
        backgroundColor = .clear
    }
    
    
    private static func createChart() -> Group {
        var items: [Node] = addYAxisItems() + addXAxisItems()
        items.append(craeteBars())
    
        return Group(contents: items, place: .identity)
    }
    
    
    private static func addYAxisItems() -> [Node] {
        let maxLines            = 6
        let lineInterval        = Int(maxValue / maxLines)
        let yAxisHeight: Double = 200
        let lineSpacing: Double = 30
        
        var newNodes: [Node] = []
        
        for i in 1...maxLines{
            let y = yAxisHeight - (Double(i) * lineSpacing)
            
            let valueLine   = Line(x1: 0, y1: y, x2: lineWidth, y2: y).stroke(fill: Color.white.with(a: 0.10))
            let valueText   = Text(text: "\(i * lineInterval)", align: .max, baseline: .mid, place: .move(dx: -10, dy: y))
            valueText.fill  = Color.white
            
            newNodes.append(valueLine)
            newNodes.append(valueText)
        }
        
        let yAxis   = Line(x1: 0, y1: 0, x2: 0, y2: yAxisHeight).stroke(fill: Color.white.with(a: 0.25))
        
        newNodes.append(yAxis)
        
        let angle1  = Line(x1: -4, y1: 4, x2: 0, y2: 0).stroke(fill: Color.white.with(a: 0.25))
        let angle2  = Line(x1: 4, y1: 4, x2: 0, y2: 0).stroke(fill: Color.white.with(a: 0.25))
        newNodes.append(angle1)
        newNodes.append(angle2)
        return newNodes
    }
    
    
    private static func addXAxisItems() -> [Node] {
        
        let chartBaseY: Double = 200
        var newNodes: [Node] = []
        
        for i in 1...adjustedData.count {
            let x = (Double(i) * 50)
            let valueText   = Text(text: lastSevenShows[i - 1].showDay, align: .max, baseline: .mid, place: .move(dx: x, dy: chartBaseY + 15))
            valueText.fill  = Color.white
            newNodes.append(valueText)
        }
        
        let xAxis = Line(x1: 0, y1: chartBaseY, x2: lineWidth, y2: chartBaseY).stroke(fill: Color.white.with(a: 0.25))
        newNodes.append(xAxis)
        
        let angle1 = Line(x1: lineWidth - 4, y1: chartBaseY - 4, x2: lineWidth, y2: chartBaseY).stroke(fill: Color.white.with(a: 0.25))
        let angle2 = Line(x1: lineWidth - 4, y1: chartBaseY + 4, x2: lineWidth, y2: chartBaseY).stroke(fill: Color.white.with(a: 0.25))
        newNodes.append(angle1)
        newNodes.append(angle2)
        
        return newNodes
    }
    
    
    private static func craeteBars() -> Group {
        
        let fill = LinearGradient(degree: 90, from: Color(val: 0x449899), to: Color(val: 0x449899).with(a: 0.33))
        let items = adjustedData.map { _ in Group() }
        
        
        animations = items.enumerated().map { (i: Int, item: Group) in
            item.contentsVar.animation(delay: Double(i) * 0.1) { t in
                let height  = adjustedData[i] * t
                let rect    = Rect(x: Double(i) * 50 + 25, y: 200 - height, w: 30, h: height)
                return [rect.fill(with: fill)]
            }
        }
        return items.group()
    }
    
    
    static func playAnimations() {
        
//        lastSevenShows = createDummyData()
//        adjustedData = lastSevenShows.map({ $0.viewCount * dataDivisor})
//
//        let fill = LinearGradient(degree: 90, from: Color(val: 0x449899), to: Color(val: 0x449899).with(a: 0.33))
//        let items = adjustedData.map { _ in Group() }
//
//
//        animations = items.enumerated().map { (i: Int, item: Group) in
//            item.contentsVar.animation(delay: Double(i) * 0.1) { t in
//                let height  = adjustedData[i] * t
//                let rect    = Rect(x: Double(i) * 50 + 25, y: 200 - height, w: 30, h: height)
//                return [rect.fill(with: fill)]
//            }
//        }
        
        animations.combine().play()
    }
    
    
    private static func createDummyData() -> [SwiftNewsVideo] {
        
        let currentUser = appDelegate.user
        print("Mac chart - current user: ", currentUser?.name as Any)
        let dataLength = currentUser?.sleepData.count
        var sleepData: [SleepData] = []

        for i in (1...7).reversed(){
            print("data: ", (currentUser?.sleepData[dataLength! - i])!.durationInSec)
            sleepData.append((currentUser?.sleepData[dataLength! - i])!)
        }
        
        var hours: [Double] = []            // Store sleep time in hours list
        
        let date        = Date()
        let calendar    = Calendar.current
        let currentDay  = calendar.component(.weekday, from: date)
        
        for data in sleepData{
            hours.append(Double(data.durationInSec)/3600.00)
        }
        
        let one    = SwiftNewsVideo(showDay: getDay(num: currentDay - 6), viewCount: hours[0])
        let two    = SwiftNewsVideo(showDay: getDay(num: currentDay - 5), viewCount: hours[1])
        let three  = SwiftNewsVideo(showDay: getDay(num: currentDay - 4), viewCount: hours[2])
        let four   = SwiftNewsVideo(showDay: getDay(num: currentDay - 3), viewCount: hours[3])
        let five   = SwiftNewsVideo(showDay: getDay(num: currentDay - 2), viewCount: hours[4])
        let six    = SwiftNewsVideo(showDay: getDay(num: currentDay - 1), viewCount: hours[5])
        let seven  = SwiftNewsVideo(showDay: getDay(num: currentDay), viewCount: hours[6])
        
        return [one, two, three, four, five, six, seven]
    }
    
    
    private static func getDay(num: Int) -> String{
        var day = num
        if num <= 0 {
            day += 7
        }
        switch day {
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tue"
        case 4:
            return "Wed"
        case 5:
            return "Thu"
        case 6:
            return "Fri"
        case 7:
            return "Sat"
        default:
            return "Error"
        }
    }
}

