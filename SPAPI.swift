//
//  SPAPI.swift
//  PokemonGoAPI
//
//  Created by George Dan on 30/07/2016.
//  Copyright © 2016 ninjaprawn. All rights reserved.
//

import Foundation
import Alamofire

struct SPLot {
	var totalNumberOfSpots = 0
	var latitude: Double = 0
	var longitude: Double = 0
	var lotCode = 0
	var name = ""
	
	var taken = 0
	var available = 0
}

class SPAPI {
	
	var apiKey: String
	var siteCode: String
	
	init(apiKey: String, siteCode: String) {
		self.apiKey = apiKey
		self.siteCode = siteCode
	}
	
	func getAllLots(callback: ((lots: [SPLot]?, error: NSError?) -> Void)) {
		
		Alamofire.request(.GET, "https://api.smartparking.com/smartlot/v1/Lots/\(apiKey)/\(siteCode)", headers: ["Content-Type": "application/json"]).responseData { response in
			switch response.result {
			case .Success:
				let json = try! NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [AnyObject]
				
				var lotArray = [SPLot]()
				for lot in json {
					let lotDict = lot as! [String: AnyObject]
					var currentLot = SPLot()
					currentLot.totalNumberOfSpots = lotDict["BayCount"] as! Int
					currentLot.lotCode = Int(lotDict["LotCode"] as! String)!
					currentLot.latitude = lotDict["Latitude"] as! Double
					currentLot.longitude = lotDict["Longitude"] as! Double
					currentLot.name = lotDict["Street"] as! String
					lotArray.append(currentLot)
					
				}
				
				callback(lots: lotArray, error: nil)
				
			case .Failure(let error):
				callback(lots: nil, error: error)
			}
			
			
		}
		
	}
	
	func getOccupancyForLot(lot: SPLot, callback: ((newLot: SPLot?, error: NSError?) -> Void)) {
		
		Alamofire.request(.GET, "https://api.smartparking.com/smartlot/v1/Occupancy/\(apiKey)/\(siteCode)/\(lot.lotCode)", headers: ["Content-Type": "application/json"]).responseData { response in
			switch response.result {
			case .Success:
				let json = try! NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [AnyObject]
				
				let lotOccupancy = json[0] as! [String: Int]
				
				var newLot = lot
				newLot.available = lotOccupancy["Free"]!
				newLot.taken = lotOccupancy["Occupied"]!
				
				callback(newLot: newLot, error: nil)
				
			case .Failure(let error):
				callback(newLot: nil, error: error)
			}
			
			
		}
		
	}
	
	func getOccupanciesForLots(lots: [SPLot], callback: ((newLots: [SPLot]?, error: NSError?) -> Void)) {
		
		var newLots = [SPLot]()
		
		Alamofire.request(.GET, "https://api.smartparking.com/smartlot/v1/Occupancies/\(apiKey)/\(siteCode)", headers: ["Content-Type": "application/json"]).responseData { response in
			switch response.result {
			case .Success:
				let json = try! NSJSONSerialization.JSONObjectWithData(response.data!, options: []) as! [[String: AnyObject]]
				
				for o in json {
					for lot in lots {
						if Int(o["LotCode"] as! String) == lot.lotCode {
							var newLot = lot
							newLot.available = o["Free"] as! Int
							newLot.taken = o["Occupied"] as! Int
							newLots.append(newLot)
						}
					}
				}
				
				callback(newLots: newLots, error: nil)
				
			case .Failure(let error):
				callback(newLots: nil, error: error)
			}
			
			
		}
		
		callback(newLots: newLots, error: nil)
		
	}
	
}