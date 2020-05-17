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

func get<T: Codable>(_ key: String, ofType type: T.Type) -> T? {
    switch PlaygroundKeyValueStore.current[key] {
        case .data(let data):
            return try? JSONDecoder().decode(type, from: data)
        default:
            return nil
    }
}

func set<T: Codable>(_ key: String, _ value: T?) {
    if let data = try? value.map(JSONEncoder().encode) {
        PlaygroundKeyValueStore.current[key] = .data(data)
    } else {
        PlaygroundKeyValueStore.current[key] = nil
    }
}
#else
let playgroundSharedDataDirectory = FileManager.default
  .urls(for: .documentDirectory, in: .userDomainMask)[0]

func get<T: Codable>(_ key: String, ofType type: T.Type) -> T? {
  return UserDefaults.standard.data(forKey: key).flatMap {
    try? JSONDecoder().decode(type, from: $0)
  }
}

func set<T: Codable>(_ key: String, _ value: T?) {
  if let data = try? value.map(JSONEncoder().encode) {
    UserDefaults.standard.set(data, forKey: key)
  } else {
    UserDefaults.standard.removeObject(forKey: key)
  }
}
#endif


