//
//  Promise.swift
//  
//
//  Created by Bartłomiej Zabicki on 02/07/2019.
//

import Foundation

public class Promise<Value>: Future<Value> {
  public init(value: Value? = nil) {
    super.init()
    if let value = value {
      result = .success(value)
    }
  }
  
  public func resolve(with value: Value) {
    result = .success(value)
  }
  
  public func reject(with error: Error) {
    result = .failure(error)
  }
}


// MARK: - Initialization

extension Promise {
  public convenience init( value: @escaping (Promise<Value>) -> Void) {
    self.init()
    value(self)
  }
}
