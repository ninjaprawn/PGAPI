//
//  PGoAPI.swift
//  PokemonGoAPI
//
//  Created by George Dan on 28/07/2016.
//  Copyright © 2016 ninjaprawn. All rights reserved.
//

import Foundation
import Alamofire
import ProtocolBuffers

class PGoAPI {
	
	private var apiurl = ""
	private var auth = RequestEnvelop.AuthInfo.Builder()
	var userLat: Double = 0.0
	var userLong: Double = 0.0
	
	func loginGoogle(email: String, password: String, callback: ((error: NSError?) -> Void)) {
		
		AuthGoogle.sharedAuthenticator.login(email, password: password, callback: { data, error in
			if let error = error {
				callback(error: error)
				return
			}
			
			let api_url = "https://pgorelease.nianticlabs.com/plfe/rpc"
			
			// AUTH
			let auth = RequestEnvelop.AuthInfo.Builder()
			auth.provider = "google"
			let authToken = RequestEnvelop.AuthInfo.Jwt.Builder()
			authToken.contents = data!
			authToken.unknown13 = 59
			auth.token = try! authToken.build()
			
			// Requests ARRAY
			let req1 = RequestEnvelop.Requests.Builder()
			req1.types = 2
			let req2 = RequestEnvelop.Requests.Builder()
			req2.types = 126
			let req3 = RequestEnvelop.Requests.Builder()
			req3.types = 4
			let req4 = RequestEnvelop.Requests.Builder()
			req4.types = 129
			let req5 = RequestEnvelop.Requests.Builder()
			req5.types = 5
			
			// REQUEST
			let req = RequestEnvelop.Builder()
			req.unknown1 = 2
			req.rpcId = 1469378659230941192
			
			req.requests = [try! req1.build(), try! req2.build(), try! req3.build(), try! req4.build(), try! req5.build()]
			
			req.latitude = self.userLat
			req.longitude = self.userLong
			req.altitude = 0.0
			
			req.auth = try! auth.build()
			self.auth = auth
			req.unknown12 = 989
			
			let finalReq = try! req.build()
			
			
			let headers = [
				"User-Agent": "Niantic App"
			]
			
			Alamofire.request(.POST, api_url, parameters: [:], encoding: .Custom({convertible, params in
				let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
				mutableRequest.HTTPBody = finalReq.data()
				return (mutableRequest, nil)
			}), headers: headers).responseData { response in
				switch response.result {
				case .Success:
					
					if response.response!.statusCode >= 400 {
						
						print("Error!")
						print(String(data: response.data!, encoding: NSUTF8StringEncoding))
						return
					}
					let resp = try! ResponseEnvelop.parseFromData(response.result.value!)
					
					let apiURL = resp.apiUrl
					self.apiurl = "https://\(apiURL)/rpc"
					
					callback(error: nil)
					
				case .Failure(let error):
					print(error)
					callback(error: error)
				}
			}
			
		})
		
	}
	
	func loginPTC(username: String, password: String, callback: ((error: NSError?) -> Void)) {
		
		AuthPTC.sharedAuthenticator.beginAuthPTC(username, password: password, handler: { data in
			//			if let error = error {
			//				callback(error: error)
			//				return
			//			}
			
			
			let api_url = "https://pgorelease.nianticlabs.com/plfe/rpc"
			
			// AUTH
			let auth = RequestEnvelop.AuthInfo.Builder()
			auth.provider = "ptc"
			let authToken = RequestEnvelop.AuthInfo.Jwt.Builder()
			authToken.contents = data
			authToken.unknown13 = 59
			auth.token = try! authToken.build()
			
			// Requests ARRAY
			let req1 = RequestEnvelop.Requests.Builder()
			req1.types = 2
			let req2 = RequestEnvelop.Requests.Builder()
			req2.types = 126
			let req3 = RequestEnvelop.Requests.Builder()
			req3.types = 4
			let req4 = RequestEnvelop.Requests.Builder()
			req4.types = 129
			let req5 = RequestEnvelop.Requests.Builder()
			req5.types = 5
			
			// REQUEST
			let req = RequestEnvelop.Builder()
			req.unknown1 = 2
			req.rpcId = 1469378659230941192
			
			req.requests = [try! req1.build(), try! req2.build(), try! req3.build(), try! req4.build(), try! req5.build()]
			
			req.latitude = self.userLat
			req.longitude = self.userLong
			req.altitude
				= 0.0
			
			req.auth = try! auth.build()
			self.auth = auth
			req.unknown12 = 989
			
			let finalReq = try! req.build()
			
			
			let headers = [
				"User-Agent": "Niantic App"
			]
			
			Alamofire.request(.POST, api_url, parameters: [:], encoding: .Custom({convertible, params in
				let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
				mutableRequest.HTTPBody = finalReq.data()
				return (mutableRequest, nil)
			}), headers: headers).responseData { response in
				switch response.result {
				case .Success:
					
					if response.response!.statusCode >= 400 {
						
						print("Error!")
						print(String(data: response.data!, encoding: NSUTF8StringEncoding))
						return
					}
					let resp = try! ResponseEnvelop.parseFromData(response.result.value!)
					
					let apiURL = resp.apiUrl
					self.apiurl = "https://\(apiURL)/rpc"
					
					callback(error: nil)
					
				case .Failure(let error):
					print(error)
					callback(error: error)
				}
			}
			
		})
		
	}
	
	func getProfile(callback: ((data: ResponseEnvelop.Profile?, error: NSError?) -> Void)) {
		
		let headers = [
			"User-Agent": "Niantic App"
		]
		
		let profileRequest = RequestEnvelop.Requests.Builder()
		profileRequest.types = 2
		
		let mainRequest = RequestEnvelop.Builder()
		mainRequest.unknown1 = 2
		mainRequest.rpcId = 1469378659230941192
		
		mainRequest.requests = [try! profileRequest.build()]
		
		mainRequest.latitude = self.userLat
		mainRequest.longitude = self.userLong
		mainRequest.altitude = 0.0
		
		mainRequest.auth = try! self.auth.build()
		mainRequest.unknown12 = 989
		
		let finalRequest = try! mainRequest.build()
		
		
		Alamofire.request(.POST, self.apiurl, parameters: [:], encoding: .Custom({convertible, params in
			let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
			mutableRequest.HTTPBody = finalRequest.data()
			return (mutableRequest, nil)
		}), headers: headers).responseData { response in
			switch response.result {
			case .Success:
				
				if response.response!.statusCode >= 400 {
					
					print("Error!")
					print(String(data: response.data!, encoding: NSUTF8StringEncoding))
					return
				}
				let resp2 = try! ResponseEnvelop.parseFromData(response.data!)
				
				if resp2.payload.count > 0 {
					callback(data: try! ResponseEnvelop.ProfilePayload.parseFromData(resp2.payload[0]).profile, error: nil)
				} else {
					print(resp2)
				}
				
			case .Failure(let error):
				callback(data: nil, error: error)
			}
		}
	}
	
	func getInventory(callback: ((data: [ResponseEnvelop.InventoryItem]?, error: NSError?) -> Void)) {
		
		let headers = [
			"User-Agent": "Niantic App"
		]
		
		let profileRequest = RequestEnvelop.Requests.Builder()
		profileRequest.types = 4
		
		let mainRequest = RequestEnvelop.Builder()
		mainRequest.unknown1 = 2
		mainRequest.rpcId = 1469378659230941192
		
		mainRequest.requests = [try! profileRequest.build()]
		
		mainRequest.latitude = self.userLat
		mainRequest.longitude = self.userLong
		mainRequest.altitude = 0.0
		
		mainRequest.auth = try! self.auth.build()
		mainRequest.unknown12 = 989
		
		let finalRequest = try! mainRequest.build()
		
		
		Alamofire.request(.POST, self.apiurl, parameters: [:], encoding: .Custom({convertible, params in
			let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
			mutableRequest.HTTPBody = finalRequest.data()
			return (mutableRequest, nil)
		}), headers: headers).responseData { response in
			switch response.result {
			case .Success:
				
				if response.response!.statusCode >= 400 {
					
					print("Error!")
					print(String(data: response.data!, encoding: NSUTF8StringEncoding))
					return
				}
				let resp2 = try! ResponseEnvelop.parseFromData(response.data!)
				
				do {
					//print(resp2)
					if resp2.payload.count > 0 {
						callback(data: try ResponseEnvelop.GetInventoryResponse.parseFromData(resp2.payload[0]).inventoryDelta.inventoryItems, error: nil)
					} else {
						print(resp2)
					}
					
				} catch (let error) {
					print(error)
					//print(error)
					//callback(data: nil, error: NSError(domain: "memes", code: 0, userInfo: nil)
				}
				
				
				
			case .Failure(let error):
				callback(data: nil, error: error)
			}
		}
	}
	
	func heartBeat(callback: ((data: [ResponseEnvelop.ClientMapCell]?, error: NSError?) -> Void)) {
		
		
		let nullBytes = [Int64](count: 21, repeatedValue: 0)
		
		let lat = self.userLat
		let long = self.userLong
		
		let origin = S2CellId(latlng: S2LatLng(latDegrees: lat, lngDegrees: long))
		var cells: [UInt64] = []
		
		var currentCell = origin
		for _ in 0..<10 {
			currentCell = currentCell.prev()
			cells.insert(UInt64(currentCell.id), atIndex: 0)
		}
		
		cells.append(UInt64(origin.id))
		
		currentCell = origin
		for _ in 0..<10 {
			currentCell = currentCell.next()
			cells.append(UInt64(currentCell.id))
		}
		
		let walk = cells.sort({ $0 > $1 })
		
		let walkData = RequestEnvelop.MessageQuad.Builder()
		walkData.f1 = walk
		walkData.f2 = nullBytes
		walkData.lat = lat
		walkData.long = long
		
		let req1 = RequestEnvelop.Requests.Builder()
		req1.types = 106
		req1.message_ = (try! walkData.build()).data()
		
		let req2 = RequestEnvelop.Requests.Builder()
		req2.types = 126
		
		let req3 = RequestEnvelop.Requests.Builder()
		req3.types = 4
		let date = RequestEnvelop.Unknown3.Builder()
		date.unknown4 = String(NSDate().timeIntervalSince1970)
		req3.message_ = (try! date.build()).data()
		
		let req4 = RequestEnvelop.Requests.Builder()
		req4.types = 129
		
		let req5 = RequestEnvelop.Requests.Builder()
		req5.types = 5
		let key = RequestEnvelop.Unknown3.Builder()
		key.unknown4 = "05daf51635c82611d1aac95c0b051d3ec088a930"
		req5.message_ = (try! key.build()).data()
		
		
		let headers = [
			"User-Agent": "Niantic App"
		]
		
		let mainRequest = RequestEnvelop.Builder()
		mainRequest.unknown1 = 2
		mainRequest.rpcId = 1469378659230941192
		
		mainRequest.requests = [try! req1.build(), try! req2.build(), try! req3.build(), try! req4.build(), try! req5.build()]
		
		mainRequest.latitude = lat
		mainRequest.longitude = long
		mainRequest.altitude = 0.0
		
		mainRequest.auth = try! self.auth.build()
		mainRequest.unknown12 = 989
		
		let finalRequest = try! mainRequest.build()
		
		
		Alamofire.request(.POST, self.apiurl, parameters: [:], encoding: .Custom({convertible, params in
			let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
			mutableRequest.HTTPBody = finalRequest.data()
			return (mutableRequest, nil)
		}), headers: headers).responseData { response in
			switch response.result {
			case .Success:
				
				if response.response!.statusCode >= 400 {
					
					print("Error!")
					print(String(data: response.data!, encoding: NSUTF8StringEncoding))
					return
				}
				let resp2 = try! ResponseEnvelop.parseFromData(response.data!)
				
				if resp2.payload.count > 0 {
					callback(data: try! ResponseEnvelop.HeartbeatPayload.parseFromData(resp2.payload[0]).cells, error: nil)
				} else {
					print(resp2)
				}
				
				
			case .Failure(let error):
				callback(data: nil, error: error)
			}
		}
		
	}
	
	func getFort(id: String, lat: Double, long: Double, callback: ((data: ResponseEnvelop.FortSearchResponse?, error: NSError?) -> Void)) {
		
		let headers = [
			"User-Agent": "Niantic App"
		]
		
		let fortSearch = RequestEnvelop.FortSearchMessage.Builder()
		fortSearch.fortId = id
		fortSearch.playerLatitude = self.userLat
		fortSearch.playerLongitude = self.userLong
		fortSearch.fortLatitude = lat
		fortSearch.fortLongitude = long
		
		let fortRequest = RequestEnvelop.Requests.Builder()
		fortRequest.types = 2
		fortRequest.message_ = (try! fortSearch.build()).data()
		
		let mainRequest = RequestEnvelop.Builder()
		mainRequest.unknown1 = 2
		mainRequest.rpcId = 1469378659230941192
		
		mainRequest.requests = [try! fortRequest.build()]
		
		mainRequest.latitude = self.userLat
		mainRequest.longitude = self.userLong
		mainRequest.altitude = 0.0
		
		mainRequest.auth = try! self.auth.build()
		mainRequest.unknown12 = 989
		
		let finalRequest = try! mainRequest.build()
		
		
		Alamofire.request(.POST, self.apiurl, parameters: [:], encoding: .Custom({convertible, params in
			let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
			mutableRequest.HTTPBody = finalRequest.data()
			return (mutableRequest, nil)
		}), headers: headers).responseData { response in
			switch response.result {
			case .Success:
				
				if response.response!.statusCode >= 400 {
					print("Error!")
					print(String(data: response.data!, encoding: NSUTF8StringEncoding))
					return
				}
				let resp2 = try! ResponseEnvelop.parseFromData(response.data!)
				
				callback(data: try! ResponseEnvelop.FortSearchResponse.parseFromData(resp2.payload[0]), error: nil)
				
			case .Failure(let error):
				callback(data: nil, error: error)
			}
		}
		
		
	}
	
	func getFortsDetails(forts: [ResponseEnvelop.PokemonFortProto], callback: ((data: [(details: ResponseEnvelop.FortDetailsResponse, originalFort: ResponseEnvelop.PokemonFortProto)]?, error: NSError?) -> Void)) {
		
		let headers = [
			"User-Agent": "Niantic App"
		]
		
		var reqs: [RequestEnvelop.Requests] = []
		
		for fort in forts {
			
			let fortDetails = RequestEnvelop.FortDetailsRequest.Builder()
			fortDetails.fortId = fort.fortId
			fortDetails.fortLatitude = fort.latitude
			fortDetails.fortLongitude = fort.longitude
			
			let fortRequest = RequestEnvelop.Requests.Builder()
			fortRequest.types = 104
			fortRequest.message_ = (try! fortDetails.build()).data()
			
			reqs.append(try! fortRequest.build())
			
		}
		
		
		let mainRequest = RequestEnvelop.Builder()
		mainRequest.unknown1 = 2
		mainRequest.rpcId = 1469378659230941192
		
		mainRequest.requests = reqs
		
		mainRequest.latitude = self.userLat
		mainRequest.longitude = self.userLong
		mainRequest.altitude = 0.0
		
		mainRequest.auth = try! self.auth.build()
		mainRequest.unknown12 = 989
		
		let finalRequest = try! mainRequest.build()
		
		
		Alamofire.request(.POST, self.apiurl, parameters: [:], encoding: .Custom({convertible, params in
			let mutableRequest = convertible.URLRequest.copy() as! NSMutableURLRequest
			mutableRequest.HTTPBody = finalRequest.data()
			return (mutableRequest, nil)
		}), headers: headers).responseData { response in
			switch response.result {
			case .Success:
				
				if response.response!.statusCode >= 400 {
					print("Error!")
					print(String(data: response.data!, encoding: NSUTF8StringEncoding))
					return
				}
				let resp2 = try! ResponseEnvelop.parseFromData(response.data!)
				
				if resp2.payload.count > 0 {
					
					var fortDetails: [(details: ResponseEnvelop.FortDetailsResponse, originalFort: ResponseEnvelop.PokemonFortProto)] = []
					for (i,p) in resp2.payload.enumerate() {
						fortDetails.append((try! ResponseEnvelop.FortDetailsResponse.parseFromData(p), forts[i]))
					}
					callback(data: fortDetails, error: nil)
					
				} else {
					
					print("getFortDetails: \(resp2)")
				}
				
			case .Failure(let error):
				callback(data: nil, error: error)
			}
		}
		
		
	}
	
	
}