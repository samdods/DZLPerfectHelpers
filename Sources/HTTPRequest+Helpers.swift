//
//  HTTPRequest+Helpers.swift
//  PerfectTemplate
//
//  Created by Sam Dods on 17/08/2016.
//
//

import PerfectHTTP

enum JSONParsingError : Error {
    case invalid
}

extension HTTPRequest {
    
    func jsonDictionaryBody() throws -> [String: Any] {
        guard let bodyString = postBodyString else {
            throw JSONParsingError.invalid
        }
        
        guard let json = (try? bodyString.jsonDecode()) as? [String:Any] else {
            throw JSONParsingError.invalid
        }
        
        return json
    }
    
}
