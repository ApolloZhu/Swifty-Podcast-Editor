//
//  Error.swift
//  Podcast
//
//  Created by Apollo Zhu on 5/16/20.
//  Copyright © 2020 Apollonyan. All rights reserved.
//

import Foundation

extension String: Error { }

extension Result where Success == Void {
  public static var success: Self {
    return .success(())
  }
}

