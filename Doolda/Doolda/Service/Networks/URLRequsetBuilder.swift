//
//  URLRequsetBuilder.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Foundation

enum HttpMethod {
    case get
    case post
    case put
    case patch
    case delete
}

extension HttpMethod {
    var method: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
}

protocol URLRequestBuilder {
    var baseURL: URL? { get }
    var requestURL: URL? { get }
    var path: String { get }
    var parameters: [String:String]? { get }
    var method: HttpMethod { get }
    var body: [String: Any]? { get }
    var urlRequest: URLRequest? { get }
}

extension URLRequestBuilder {
    
    var requestURL: URL? {
        return baseURL?.appendingPathComponent(path, isDirectory: false)
    }
    
    var urlRequest: URLRequest? {
        guard let requestURL = requestURL else {
            return nil
        }

        switch method {
        case .get:
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
                return URLRequest(url: compoentURL)
            } else {
                return URLRequest(url: requestURL)
            }
        
        case .post, .put, .delete, .patch:
            var urlRequest = URLRequest(url: requestURL)
            urlRequest.httpMethod = method.method
            
            if let httpbody = self.body {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: httpbody)
            }
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            
            return urlRequest
        }
    }
}
