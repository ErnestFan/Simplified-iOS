//
//  NYPLReaderExtensions.swift
//  SimplyE
//
//  Created by Ettore Pasquini on 3/4/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import Foundation
import R2Shared
import R2Streamer

// Required to be able to compile the R2 stuff
extension NYPLBook {

  /// This is really just the file name ("28E5C209-579E-4127-A3C9-1F35AA30286D.epub")
  /// or anything absolute or relative (as long as there's no scheme),
  /// or a file url "file:/some/path/abc.epub",
  /// "file:///some/path/abc.epub"
  var fileName: String? {
    let url = URL(string: href)
    guard url?.scheme == nil || (url?.isFileURL ?? false) else {
      return nil
    }
    return href
  }

  var url: URL? {
    return NYPLMyBooksDownloadCenter.shared()?.fileURL(forBookIndentifier: identifier)
  }

  var href: String {
    guard let urlStr = url?.absoluteString else {
      fatalError("TODO: the URL for \(self) is nil")
    }

    return urlStr
  }

  var progressionLocator: Locator? {
    // TODO: SIMPLY-2609
    return nil
  }
}

@objc extension NYPLRootTabBarController {
  func presentBook(_ book: NYPLBook) {
    guard let libModule = r2Owner?.libraryModule else {
      return
    }

    let libService = libModule.libraryService

    guard let (publication, container) = libService.parsePublication(for: book) else {
      return
    }

    libService.preparePresentation(of: publication, book: book, with: container)

    guard let navVC = NYPLRootTabBarController.shared().selectedViewController as? UINavigationController else {
      fatalError("No navigation controller, unable to present reader")
    }

    r2Owner.readerModule.presentPublication(publication: publication,
                                            book: book,
                                            in: navVC) {}
  }
}

