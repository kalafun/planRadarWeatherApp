//
//  APIClient.swift
//  WeatherApp
//
//  Created by Tomas Bobko on 02.07.24.
//

import Foundation

class APIClient {
    static let shared = APIClient()

    func data<T: Decodable>(for request: URLRequest) async throws -> T {
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        print("")
        print("REQUEST: \(request.url?.absoluteString ?? "")")
        print("RESPONSE>>>\((urlResponse as? HTTPURLResponse)?.statusCode.description ?? "N/A")")
        print("RESPONSE>>>\n\(String(data: data, encoding: String.Encoding.utf8)! as NSString)")
        print("")

        return try JSONDecoder().decode(T.self, from: data)
    }
}
