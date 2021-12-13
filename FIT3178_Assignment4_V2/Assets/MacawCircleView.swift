//
//  MacawCircleView.swift
//  FIT3178_Assignment4_V2
//
//  Created by Yushu Guo on 8/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

/**
 Reference:
 
 Github Link:   https://github.com/exyte/Macaw
 
 */


import Foundation
import Macaw

class MacawCircleView: MacawView {
    
    private var animationGroup = Group()
    
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    private var animations = [Animation]()
    private let backgroundColors = [
        0.2,
        0.14,
        0.07
        ].map {
            Color.rgba(r: 255, g: 255, b: 255, a: $0)
    }
    
    
    private let gradientColors = [
//        (top: 0xfc087e, bottom: 0xff6868),
//        (top: 0x06dfed, bottom: 0x03aafe)c,
//        (top: 0xffff5c, bottom: 0xffa170)
        (top: 0x10375c, bottom: 0x07192b),
        (top: 0x844685, bottom: 0x512b52),
        (top: 0xf3c263, bottom: 0xb8961a)
    ].map {
        LinearGradient(
            degree: 90,
            from: Color(val: $0.top),
            to: Color(val: $0.bottom)
        )
    }
    
    // three circle represent:
    // From outside to insid
    //  Reperesnet the fall alsleep speed dependon how many times app dectect
    //  Represent the needed sleep time to achieve healthy sleep goal
    //  Represent the sleep time    = default - 10.00 pm
    
    private var extent:[Double] = []                    // Will be updated when user weak up
    
    
    private let r = [
        64.0,
        44.0,
        24.0
    ]
    
    // prepare fot the back ground circle
    private func createArc(_ t: Double, _ i: Int) -> Shape {
        return Shape(
            form: Arc(
                ellipse: Ellipse(cx: 100, cy: 75, rx: self.r[i], ry: self.r[i]),
                shift: 5.0,
                extent: self.extent[i] * t),
            stroke: Stroke(
                fill: gradientColors[i],
                width: 19,
                cap: .round
            )
        )
    }
    
    
    private func createScene() {

        /*
        let text = Text(
            text: "Daily Summary",
            font: Font(name: "Serif", size: 24),
            fill: Color(val: 0xFFFFFF)
        )
        text.align = .mid
        text.place = .move(dx: viewCenterX, dy: 30)*/
        
        let rootNode = Group(place: .move(dx: 0, dy: 0))
        
        for i in 0...2 {
            let circle = Shape(
                form: Circle(cx: 100, cy: 75, r: r[i]),
                stroke: Stroke(fill: backgroundColors[i], width: 19)
            )
            rootNode.contents.append(circle)
        }
        
        animationGroup = Group()
        rootNode.contents.append(animationGroup)
        
        let promptText = Text(text: "Turning off unnecessary \nlights is a prerequisite for \na good sleep", align: .max, baseline: .mid, place: .move(dx: 360, dy: 70))
        
        promptText.fill = Color.white
        
        rootNode.contents.append(promptText)
        
        self.node = [rootNode].group()
        self.backgroundColor = UIColor.darkGray
    }
    
    
    private func createAnimations() {
        animations.removeAll()
        animations.append(
            animationGroup.contentsVar.animation({ t in
                var shapes1: [Shape] = []
                for i in 0...2 {
                    shapes1.append(self.createArc(t, i))
                }
                return  shapes1
            }, during: 1).easing(Easing.easeInOut)
        )
    }
    
    
    public func updateCircle(newExtent: [Double]) {
        self.extent = newExtent
    }
    
    
    open func play() {
        createScene()
        createAnimations()
        animations.forEach {
            $0.play()
        }
    }
}
