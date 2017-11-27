//
//  Person.swift
//  Veilstone
//
//  Created by José Guilherme de Lima Freitas on 20/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

import Foundation

class Person{
    
    enum Schooling: Int{
        case highSchool = 0, technical, graduate
        
        func description() -> String{
            switch self {
            case .graduate:
                return "Graduado"
            case .technical:
                return "Técnico"
            case .highSchool:
                return "Ensino médio"
                
            }
        }
    }
    
    var      name: String
    var schooling: Schooling
    //var   moradia: Establishment?
    var   moradia: Int = -1
    var       job: Job!
    var      live: Bool = true
    
    init(schooling: Int){
        self.name = "LINS"
        self.schooling = Schooling(rawValue: schooling)!
    }
}

extension Person {
    class func randomPersons(number: Int) -> [Person]{
        var returnValue = [Person]()
        
        for _ in 0..<number{
            let newPerson = Person(schooling: Int(arc4random_uniform(3)))
            returnValue.append(newPerson)
        }
        
        return returnValue
    }
}

