//
//  STARKLineModel.swift
//  IX
//
//  Created by Wei Jen Wang on 2019/4/18.
//  Copyright © 2019 Wei Jen Wang. All rights reserved.
//

struct CandlesModel: Codable {
    var candleItems: [CandleItems]
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var tempItem: [CandleItems] = []
        
        while !container.isAtEnd {
            let item = try container.decode(CandleItems.self)
            tempItem.append(item)
        }
        
        candleItems = tempItem
    }
}

struct CandleItems: Codable {
    let Close: String
    let High: String
    let Key: String
    let Low: String
    let Open: String
    let Time: String
}
