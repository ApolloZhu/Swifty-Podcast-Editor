//
//  PlaygroundHelper.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import Foundation

#if canImport(PlaygroundSupport)
import PlaygroundSupport

let playgroundSharedDataDirectory: URL = {
  let url = PlaygroundSupport.playgroundSharedDataDirectory
  if !FileManager.default.fileExists(atPath: url.path) {
    try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
  }
  return url
}()
/*
 func get<T: Codable>(_ key: String, ofType type: T.Type) -> T? {
   switch PlaygroundKeyValueStore.current.keyValueStore[key] {
   case .data(let data):
     return try? JSONDecoder().decode(type, from: data)
   default:
     return nil
   }
 }

 func set<T: Codable>(_ key: String, _ value: T?) {
   if let data = try? value.map(JSONEncoder().encode) {
     PlaygroundKeyValueStore.current.keyValueStore[key] = .data(data)
   } else {
     PlaygroundKeyValueStore.current.keyValueStore[key] = nil
   }
 }
 */
#else
let playgroundSharedDataDirectory = FileManager.default
  .urls(for: .documentDirectory, in: .userDomainMask)[0]
#endif

public func get<T: Codable>(_ key: String, ofType type: T.Type) -> T? {
  return UserDefaults.standard.data(forKey: key).flatMap {
    try? JSONDecoder().decode(type, from: $0)
  }
}

public func set<T: Codable>(_ key: String, _ value: T?) {
  if let data = try? value.map(JSONEncoder().encode) {
    UserDefaults.standard.set(data, forKey: key)
  } else {
    UserDefaults.standard.removeObject(forKey: key)
  }
  UserDefaults.standard.synchronize()
}

