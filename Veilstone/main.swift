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
    var turns: Int = 18
    
    let bg = DispatchQueue(label: "bg")
    
    func run(){
        
        joystick.delegate = self
        renderer.delegate = self
        
        city.updateInterests()
        city.printInterestMatrix()
        
        bg.asyncAfter(deadline: .now() + 1.2){
            self.nextSimulation()
        }
        
        joystick.setup()
        renderer.run(inFullscreen: false, w: 960, h: 600)
        
    }
    
    func nextSimulation(){

        turns -= 1
        
        guard turns != 0 else{
            finishSimulation()
            return
        }
        
        print("-------------------------------------------------------")
        
        // Criar um criterio pro numero de pessoas
        let numPersons = 10 + Int(arc4random_uniform(10))
        let persons = Person.randomPersons(number: numPersons)
        city.newPeopleLogic(persons: persons)
        nextPos = city.newPos()
        
        // Atualiza o mapa
        DispatchQueue.main.sync {
            self.renderer.prepareNextRender()
            self.renderer.swapRenders()
        }
        
        // espera nova carta
        renderer.shouldChooseNextBuilding()
    }
    
    func finishSimulation(){
      city.printStats()
      city.servicesStatus()
      city.printFinalStats(loops: 15)
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
        return max(0, min(1, 1 - Float(city.energyNeeded) / Float(city.energy)))
    }
    
    func currentWaterSupply() -> Float {
        return max(0, min(1, 1 - Float(city.waterNeeded) / Float(city.water)))
    }
    
    func didChooseCard(withBuildingID bid: Int32) {
        
        city.newEFromOptions(id: Int(bid), x: nextPos.x, y: nextPos.y)
        city.updateStats()
        city.printMatrix()
        city.printInterestMatrix()
        city.servicesStatus()
        bg.async { self.nextSimulation() }
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

