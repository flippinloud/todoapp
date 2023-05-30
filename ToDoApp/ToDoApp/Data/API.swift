//
//  API.swift
//  ToDoApp
//
//  Created by Steve Gregory on 25/5/2023.
//

import Foundation

class API {
    static let shared = API()
    private let baseURL = "http://127.0.0.1:8000/api/"
    
    private init() {} // This prevents others from using the default '()' initializer for this class.
    
    func getToDo(completion: @escaping ([ToDoModel]) -> Void) {
        guard let url = URL(string: baseURL + "todos") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode([ToDoModel].self, from: data)
                    DispatchQueue.main.async {
                        completion(decodedResponse)
                    }
                } catch {
                    print("Failed to decode JSON")
                }
            } else if let error = error {
                print("Fetch failed: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func updateToDo(todo: ToDoModel, completion: @escaping (Result<ToDoModel, Error>) -> Void) {
        guard let url = URL(string: baseURL + "todos/\(todo.id)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        guard let httpBody = try? encoder.encode(todo) else {
            print("Failed to encode todo")
            return
        }

        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print ("data is " + data!.description)
                completion(.failure(error))
            } else if let data = data {
                do {
                    let updatedTodo = try JSONDecoder().decode(ToDoModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(updatedTodo))
                    }
                } catch {
                    print ("data is " + data.description)
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func createToDo(todo: ToDoModel, completion: @escaping (Result<ToDoModel, Error>) -> Void) {
        guard let url = URL(string: baseURL + "todos/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        guard let httpBody = try? encoder.encode(todo) else {
            print("Failed to encode todo")
            return
        }

        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let createdTodo = try JSONDecoder().decode(ToDoModel.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(createdTodo))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func deleteToDo(todo: ToDoModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: baseURL + "todos/\(todo.id)/") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            }
        }.resume()
    }
}
