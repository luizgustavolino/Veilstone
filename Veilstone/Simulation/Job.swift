//
//  Job.swift
//  Veilstone
//
//  Created by José Guilherme de Lima Freitas on 20/11/17.
//  Copyright © 2017 Nilo. All rights reserved.
//

import Foundation

class Job {
    
    //var employee: Person?
    var employee: Int = -1
    var salary: Double
    var company: Int = 0
    var minSchooling: Person.Schooling
    
    init(minSchooling: Person.Schooling){
        switch minSchooling {
        case .graduate:
            self.salary = 7750 + (Double(arc4random_uniform(10)) * 50)
        case .technical:
            self.salary = 3750 + (Double(arc4random_uniform(10)) * 50)
        case .highSchool:
            self.salary = 1750 + (Double(arc4random_uniform(10)) * 50)
        }
        self.minSchooling = minSchooling
    }
}

extension Job{
    class func createJobs(with d: [Int]) -> [Job]{
        var jobs = [Job]()
        for (index, value) in d.enumerated(){
            for _ in 0..<value{
                jobs.append(Job(minSchooling: Person.Schooling(rawValue: index)!))
            }
        }
        return jobs
    }
}

