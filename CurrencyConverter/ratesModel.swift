//
//  ratesModel.swift
//  CurrencyConverter
//
//  Created by anilkumar thatha. venkatachalapathy on 6/7/16.
//  Copyright © 2016 Anil T V. All rights reserved.
//

import Foundation

class ratesModel {
    var base: String?
    var date: String?
    var rates: NSDictionary?
    
    init(base: String?, date: String?, rates: NSDictionary?) {
        self.base = base
        self.date = date
        self.rates = rates
    }

}