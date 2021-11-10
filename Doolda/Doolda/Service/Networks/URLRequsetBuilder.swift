//
//  URLRequsetBuilder.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol URLRequestBuilder {
    var baseURL: URL? { get }
    var requestURL: URL? { get }
    var path: String? { get }
    var parameters: [String:String]? { get }
    var method: HttpMethod { get }
    var headers: [String:String]? { get }
    var body: [String: Any]? { get }
    var binary: Data? { get }
    var urlRequest: URLRequest? { get }
}

extension URLRequestBuilder {
    var requestURL: URL? {
        guard let path = path else { return baseURL }
        return baseURL?.appendingPathComponent(path, isDirectory: false)
    }
    
    var urlRequest: URLRequest? {
        guard let requestURL = requestURL else {
            return nil
        }
        
        var urlRequest: URLRequest
        
        var component = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
        
        var parameter = [URLQueryItem]()
        if let parameters = self.parameters {
            for (name, value) in parameters {
                if name.isEmpty { continue }
                parameter.append(URLQueryItem(name: name, value: value))
            }
            if !parameter.isEmpty {
                component?.queryItems = parameter
            }
        }
        
        if let compoentURL = component?.url {
            urlRequest =  URLRequest(url: compoentURL)
        } else {
            urlRequest =  URLRequest(url: requestURL)
        }

        switch method {
        case .get:
            return urlRequest

        case .post, .put, .delete, .patch:
            urlRequest.httpMethod = method.rawValue
            
            if let httpbody = self.body {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: httpbody)
            }
            else if let binaryData = self.binary {
                urlRequest.httpBody = binaryData
            }

            headers?.forEach { key, value in
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
            
            return urlRequest
        }
    }
}
