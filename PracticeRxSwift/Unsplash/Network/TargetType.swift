//
//  TargetType.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/11/24.
//

import Foundation
import Alamofire

protocol TargetType: URLRequestConvertible {
    var baseURL: String { get }
    var endPoint: String { get }
    var method: HTTPMethod { get }
    var params: [String: String] { get }
}

extension TargetType {
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        let endPoint = url.appendingPathComponent(endPoint)
        var request = try URLRequest(url: endPoint, method: method)
        
        var components = URLComponents(string: endPoint.absoluteString)
        let queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        components?.queryItems = queryItems
        
        request.url = components?.url
        return request
    }
}
