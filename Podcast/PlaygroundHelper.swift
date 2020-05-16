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
#else
let playgroundSharedDataDirectory = FileManager.default
  .urls(for: .documentDirectory, in: .userDomainMask)[0]
#endif


