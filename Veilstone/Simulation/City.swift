//
//  City.swift
//  Veilstone
//
//  Created by José Guilherme de Lima Freitas on 25/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

import Foundation

typealias PosTuple = (x: Int, y: Int, establishment: Establishment)

struct Node{
    var buildingID: Int = 0
    var interest: Int = 0
    var establishmentIndex: Int = -1
    
    init(){
        let random = Int(arc4random_uniform(10))
        if random > 8{
            buildingID = 1
        }
    }
}

struct City{
    var cityMatrix: [[Node]]
    var size: Int
    var water: Int = 0
    var energy: Int = 0
    var energyNeeded: Int = 0
    var waterNeeded: Int = 0
    var establishments = [Establishment]()
    var persons = [Person]()
    private var availables = [Establishment]()
    private var selectables = [Establishment]()
    private var nextEIndex: Int = 0
    private var nextPIndex: Int = 0
    private let energyID: Int = 12
    private let waterID: Int = 13
    private let energyIncrease: Int = 25
    private let waterIncrease: Int = 25
    private var notFoundJob: Int = 0
    private var noEnergy: Int = 0
    private var noWater: Int = 0
    
    private var educacao: Double = 0
    private var educacaoPoints: Double = 0
    private var saude: Double = 0
    private var saudePoints: Double = 0
    private var cultura: Double = 0
    private var culturaPoints: Double = 0
    private var seguranca: Double = 0
    private var segurancaPoints: Double = 0
    private let peso: Double = 0.6
    
    init(size: Int){
        self.size = size
        availables = Establishment.parseEstablishments()!
        for avaiable in availables{
            if avaiable.relevancia != 0{
                selectables.append(avaiable)
            }
        }
        var matrix = [[Node]]()
        var initialConfig = City.readConfig(availables)
        var actual: Int = 0
        
        for x in 0...size{
            var line = [Node]()
            for y in 0...size{
                var node = Node()
                let tuple = initialConfig[actual % initialConfig.count]
                
                if(tuple.x == x && tuple.y == y){
                    establishments.append(tuple.establishment)
                    node.establishmentIndex = nextEIndex
                    node.buildingID = tuple.establishment.buildingID
                    energyNeeded += tuple.establishment.energyDemand
                    waterNeeded += tuple.establishment.waterDemand
                    
                    if(tuple.establishment.buildingID == energyID){
                        energy += energyIncrease
                    }else if(tuple.establishment.buildingID == waterID){
                        water += waterIncrease
                    }
                    
                    //print(tuple.establishment.relevancia)
                    switch tuple.establishment.relevancia {
                    case 1:
                        educacaoPoints += peso
                    case 2:
                        saudePoints += peso
                    case 5:
                        culturaPoints += peso
                    case 6:
                        segurancaPoints += peso
                    default:
                        print("nao atualizou relevancias: \(tuple.establishment.relevancia)")
                    }
                    
                    nextEIndex += 1
                    actual += 1
                }
                line.append(node)
            }
            matrix.append(line)
        }
        self.cityMatrix = matrix
    }
    
    func printMatrix(){
        print()
        for indexi in 0..<self.size{
            let line = cityMatrix[indexi]
            for indexj in 0..<self.size{
                let node = line[indexj]
                print(node.buildingID, terminator: " ")
            }
            print()
        }
    }
    
    func printInterestMatrix(){
        print()
        for indexi in 0..<self.size{
            let line = cityMatrix[indexi]
            for indexj in 0..<self.size{
                let node = line[indexj]
                if(node.establishmentIndex == -1){
                    print(node.interest, terminator: " ")
                }else{
                    print("x", terminator: " ")
                }
            }
            print()
        }
    }
    
    mutating func updateInterests(){
        let range: Int = 3
        for x in 0..<self.size{
            for y in 0..<self.size{
                let node = cityMatrix[x][y]
                if node.establishmentIndex != -1{
                    var rangex: [Int] = [x-range, x+range]
                    var rangey: [Int] = [y-range, y+range]
                    
                    if(rangex[0] < 0){
                        rangex[0] = 0
                    }
                    if(rangex[1] >= self.size){
                        rangex[1] = self.size - 1
                    }
                    if(rangey[0] < 0){
                        rangey[0] = 0
                    }
                    if(rangey[1] >= self.size){
                        rangey[1] = self.size - 1
                    }
                    
                    for posX in rangex[0]...rangex[1]{
                        for posY in rangey[0]...rangey[1]{
                            if !(posX == x && posY == y){
                                let distance: Double = sqrt(pow(Double(posX - x), 2) + pow(Double(posY - y), 2))
                                
                                if distance <= Double(establishments[node.establishmentIndex].cityImpact.count){
                                    self.cityMatrix[posX][posY].interest += establishments[node.establishmentIndex].cityImpact[Int(lround(distance - 1))]
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    mutating func updateInterests(x: Int, y: Int){
        let range: Int = 3
        let node = cityMatrix[x][y]
        
        var rangex: [Int] = [x-range, x+range]
        var rangey: [Int] = [y-range, y+range]
        
        if(rangex[0] < 0){
            rangex[0] = 0
        }
        if(rangex[1] >= self.size){
            rangex[1] = self.size - 1
        }
        if(rangey[0] < 0){
            rangey[0] = 0
        }
        if(rangey[1] >= self.size){
            rangey[1] = self.size - 1
        }
        
        for posX in rangex[0]...rangex[1]{
            for posY in rangey[0]...rangey[1]{
                if !(posX == x && posY == y){
                    let distance: Double = sqrt(pow(Double(posX - x), 2) + pow(Double(posY - y), 2))
                    
                    if distance <= Double(establishments[node.establishmentIndex].cityImpact.count){
                        self.cityMatrix[posX][posY].interest += establishments[node.establishmentIndex].cityImpact[Int(lround(distance - 1))]
                        
                    }
                }
            }
        }
    }
    
    
    mutating func newPeopleLogic(persons: [Person]){
        var newCitizens = [Person]()
        var faltas: [Int] = [0,0,0]
        for person in persons{
            if self.lookForJob(person: person){
                newCitizens.append(person)
            }
        }
        
        var withoutHome = [Person]()
        for citizen in newCitizens{
            if (!self.lookForHome(person: citizen)){
                withoutHome.append(citizen)
                faltas[citizen.schooling.rawValue] += 1
            }
        }
        
        print()
        var index = faltas.count
        //        for (index, falta) in faltas.enumerated(){
        //            if falta != 0{
        //                print("Prefeito, \(falta) pessoas de classe: \(Person.Schooling(rawValue: index)!.description()) não conseguiram lugar pra morar")
        //                let e = self.goodHome(numPessoas: falta, classe: index + 1)
        //                let position = newEPos(classe: index + 1)
        //                self.newEstablishment(establishment: e, posX: position.0, posY: position.1)
        //                print("Construído: \(e.name), que tem \(e.moradias) moradias!")
        //            }
        //        }
        
        while(index > 0){
            let falta = faltas[index - 1]
            if falta != 0{
                print("Prefeito, \(falta) pessoas de classe: \(Person.Schooling(rawValue: index - 1)!.description()) não conseguiram lugar pra morar")
                let e = self.goodHome(numPessoas: falta, classe: index)
                let position = newEPos(classe: index)
                self.newEstablishment(establishment: e, posX: position.0, posY: position.1)
                print("Construído: \(e.name), que tem \(e.moradias) moradias!")
            }
            index -= 1
        }
        
        for person in withoutHome{
            _ = self.lookForHome(person: person)
        }
    }
    
    func servicesStatus(){
        print()
        print("A cidade tem \(energy) pontos de energia e \(water) pontos de água")
        print("A cidade precisa de \(energyNeeded) pontos de energia e \(waterNeeded) pontos de água")
        print()
    }
    
    private func newEPos(classe: Int) -> (Int, Int){
        
        let center = (Int(self.size/2), Int(self.size/2))
        var returnValue = (Int(arc4random_uniform(UInt32(self.size))), Int(arc4random_uniform(UInt32(self.size))))
        
        var actualDistance: Double = 1000
        var distance: Double = 0
        var interest: Int = 0
        
        for x in 0..<self.size{
            for y in 0..<self.size{
                let node = cityMatrix[x][y]
                if(node.establishmentIndex == -1){
                    if classe == 1 && node.interest < 0{
                        distance = sqrt(pow(Double(center.0 - x), 2) + pow(Double(center.1 - y), 2))
                        if(distance < actualDistance){
                            returnValue = (x, y)
                            actualDistance = distance
                            interest = node.interest
                        }
                        
                        if(node.interest < interest){
                            returnValue = (x, y)
                            actualDistance = distance
                            interest = node.interest
                        }
                    }else if(classe == 2 && (node.interest > 0  && node.interest <= 2)){
                        distance = sqrt(pow(Double(center.0 - x), 2) + pow(Double(center.1 - y), 2))
                        if(distance < actualDistance){
                            returnValue = (x, y)
                            actualDistance = distance
                        }
                    }else if(classe == 3 && node.interest > 2){
                        distance = sqrt(pow(Double(center.0 - x), 2) + pow(Double(center.1 - y), 2))
                        if(distance < actualDistance){
                            returnValue = (x, y)
                            actualDistance = distance
                            interest = node.interest
                        }
                        
                        if(node.interest > interest){
                            returnValue = (x, y)
                            actualDistance = distance
                            interest = node.interest
                        }
                    }
                }
            }
        }
        return returnValue
    }
    
    mutating func newEFromOptions(id: Int, x: Int, y: Int){
        let est = makeCopy(e: selectables[id])
        print("Escolhido e construído: \(est.name) em \(x,y)")
        newEstablishment(establishment: est, posX: x, posY: y)
    }
    
    func newPos() -> (x: Int, y: Int){
        var returnValue = (0,0)
        let center = (Int(self.size/2), Int(self.size/2))
        var betterDistance: Double = 1000
        for x in 0..<self.size{
            for y in 0..<self.size{
                let node = cityMatrix[x][y]
                if(node.establishmentIndex == -1){
                    let distance = sqrt(pow(Double(center.0 - x), 2) + pow(Double(center.1 - y), 2))
                    
                    if(distance < betterDistance){
                        betterDistance = distance
                        returnValue = (x,y)
                    }
                }
            }
        }
        
        return returnValue
    }
    
    func impactName(id: Int) -> String{
        //1 - Educacao
        //2 - Saude
        //3 - Energia
        //4 - Agua
        //5 - Cultura
        //6 - Segurança
        
        switch id {
        case 1:
            return "Educação"
        case 2:
            return "Saúde"
        case 3:
            return "Energia"
        case 4:
            return "Água"
        case 5:
            return "Cultura"
        case 6:
            return "Segurança"
        default:
            return "Deu ruim ao escolher impacto"
        }
    }
    
    mutating func buildOptions() -> [Int]{
        print("Você pode escolher entre: ")
        
        var returnValue = [Int]()
        //let energyIDSelectable = 3
        //let waterIDSelectable = 4
        
        if(energyNeeded > energy){
//            for (index, selectable) in selectables.enumerated(){
//                if(selectable.relevancia == energyIDSelectable){
//                    print("Acabou a infra de energia, você só pode construir a \(selectable.name)")
//                    returnValue.append(index)
//                    return returnValue
//                }
//            }
            noEnergy += 1
            print("Acabou a infra de energia!")
        }
        if(waterNeeded > water){
//            for (index, selectable) in selectables.enumerated(){
//                if(selectable.relevancia == waterIDSelectable){
//                    print("Cabou a infra de água mané, você só pode construir a \(selectable.name)")
//                    returnValue.append(index)
//                    return returnValue
//                }
//            }
            noWater += 1
            print("Acabou a infra de água!")
        }
        
        for (index, selectable) in selectables.enumerated(){
            print("\(selectable.name), que vai melhorar a cidade em: \(impactName(id: selectable.relevancia))")
            //if !(selectable.relevancia == waterIDSelectable || selectable.relevancia == energyIDSelectable){
            returnValue.append(index)
            //}
        }
   
        return returnValue
    }
    
    mutating func newEstablishment(establishment: Establishment, posX: Int, posY: Int){
        let est = makeCopy(e: establishment)
        establishments.append(est)
        cityMatrix[posX][posY].buildingID = est.buildingID
        cityMatrix[posX][posY].establishmentIndex = nextEIndex
        energyNeeded += est.energyDemand
        waterNeeded += est.waterDemand
        
        if(est.buildingID == energyID){
            energy += energyIncrease
        }else if(est.buildingID == waterID){
            water += waterIncrease
        }
        nextEIndex += 1
        updateRelevancia(id: est.relevancia)
        updateInterests(x: posX, y: posY)
    }
    
    mutating func lookForJob(person: Person) -> Bool{
        for (index, establishment) in establishments.enumerated(){
            for job in establishment.jobs{
                if person.schooling.rawValue == job.minSchooling.rawValue && job.employee == -1{
                    
                    job.employee = nextPIndex
                    nextPIndex += 1
                    job.company = index
                    person.job = job
                    persons.append(person)
                    
                    print("\(person.name) começou a trabalhar em trabalhar em \(establishment.name), recebendo R$ \(job.salary) com \(job.minSchooling.description())")
                    return true
                }
            }
        }
        print("\(person.name) não achou um lugar para trabalhar")
        notFoundJob += 1
        return false
    }
    
    func lookForHome(person: Person) -> Bool{
        for (index, establishment) in establishments.enumerated(){
            if establishment.moradias > 0 && person.schooling.rawValue == (establishment.classe - 1){
                if establishment.moradiasLeft > 0{
                    person.moradia = index
                    establishment.moradiasLeft -= 1
                    print("\(person.name) começou a morar no \(establishment.name)")
                    return true
                }
            }
        }
        print("\(person.name) não arranjou lugar pra morar")
        return false
    }
    
    func goodHome(numPessoas: Int, classe: Int) -> Establishment{
        for establishment in availables{
            if(establishment.moradias >= numPessoas && establishment.classe == classe){
                return establishment
            }
        }
        return availables[0]
    }
    
    func jobStatus(){
        print("\n\n")
        
        print("PESSOAS")
        for person in persons{
            print("\(person.name), \(person.schooling.description()), está trabalhando em \(establishments[person.job.company].name), recebendo R$ \(person.job.salary)")
        }
        
        print()
        
        print("EMPRESAS")
        for establishment in establishments{
            for job in establishment.jobs{
                var funcionario: String = ""
                if(job.employee == -1){
                    funcionario = "está livre"
                }else{
                    funcionario = persons[job.employee].name
                }
                print("Empresa: \(establishment.name), emprego com necessidade de: \(job.minSchooling.description()), salário: \(job.salary), funcionário: \(funcionario)")
            }
        }
        print("\n\n")
    }
    
    func homeStatus(){
        print()
        print("PESSOAS")
        for person in persons{
            if person.moradia != -1{
                print("\(person.name), é \(person.schooling.description()) e mora em: \(establishments[person.moradia].name)")
            }
        }
        
        print()
        print("MORADIA")
        for establishment in establishments{
            if(establishment.moradias != 0){
                print("\(establishment.name) tem \(establishment.moradiasLeft) moradias disponíveis!")
            }
        }
    }
    
    func makeCopy(e: Establishment) -> Establishment {
        let newE = Establishment()
        newE.name = e.name
        newE.buildingID = e.buildingID
        newE.cityImpact = e.cityImpact
        newE.energyDemand = e.energyDemand
        newE.waterDemand = e.waterDemand
        var newJobs = [Job]()
        for job in e.jobs{
            let newJob = Job(minSchooling: job.minSchooling)
            newJobs.append(newJob)
        }
        newE.jobs = newJobs
        newE.moradias = e.moradias
        newE.classe = e.classe
        newE.moradiasLeft = e.moradias
        newE.relevancia = e.relevancia
        return newE
    }
    
    
    mutating func updateStats(){
        educacao += educacaoPoints
        saude += saudePoints
        cultura += culturaPoints
        seguranca += segurancaPoints
    }
    
    func printStats(){
        print("Educacao: \(educacao), Saude: \(saude), Cultura: \(cultura), Seguranca: \(seguranca)")
        //print("Desejado para todos: \(loop)")
    }
    
    func printFinalStats(loops: Double){
        
        let pib: Double = calcularPIB()
        let rendaCapta: Double = pib / Double(persons.count)
        let numEmpregos: Int = calcularEmpregos()
        
        var finalEducacao = (1 - (educacao/loops)) * 100
        if finalEducacao < 0 {
            finalEducacao = 0
        }
        
        var finalSaude = (1 - (saude/loops)) * 100
        if finalSaude < 0 {
            finalSaude = 0
        }
        
        var finalCultura = (1 - (cultura/loops)) * 100
        if finalCultura < 0 {
            finalCultura = 0
        }
        
        var finalSeguranca = (1 - (seguranca/loops)) * 100
        if finalSeguranca < 0 {
            finalSeguranca = 0
        }
        print("---------------------------------------------------------")
        print()
        print("Relatório Final \n")
        print("\(finalEducacao) % das pessoas ficaram insatisfeitas com a Educacao durante seu mandato")
        print("\(finalSaude) % das pessoas ficaram insatisfeitas com a Saude durante seu mandato")
        print("\(finalCultura) % das pessoas ficaram insatisfeitas com a Cultura durante seu mandato")
        print("\(finalSeguranca) % das pessoas ficaram insatisfeitas com a Seguranca durante seu mandato")
        print("Número de pessoas: \(persons.count)")
        print("Número de construções: \(establishments.count)")
        print("Número de pessoas que não conseguiram um emprego: \(notFoundJob)")
        
        if noWater > 0{
            print("Durante um certo período no seu mandato, o sistema de água ficou sobrecarregado, gerando quedas no abastecimento: \(noWater)")
        }else{
            print("Sua gestão de água foi excelente!")
        }
        
        
        if noEnergy > 0{
            print("Durante um certo período no seu mandato, o sistema de energia ficou sobrecarregado, gerando apagões: \(noEnergy)")
        }else{
            print("Sua gestão de energia foi excelente!")
        }
        
        print("Sua cidade gerou \(numEmpregos) empregos")
        print("PIB da sua cidade: R$ \(pib)")
        print("Renda per capta: R$ \(rendaCapta)")
        
        var dict = [String: Double]()
        dict.updateValue(finalEducacao, forKey: "educacao")
        dict.updateValue(finalSaude, forKey: "saude")
        dict.updateValue(finalCultura, forKey: "cultura")
        dict.updateValue(finalSeguranca, forKey: "seguranca")
        dict.updateValue(Double(persons.count), forKey: "numPessoas")
        dict.updateValue(Double(establishments.count), forKey: "numConstrucoes")
        dict.updateValue(Double(notFoundJob), forKey: "noJobs")
        
        print()
        print("---------------------------------------------------------")
    }
    
    mutating func updateRelevancia(id: Int){
        //1 - Educacao
        //2 - Saude
        //3 - Energia
        //4 - Agua
        //5 - Cultura
        //6 - Segurança
        switch id {
        case 1:
            educacaoPoints += peso
        case 2:
            saudePoints += peso
        case 5:
            culturaPoints += peso
        case 6:
            segurancaPoints += peso
        default:
            print("nao atualizou relevancias: \(id)")
        }
    }
    
    func calcularPIB() -> Double{
        var salary: Double = 0.0
        
        for person in persons{
            salary += person.job.salary
        }
        
        return salary
    }
    
    func calcularEmpregos() -> Int{
        var numEmpregos: Int = 0
        
        for establishment in establishments{
            numEmpregos += establishment.jobs.count
        }
        
        return numEmpregos
    }
    
    private static func readConfig(_ availables: [Establishment]) -> [PosTuple]{
        func readData(file: String) -> NSString?{
            do{
                return try NSString(contentsOfFile: FileManager.default.currentDirectoryPath + file, encoding: String.Encoding.utf8.rawValue)
            }catch{
                print("Erro ao ler csv de config inicial")
                return nil
            }
        }
        
        func makeCopy(e: Establishment) -> Establishment {
            let newE = Establishment()
            newE.name = e.name
            newE.buildingID = e.buildingID
            newE.cityImpact = e.cityImpact
            newE.energyDemand = e.energyDemand
            newE.waterDemand = e.waterDemand
            var newJobs = [Job]()
            for job in e.jobs{
                let newJob = Job(minSchooling: job.minSchooling)
                newJobs.append(newJob)
            }
            newE.jobs = newJobs
            newE.moradias = e.moradias
            newE.classe = e.classe
            newE.moradiasLeft = e.moradias
            newE.relevancia = e.relevancia
            return newE
        }
        
        func searchEstablishment(_ availables: [Establishment], id: Int) -> Establishment{
            for establishment in availables{
                if(establishment.buildingID == id){
                    
                    return makeCopy(e: establishment)
                }
            }
            return availables[0]
        }
        
        var array = [PosTuple]()
        let file = "/csv/initialConfig.csv"
        if let csvData = readData(file: file){
            let lines = csvData.components(separatedBy: "\n")
            for (index, line) in lines.enumerated(){
                if index > 0{
                    let values = line.components(separatedBy: ";")
                    let tuple = PosTuple(Int(values[1])!, Int(values[2].replacingOccurrences(of: "\r", with: ""))!, searchEstablishment(availables, id: Int(values[0])!))
                    array.append(tuple)
                }
            }
        }
        return array
    }
}

