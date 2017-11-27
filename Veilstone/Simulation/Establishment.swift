//
//  Establishment.swift
//  Veilstone
//
//  Created by José Guilherme de Lima Freitas on 20/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

//1 - Educacao
//2 - Saude
//3 - Cultura
//4 - Segurança
//99 - Energia
//100 - Agua
import Foundation

class Establishment {
    
    //    enum EstablishmentType: Int{
    //        case building = 1, school, hospital, house, energy
    //
    //        func description() -> String{
    //            switch self {
    //            case .building:
    //                return "Prédio"
    //            case .school:
    //                return "Escola"
    //            case .hospital:
    //                return "Hospital"
    //            case .house:
    //                return "Casa"
    //            case .energy:
    //                return "Energia"
    //            }
    //        }
    //    }
    
    var         name: String = ""
    //var         type: EstablishmentType
    var   buildingID: Int = 0
    var     moradias: Int = 0
    var moradiasLeft: Int = 0
    var   cityImpact = [Int]()
    var  waterDemand: Int = 0
    var energyDemand: Int = 0
    //var  residents = [Person]()
    var   relevancia: Int = 0
    var       jobs = [Job]()
    var       classe: Int = 0
    
    init(){}
    init(name: String, id: Int, jobs: Int, moradias: Int, impact: [Int], jdistribution: [Int], water: Int, energy: Int, classe: Int, relevancia: Int){
        self.name = name
        self.buildingID = id
        self.moradias = moradias
        self.moradiasLeft = moradias
        self.cityImpact = impact
        self.jobs = Job.createJobs(with: jdistribution)
        self.waterDemand = water
        self.energyDemand = energy
        self.classe = classe
        self.relevancia = relevancia
    }
}

extension Establishment{
    
    class func parseEstablishments() -> [Establishment]?{
        //Arquivo csv com as informações de cada estabelecimento
        let file = "/csv/establishments.csv"
        var establishments = [Establishment]()
        
        if let csvData = readData(file: file){
            let lines = csvData.components(separatedBy: "\n")
            for (index, line) in lines.enumerated(){
                if index > 0{
                    let values = line.components(separatedBy: ";")
                    establishments.append(create(values: values))
                }
            }
        }else{
            return nil
        }
        
        return establishments
    }
    
    private class func create(values: [String]) -> Establishment{
        let cityImpact = values[4].components(separatedBy: ",").map({return Int($0)!})
        let jobDistribution = values[5].components(separatedBy: ",").map({return Int($0)!})
        
        let newEstablishment = Establishment(name: values[0],
                                             id: Int(values[1])!,
                                             jobs: Int(values[2])!,
                                             moradias: Int(values[3])!,
                                             impact: cityImpact,
                                             jdistribution: jobDistribution,
                                             water: Int(values[6])!,
                                             energy: Int(values[7])!,
                                             classe: Int(values[8])!,
                                             relevancia: Int(values[9])!)
        return newEstablishment
    }
    
    private class func readData(file: String) -> NSString?{
        do{
            return try NSString(contentsOfFile: FileManager.default.currentDirectoryPath + file, encoding: String.Encoding.utf8.rawValue)
        }catch{
            print("Erro ao ler csv de estabelecimentos")
            return nil
        }
    }
}

