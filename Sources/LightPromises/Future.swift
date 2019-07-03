//
//  Future.swift
//  LightPromises
//
//  Created by Bartłomiej Zabicki on 02/07/2019.
//  Copyright © 2019 Bartlomiej Zabicki. All rights reserved.
//

import Foundation

public class Future<Value>: Hashable {
  let id = UUID()
  typealias T = Value
  internal var result: Result<Value, Error>? {
    didSet { result.map(report) }
  }
  private lazy var callbacks = [(Result<Value, Error>) -> Void]()
  
  public func observe(with callback: @escaping (Result<Value, Error>) -> Void) {
    callbacks.append(callback)
    result.map(callback)
  }
  
  private func report(result: Result<Value, Error>) {
    for callback in callbacks {
      callback(result)
    }
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  public static func == (lhs: Future<Value>, rhs: Future<Value>) -> Bool {
    return lhs.id == rhs.id
  }
}

// MARK: - Initialization

extension Future {
  public convenience init( value: @escaping (Promise<Value>) -> Void) {
    self.init()
    let promise = Promise<Value>()
    value(promise)
  }
}

// MARK: - Error handling

extension Future {
  
  public func `catch`(_ block: @escaping (Error) -> Void) -> Void {
    switch result {
    case .failure(let error)?:
      block(error)
    default: break
    }
  }
  
}

// MARK: - Observing value

extension Future {
  public func flatMap<NextValue>(with closure: @escaping (Value) throws -> Future<NextValue>) -> Future<NextValue> {
    let promise = Promise<NextValue>()
    
    observe { result in
      switch result {
      case .success(let value):
        do {
          let future = try closure(value)
          
          future.observe { result in
            switch result {
            case .success(let value):
              promise.resolve(with: value)
            case .failure(let error):
              promise.reject(with: error)
            }
          }
        } catch {
          promise.reject(with: error)
        }
      case .failure(let error):
        promise.reject(with: error)
      }
    }
    
    return promise
  }
  
  public func transformed<NextValue>(with closure: @escaping (Value) throws -> NextValue) -> Future<NextValue> {
    return flatMap { value in
      return try Promise(value: closure(value))
    }
  }
}

extension URLSession {
  func request(url: URL) -> Future<Data> {
    let promise = Promise<Data>()
    
    let task = dataTask(with: url) { data, _, error in
      if let error = error {
        promise.reject(with: error)
      } else {
        promise.resolve(with: data ?? Data())
      }
    }
    
    task.resume()
    
    return promise
  }
}

extension Future {
  
  public func and<T>(with nextFuture: Future<T>) -> Future<(Value,T)> {
    let promise = Promise<(Value,T)>()
    var currentValue: Value?
    var nextValue: T?
    
    observe { result in
      switch result {
      case .success(let value):
        do {
          currentValue = value
          if let currentValue = currentValue, let nextValue = nextValue {
            promise.resolve(with: (currentValue, nextValue))
          }
        }
      case .failure(let error):
        promise.reject(with: error)
      }
    }
    nextFuture.observe { result in
      switch result {
      case .success(let value):
        nextValue = value
        if let currentValue = currentValue, let nextValue = nextValue {
          promise.resolve(with: (currentValue, nextValue))
        }
      case .failure(let error):
        promise.reject(with: error)
      }
    }
    
    return promise
  }
  
}
