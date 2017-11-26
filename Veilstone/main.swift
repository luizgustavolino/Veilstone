//
//  main.swift
//  Veilstone
//
//  Created by Nilo on 19/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

import Foundation

class Veilstone : NSObject{
    
    let renderer = MainRenderer()
    let joystick = JoystickController()
    
    let size = 30
    var matrix:[[Int]] = []
    
    func run(){
        
        let itens = [10,11,12]
        
        for _ in 1...size{
            var innerMatrix:[Int] = []
            for _ in 1...size{
                let item = Int(itens[Int(arc4random())%itens.count])
                innerMatrix.append(item)
            }
            matrix.append(innerMatrix)
        }
        
        joystick.delegate = self
        renderer.delegate = self
        
        joystick.setup()
        renderer.run(inFullscreen: true, w: 1440/2, h: 900/2)
    }
}

extension Veilstone : JoystickControllerDelegate {
    
    func controllerDidInput(_ code: Int32) {
        print("got code", code)
    }
    
    func analogDidChange(_ code: Int32, value: Double) {
        
    }
}

extension Veilstone : MainRendererDelegate {
    
    func mapSize() -> Int32 {
        return Int32(size)
    }
    
    func building(forPX px: Int32, py: Int32) -> Int32 {
        return Int32(matrix[Int(px)][Int(py)])
    }
}

Veilstone().run()

