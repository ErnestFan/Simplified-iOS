//
//  AppModule.swift
//  r2-testapp-swift
//
//  Created by Mickaël Menu on 20.02.19.
//
//  Copyright 2019 European Digital Reading Lab. All rights reserved.
//  Licensed to the Readium Foundation under one or more contributor license agreements.
//  Use of this source code is governed by a BSD-style license which is detailed in the
//  LICENSE file present in the project repository where this source code is maintained.
//

import Foundation
import UIKit
import R2Shared
import R2Streamer


/// Base module delegate, that sub-modules' delegate can extend.
/// Provides basic shared functionalities.
@objc protocol ModuleDelegate: AnyObject {
    func presentAlert(_ title: String, message: String, from viewController: UIViewController)
    func presentError(_ error: Error?, from viewController: UIViewController)
}



/// Main application module, it:
/// - owns the sub-modules (library, reader, etc.)
/// - orchestrates the communication between its sub-modules, through the modules' delegates.
@objc public final class AppModule: NSObject {

// App modules
  var library: LibraryModuleAPI! = nil
  var reader: ReaderModuleAPI! = nil
//    var opds: OPDSModuleAPI! = nil

  override init() {
    super.init()
    guard let server = PublicationServer() else {
      /// FIXME: we should recover properly if the publication server can't start, maybe this should only forbid opening a publication?
      fatalError("Can't start publication server")
    }

    library = LibraryModule(delegate: self, server: server)
    reader = ReaderModule(delegate: self, resourcesServer: server)
    //        opds = OPDSModule(delegate: self)

    // Set Readium 2's logging minimum level.
    R2EnableLog(withMinimumSeverityLevel: .debug)
  }
}

extension AppModule: ModuleDelegate {
  func presentAlert(_ title: String, message: String, from viewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let dismissButton = UIAlertAction(title: NSLocalizedString("ok_button", comment: "Alert button"), style: .cancel)
    alert.addAction(dismissButton)
    viewController.present(alert, animated: true)
  }

  func presentError(_ error: Error?, from viewController: UIViewController) {
    guard let error = error else { return }
    presentAlert(
      NSLocalizedString("error_title", comment: "Alert title for errors"),
      message: error.localizedDescription,
      from: viewController
    )
  }
}

extension AppModule: LibraryModuleDelegate {
//  class func AppModule
  func libraryDidSelectPublication(_ publicationWrapper: OBJCPublication,
                                   book: NYPLBook,
                                   inNavVC navVC: UINavigationController,
                                   completion: @escaping () -> Void) {

    reader.presentPublication(publication: publicationWrapper.publication,
                              book: book,
                              in: navVC,
                              completion: completion)
  }
}

extension AppModule: ReaderModuleDelegate {
  func readerLoadDRM(for book: NYPLBook, completion: @escaping (CancellableResult<DRM?>) -> Void) {
    library.loadDRM(for: book, completion: completion)
  }
}

//extension AppModule: OPDSModuleDelegate {
//    func opdsDownloadPublication(_ publication: Publication?, at link: Link, completion: @escaping (Bool) -> Void) {
//        library.downloadPublication(publication, at: link, completion: completion)
//    }
//}
