//
//  AuthPTC.swift
//  PokemonGoAPI
//
//  Created by George Dan on 29/07/2016.
//  Copyright © 2016 ninjaprawn. All rights reserved.
//

import Foundation
import Alamofire

class AuthPTC {
	
	static let sharedAuthenticator = AuthPTC()
	
	func matchesForRegexInText(regex: String!, text: String!) -> [String] {
		do {
			let regex = try NSRegularExpression(pattern: regex, options: [])
			let nsString = text as NSString
			let results = regex.matchesInString(text,
			                                    options: [], range: NSMakeRange(0, nsString.length))
			return results.map { nsString.substringWithRange($0.range)}
		} catch let error as NSError {
			print("invalid regex: \(error.localizedDescription)")
			return []
		}
	}
	
	
	let requestURL = "https://sso.pokemon.com/sso/login?service=https%3A%2F%2Fsso.pokemon.com%2Fsso%2Foauth2.0%2FcallbackAuthorize"
	let loginURL = "https://sso.pokemon.com/sso/oauth2.0/accessToken"
	
	func beginAuthPTC(username:String, password:String, handler: String->Void){
		let firstRequest = request(.GET, requestURL, parameters: nil, headers: ["User-Agent" : "niantic"])
		
		firstRequest.responseJSON { (JSON) in
			switch JSON.result {
			case .Success(let JSON):
				//print("Success with JSON: \(JSON)")
				
				let response = JSON as! NSDictionary
				
				//example if there is an id
				let executionString = response.objectForKey("execution")! as! String
				let token = response.objectForKey("lt")! as! String
				
				//print(executionString, token)
				
				self.continueAuthPTC(username, password: password, token: token, execution: executionString, handler: handler)
				
			case .Failure(let error):
				print("Request failed with error: \(error)")
				return
			}
			
		}
		
	}
	
	func continueAuthPTC(username:String, password:String, token:String, execution:String, handler: String->Void){
		let nextRequest = request(.GET, requestURL, parameters: ["lt":token,
			"execution":execution,
			"_eventId":"submit",
			"username":username,
			"password":password], headers: ["User-Agent" : "niantic"])
		
		nextRequest.responseJSON { (JSON) in
			//print(String(JSON.response))
			let headers = String(JSON.response)
			let ticket = self.matchesForRegexInText("ticket=.*?\\.com", text: headers)
			if ticket.count > 0 {
				let ticketString = ticket[0].stringByReplacingOccurrencesOfString("ticket=", withString: "")
				self.ticketAuthPTC(ticketString, handler: handler)
			}
		}
		
	}
	
	func ticketAuthPTC(ticket:String, handler: String->Void){
		//print("TICKET: \(ticket)")
		let authRequest = request(.POST, loginURL, parameters: ["client_id": "mobile-app_pokemon-go",
			"redirect_uri": "https://www.nianticlabs.com/pokemongo/error",
			"client_secret": "w8ScCUXJQc6kXKw8FiOhd8Fixzht18Dq3PEVkUCP5ZPxtgyWsbTvWHFLm2wNY0JR",
			"grant_type": "refresh_token",
			"code": ticket], headers: ["User-Agent" : "niantic"])
		authRequest.responseJSON { (JSON) in
			//print(NSString(data: JSON.data!, encoding: NSUTF8StringEncoding))
			let accessToken = String(NSString(data: JSON.data!, encoding: NSUTF8StringEncoding)).stringByReplacingOccurrencesOfString("access_token=", withString: "").componentsSeparatedByString("&")[0].stringByReplacingOccurrencesOfString("Optional(", withString: "")
			handler(accessToken)
			//print(accessToken)
			
		}
		
	}
	
}