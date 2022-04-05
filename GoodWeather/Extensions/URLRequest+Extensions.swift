//
//  URLRequest+Extensions.swift
//  GoodWeather
//
//  Created by Mohammad Azam on 3/9/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

struct Resource<T> {
    let url: URL
}

extension URLRequest {
    
    static func load<T: Decodable>(resource: Resource<T>) -> Observable<T> {
        
        return Observable.just(resource.url)
            .flatMap { url -> Observable<(response: HTTPURLResponse, data: Data)> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.response(request: request)

            }.map { response, data -> T in
                // ステータスコードが200〜300までのレスポンスのみデコードデータを返す
                if 200..<300 ~= response.statusCode {
                    return try JSONDecoder().decode(T.self, from: data)
                } else {
                    throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
                }
        }.asObservable()
        
    }
    
}
