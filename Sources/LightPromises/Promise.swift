//
//  Promise.swift
//  
//
//  Created by Bartłomiej Zabicki on 02/07/2019.
//

import Foundation

class Promise<Value>: Future<Value> {
  init(value: Value? = nil) {
    super.init()
    if let value = value {
      result = .success(value)
    }
  }
  
  func resolve(with value: Value) {
    result = .success(value)
  }
  
  func reject(with error: Error) {
    result = .failure(error)
  }
}
