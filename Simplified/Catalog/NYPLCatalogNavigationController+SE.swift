//
//  NYPLCatalogNavigationController+SE.swift
//  Simplified
//
//  Created by Ettore Pasquini on 9/14/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import Foundation

extension NYPLCatalogFeedViewController {
  @objc func didSignOut() {
  }

  @objc func shouldLoad() -> Bool {
    return NYPLSettings.shared.userHasSeenWelcomeScreen
  }
}
