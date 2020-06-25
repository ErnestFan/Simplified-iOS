//
//  ACSLicense.swift
//  SimplyE
//
//  Created by Vladimir Fedorov on 13.05.2020.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import Foundation
import R2Shared

/// DRM License for Adobe DRM
class AdobeDRMLicense: DRMLicense {
  
  /// DRM container for file
  var container: AdobeDRMContainer?
  
  /// DRM license for file
  /// - Parameter fileURL: .epub file URL
  init(with fileURL: URL) {
    container = AdobeDRMContainer(url: fileURL)
    if let errorMessage = container?.epubDecodingError {
      NYPLErrorLogger.logError(withCode: .epubDecodingError, context: NYPLErrorLogger.Context.ereader.rawValue, message: errorMessage)
    }
  }
  
  /// Depichers the given encrypted data to be displayed in the reader.
  func decipher(_ data: Data) throws -> Data? {
    guard let container = container else { return data }
    return container.decode(data)
  }
}
