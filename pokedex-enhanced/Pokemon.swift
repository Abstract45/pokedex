//
//  Pokemon.swift
//  pokedex-enhanced
//
//  Created by Miwand Najafe on 2016-04-17.
//  Copyright © 2016 Miwand Najafe. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
class Pokemon {
    private var _name: String!
    private var _pokedexId:Int!
    private var _description:String!
    private var _type:String!
    private var _defense:String!
    private var _height:String!
    private var _weight:String!
    private var _attack:String!
    private var _nextEvolutionTxt:String!
    private var _pokemonURL: String!
    private var _nextEvolutionId:String!
    private var _nextEvolutionLvl:String!
    var name: String {
        return _name
    }
    var pokedexId:Int {
        return _pokedexId
    }
    var description:String {
        return _description
    }
    var type:String {
        return _type
    }
    var defense:String {
        return _defense
    }
    var height:String {
        return _height
    }
    var weight:String {
        return _weight
    }
    var nextEvolutionTxt:String {
        return _nextEvolutionTxt
    }
    var nextEvolutionId:String {
        return _nextEvolutionId
    }
    var nextEvolutionLvl:String {
        return _nextEvolutionLvl
    }
    var attack:String {
        return _attack
    }
    init(name:String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId
        self._pokemonURL = URL_BASE + URL_POKEMON + "\(self._pokedexId)/"
    }
    func downloadPokemonDetails(complete:DownloadComplete) {
        let url = NSURL(string: self._pokemonURL)!
        print(url)
        Alamofire.request(.GET, url).responseJSON { (response) in
            
            if let results = response.data {
                
                let json = JSON(data: results)
                
                self._weight = json["weight"].stringValue
                self._attack = json["attack"].stringValue
                self._defense = json["defense"].stringValue
                self._height = json["height"].stringValue
                if let types = json["types"].array {
                    var typeCast = ""
                    for type in types.enumerate() {
                        
                        if let t = type.element["name"].string {
                            typeCast += t
                            if type.index == 0 && types.count > 1 {
                                typeCast += "/"
                            }
                        }
                    }
                    self._type = typeCast
                }
                
                let descArray = json["descriptions"].arrayValue
                if let url = NSURL(string:URL_BASE + descArray[0]["resource_uri"].stringValue) {
                    Alamofire.request(.GET, url).responseJSON(completionHandler: { (response) in
                        let results2 = response.data
                        let json2 = JSON(data: results2!)
                        self._description = json2["description"].stringValue
                        complete()
                    })
                }
                let evolutions = json["evolutions"].arrayValue
                if evolutions.count > 0 {
                    if evolutions[0]["to"].stringValue.rangeOfString("mega") == nil {
                        let evoName = evolutions[0]["to"].stringValue
                        let newStr = evolutions[0]["resource_uri"].stringValue.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString: "")
                        let evoImgId = newStr.stringByReplacingOccurrencesOfString("/", withString: "")
                        self._nextEvolutionLvl = evolutions[0]["level"].stringValue
                        self._nextEvolutionId = evoImgId
                        self._nextEvolutionTxt = evoName
                    } else {
                        self._nextEvolutionTxt = ""
                        self._nextEvolutionId = ""
                        self._nextEvolutionLvl = ""
                    }
                } else {
                    self._nextEvolutionTxt = ""
                    self._nextEvolutionId = ""
                    self._nextEvolutionLvl = ""
                }
            }
            
            
        }
    }
}