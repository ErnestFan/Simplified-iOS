//
//  Normalise.swift
//  Simplified
//
//  Created by Vladimir Fedorov on 23.06.2020.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

// TODO: SIMPLY-2840
// This file should be removed as a part of the cleanup

import Foundation

/*
 
 This function is imported from R2Streamer
 It is used in NavigationDocumentParser.swift

 */

/// Normalize a path relative path given the base path.
internal func normalize(base: String, href: String?) -> String {
    guard let href = href, !href.isEmpty else {
        return ""
    }
    let hrefComponents = href.components(separatedBy: "/").filter({!$0.isEmpty})
    var baseComponents = base.components(separatedBy: "/").filter({!$0.isEmpty})

    // Remove the /folder/folder/"PATH.extension" part to keep only the path.
    _ = baseComponents.popLast()
    // Find the number of ".." in the path to replace them.
    let replacementsNumber = hrefComponents.filter({$0 == ".."}).count
    // Get the valid part of href, reversed for next operation.
    var normalizedComponents = hrefComponents.filter({$0 != ".."})
    // Add the part from base to replace the "..".
    for _ in 0..<replacementsNumber {
        _ = baseComponents.popLast()
    }
    normalizedComponents = baseComponents + normalizedComponents
    // Recreate a string.
    var normalizedString = ""
    for component in normalizedComponents {
        normalizedString.append("/\(component)")
    }
    return normalizedString
}
