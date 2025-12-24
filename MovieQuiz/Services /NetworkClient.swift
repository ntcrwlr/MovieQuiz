//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Сергей Бушков on 12.12.2025.
//
import Foundation


protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkRouting {
    
    private enum NetworkError: Error {
        case codeError
        case noData
    }
    
    /// Загружает данные по указанному URL и возвращает результат в completion handler
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Ошибка транспорта
            if let error = error {
                handler(.failure(error))
                return
            }
            
            // Проверяем код ответа
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // Данные
            guard let data = data else {
                handler(.failure(NetworkError.noData))
                return
            }
            
            handler(.success(data))
        }
        
        task.resume()
    }
}
