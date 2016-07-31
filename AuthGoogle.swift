//
//  AuthGoogle.swift
//  PokemonGoAPI
//
//  Created by George Dan on 28/07/2016.
//  Copyright © 2016 ninjaprawn. All rights reserved.
//

import Foundation
import Alamofire

class AuthGoogle {
	
	static let sharedAuthenticator = AuthGoogle()
	
	let authURL = "https://android.clients.google.com/auth"
	
	func convertToEncodedData(data: [String: String]) -> String {
		
		var d = String()
		
		data.forEach({key, content in
			if d.isEmpty {
				d = "\(key)=\(content.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)"
			} else {
				d = "\(d)&\(key)=\(content.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)"
			}
		})
		
		return d
	}
	
	func getTokenFromResponse(response: String) -> String {
		
		let tokenRegex = try! NSRegularExpression(pattern: "Token=(.*?)\n", options: [])
		
		return String((response as NSString).substringWithRange(tokenRegex.firstMatchInString(response, options: [], range: NSMakeRange(0, response.characters.count))!.rangeAtIndex(1)))
		
	}
	
	func getAuthFromResponse(response: String) -> String {
		
		let tokenRegex = try! NSRegularExpression(pattern: "Auth=(.*?)\n", options: [])
		
		return String((response as NSString).substringWithRange(tokenRegex.firstMatchInString(response, options: [], range: NSMakeRange(0, response.characters.count))!.rangeAtIndex(1)))
		
	}
	
	func login(email: String, password: String, callback: ((data: String?, error: NSError?) -> Void)) {
		
		let data = ["accountType": "HOSTED_OR_GOOGLE", "Email": email, "has_permission": "1", "add_account": "1", "Passwd": password, "service": "ac2dm", "source": "android", "androidId": "9774d56d682e549c", "device_country": "us", "operatorCountry": "us", "lang": "en", "sdk_version": "17"]
		
		let d = self.convertToEncodedData(data)
		
		let headers = [
			"Content-type": "application/x-www-form-urlencoded",
			"User-Agent": "Dalvik/2.1.0 (Linux; U; Android 5.1.1; Andromax I56D2G Build/LMY47V"
		]
		
		Alamofire.request(.POST, "\(authURL)?\(d)", headers: headers).responseData { response in
			switch response.result {
			case .Success:
				if response.response!.statusCode >= 400 {
					print(String(data: response.data!, encoding: NSUTF8StringEncoding))
					callback(data: nil, error: nil)
				}
				let token = self.getTokenFromResponse(String(data: response.data!, encoding: NSUTF8StringEncoding)!)
				
				self.oauth(email, token: token, callback: callback)
			case .Failure(let error):
				callback(data: nil, error: error)
			}
		}
		
	}
	
	private func oauth(email: String, token: String, callback: ((data: String?, error: NSError?) -> Void)) {
		let data = ["accountType": "HOSTED_OR_GOOGLE", "Email": email, "has_permission": "1", "EncryptedPasswd": token, "service": "audience:server:client_id:848232511240-7so421jotr2609rmqakceuu1luuq0ptb.apps.googleusercontent.com", "source": "android", "androidId": "9774d56d682e549c", "app": "com.nianticlabs.pokemongo", "client_sig": "321187995bc7cdc2b5fc91b11a96e2baa8602c62", "device_country": "us", "operatorCountry": "us", "lang": "en", "sdk_version": "17"]
		
		let d = self.convertToEncodedData(data)
		
		let headers = [
			"Content-type": "application/x-www-form-urlencoded",
			"User-Agent": "Dalvik/2.1.0 (Linux; U; Android 5.1.1; Andromax I56D2G Build/LMY47V"
		]
		
		Alamofire.request(.POST, "\(authURL)?\(d)", headers: headers).responseData { response in
			switch response.result {
			case .Success:
				if response.response!.statusCode >= 400 {
					print(String(data: response.data!, encoding: NSUTF8StringEncoding))
					callback(data: nil, error: nil)
				}
				callback(data: self.getAuthFromResponse(String(data: response.data!, encoding: NSUTF8StringEncoding)!), error: nil)
			case .Failure(let error):
				callback(data: nil, error: error)
			}
		}
	}
	
}