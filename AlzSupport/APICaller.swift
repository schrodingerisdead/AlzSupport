//
//  APICaller.swift
//  AlzSupport
//
//  Created by Magdalena Oreshkova on 3/7/24.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    struct Constants {
        static let alheimerURL = URL(string: "https://newsapi.org/v2/everything?q=alzheimer&language=en&sortBy=popularity&apiKey=d4a30dbe4e3e4670862f4dc63a513591")
    }
    private init() {}
    
    public func getAlzheimersNews(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let url = Constants.alheimerURL else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) {data, _, error in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode(APIResponse.self, from: data)
                    print("Articles: \(result.articles.count)")
                    completion(.success(result.articles))
                }
                catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
//Models
struct APIResponse: Codable {
    let articles: [Article]
}
struct Article: Codable {
    let source: Source
    let title:  String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
}

struct Source: Codable {
    let name: String
}

