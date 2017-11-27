//
//  main.swift
//  Veilstone
//
//  Created by Nilo on 19/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//
//    renderer.reload()
//    voce: reload
//    eu: mapSize, buildingPXPY, options
//    jogador escolhe
//    eu: didChooseCard
//    voce: atualiza matrix
//    REPETE
//    WISHLIST:  focar camera em: px py


import Foundation

class Veilstone : NSObject{
    
    let renderer = MainRenderer.shared()!
    let joystick = JoystickController()
    var city = City(size: 10)
    var nextPos = (x: 0, y: 0)
    var turns: Int = 5

    
    func run(){
        joystick.delegate = self
        renderer.delegate = self
        
        city.updateInterests()
        city.printInterestMatrix()
        joystick.setup()
        renderer.run(inFullscreen: false, w: 960, h: 600)
        nextSimulation()
    }
    
    func nextSimulation(){
        turns -= 1
        if(turns == 0){
            finishSimulation()
            return
        }
        print("-------------------------------------------------------")
        
        //Criar um criterio pro numero de pessoas
        let persons = Person.randomPersons(number: 10)
        city.newPeopleLogic(persons: persons)
        
        
        renderer.reload()
        nextPos = city.newPos()
        renderer.shouldChooseNextBuilding()
    }
    
    func finishSimulation(){
      city.printStats()
      city.printFinalStats(loops: 5)
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
    
    func currentEnergySupply() -> Float {
        city.servicesStatus()
        return Float(city.energyNeeded) / Float(city.energy)
    }
    
    func currentWaterSupply() -> Float {
        city.servicesStatus()
        return Float(city.waterNeeded) / Float(city.water)
    }
    
    func didChooseCard(withBuildingID bid: Int32) {
        city.newEFromOptions(id: Int(bid), x: nextPos.x, y: nextPos.y)
        city.updateStats()
        city.printMatrix()
        nextSimulation()
    }
    
    func mapSize() -> Int32 {
        return Int32(city.size)
    }
    
    func building(forPX px: Int32, py: Int32) -> Int32 {
        return Int32(city.cityMatrix[Int(px)][Int(py)].buildingID)
    }
    
    func options() -> [NSNumber]! {
        var options:[NSNumber] = []
        for i in city.buildOptions() {
            options.append(NSNumber(integerLiteral: i))
        }
        return options
    }
}

Veilstone().run()
//Veilstone().startSimulation()

