// MARK: AccountDetails
// Extra data that gets loaded from an OPDS2AuthenticationDocument,
@objcMembers final class AccountDetails: NSObject {
  enum AuthType: String {
    case basic = "http://opds-spec.org/auth/basic"
    case coppa = "http://librarysimplified.org/terms/authentication/gate/coppa"
    case anonymous = "http://librarysimplified.org/rel/auth/anonymous"
    case none
  }
  
  struct Authentication {
    let authType:AuthType
    let authPasscodeLength:UInt
    let patronIDKeyboard:LoginKeyboard
    let pinKeyboard:LoginKeyboard
    let patronIDLabel:String?
    let pinLabel:String?
    let supportsBarcodeScanner:Bool
    let supportsBarcodeDisplay:Bool
    let coppaUnderUrl:URL?
    let coppaOverUrl:URL?
    
    init(auth: OPDS2AuthenticationDocument.Authentication) {
      authType = AuthType(rawValue: auth.type) ?? .none
      authPasscodeLength = auth.inputs?.password.maximumLength ?? 99
      patronIDKeyboard = LoginKeyboard.init(auth.inputs?.login.keyboard) ?? .standard
      pinKeyboard = LoginKeyboard.init(auth.inputs?.password.keyboard) ?? .standard
      patronIDLabel = auth.labels?.login
      pinLabel = auth.labels?.password
      supportsBarcodeScanner = auth.inputs?.login.barcodeFormat == "Codabar"
      supportsBarcodeDisplay = supportsBarcodeScanner
      coppaUnderUrl = URL.init(string: auth.links?.first(where: { $0.rel == "http://librarysimplified.org/terms/rel/authentication/restriction-not-met" })?.href ?? "")
      coppaOverUrl = URL.init(string: auth.links?.first(where: { $0.rel == "http://librarysimplified.org/terms/rel/authentication/restriction-met" })?.href ?? "")
    }
  }
  
  let defaults:UserDefaults
  let uuid:String
  let supportsSimplyESync:Bool
  let supportsCardCreator:Bool
  let supportsReservations:Bool
  let auths: [Authentication]
  
  let mainColor:String?
  let userProfileUrl:String?
  let cardCreatorUrl:String?
  let loansUrl:URL?
  
  var authType: AuthType {
    return auths.first?.authType ?? .none
  }
  
  var authPasscodeLength: UInt {
    return auths.first?.authPasscodeLength ?? 99
  }
  
  var patronIDKeyboard: LoginKeyboard {
    return auths.first?.patronIDKeyboard ?? .standard
  }
  
  var pinKeyboard: LoginKeyboard {
    return auths.first?.pinKeyboard ?? .standard
  }
  
  var supportsBarcodeScanner: Bool {
    return auths.first?.supportsBarcodeScanner ?? false
  }
  
  var supportsBarcodeDisplay: Bool {
    return auths.first?.supportsBarcodeDisplay ?? false
  }
  
  var coppaUnderUrl: URL? {
    return auths.first?.coppaUnderUrl
  }
  
  var coppaOverUrl: URL? {
    return auths.first?.coppaOverUrl
  }

  var patronIDLabel: String? {
    return auths.first?.patronIDLabel
  }
  
  var pinLabel: String? {
    return auths.first?.pinLabel
  }
  
  var needsAuth:Bool {
    return authType == .basic
  }
  
  var needsAgeCheck:Bool {
    return authType == .coppa
  }
  
  fileprivate var urlAnnotations:URL?
  fileprivate var urlAcknowledgements:URL?
  fileprivate var urlContentLicenses:URL?
  fileprivate var urlEULA:URL?
  fileprivate var urlPrivacyPolicy:URL?
  
  var eulaIsAccepted:Bool {
    get {
      guard let result = getAccountDictionaryKey(userAcceptedEULAKey) else { return false }
      return result as! Bool
    }
    set {
      setAccountDictionaryKey(userAcceptedEULAKey, toValue: newValue as AnyObject)
    }
  }
  var syncPermissionGranted:Bool {
    get {
      guard let result = getAccountDictionaryKey(accountSyncEnabledKey) else { return false }
      return result as! Bool
    }
    set {
      setAccountDictionaryKey(accountSyncEnabledKey, toValue: newValue as AnyObject)
    }
  }
  var userAboveAgeLimit:Bool {
    get {
      guard let result = getAccountDictionaryKey(userAboveAgeKey) else { return false }
      return result as! Bool
    }
    set {
      setAccountDictionaryKey(userAboveAgeKey, toValue: newValue as AnyObject)
    }
  }
  
  init(authenticationDocument: OPDS2AuthenticationDocument, uuid: String) {
    defaults = .standard
    self.uuid = uuid
    
    auths = authenticationDocument.authentication?.map({ (opdsAuth) -> Authentication in
      return Authentication.init(auth: opdsAuth)
    }) ?? []
    
    supportsReservations = authenticationDocument.features?.disabled?.contains("https://librarysimplified.org/rel/policy/reservations") != true
    userProfileUrl = authenticationDocument.links?.first(where: { $0.rel == "http://librarysimplified.org/terms/rel/user-profile" })?.href
    loansUrl = URL.init(string: authenticationDocument.links?.first(where: { $0.rel == "http://opds-spec.org/shelf" })?.href ?? "")
    supportsSimplyESync = userProfileUrl != nil
    
    mainColor = authenticationDocument.colorScheme
    
    let registerUrl = authenticationDocument.links?.first(where: { $0.rel == "register" })?.href
    if let url = registerUrl, url.hasPrefix("nypl.card-creator:") == true {
      supportsCardCreator = true
      cardCreatorUrl = String(url.dropFirst("nypl.card-creator:".count))
    } else {
      supportsCardCreator = false
      cardCreatorUrl = registerUrl
    }
    
    super.init()
    
    if let urlString = authenticationDocument.links?.first(where: { $0.rel == "privacy-policy" })?.href,
      let url = URL(string: urlString) {
      setURL(url, forLicense: .privacyPolicy)
    }
    
    if let urlString = authenticationDocument.links?.first(where: { $0.rel == "terms-of-service" })?.href,
      let url = URL(string: urlString) {
      setURL(url, forLicense: .eula)
    }
    
    if let urlString = authenticationDocument.links?.first(where: { $0.rel == "license" })?.href,
      let url = URL(string: urlString) {
      setURL(url, forLicense: .contentLicenses)
    }
    
    if let urlString = authenticationDocument.links?.first(where: { $0.rel == "copyright" })?.href,
      let url = URL(string: urlString) {
      setURL(url, forLicense: .acknowledgements)
    }
  }

  func setURL(_ URL: URL, forLicense urlType: URLType) -> Void {
    switch urlType {
    case .acknowledgements:
      urlAcknowledgements = URL
      setAccountDictionaryKey("urlAcknowledgements", toValue: URL.absoluteString as AnyObject)
    case .contentLicenses:
      urlContentLicenses = URL
      setAccountDictionaryKey("urlContentLicenses", toValue: URL.absoluteString as AnyObject)
    case .eula:
      urlEULA = URL
      setAccountDictionaryKey("urlEULA", toValue: URL.absoluteString as AnyObject)
    case .privacyPolicy:
      urlPrivacyPolicy = URL
      setAccountDictionaryKey("urlPrivacyPolicy", toValue: URL.absoluteString as AnyObject)
    case .annotations:
      urlAnnotations = URL
      setAccountDictionaryKey("urlAnnotations", toValue: URL.absoluteString as AnyObject)
    }
  }
  
  func getLicenseURL(_ type: URLType) -> URL? {
    switch type {
    case .acknowledgements:
      if let url = urlAcknowledgements {
        return url
      } else {
        guard let urlString = getAccountDictionaryKey("urlAcknowledgements") as? String else { return nil }
        guard let result = URL(string: urlString) else { return nil }
        return result
      }
    case .contentLicenses:
      if let url = urlContentLicenses {
        return url
      } else {
        guard let urlString = getAccountDictionaryKey("urlContentLicenses") as? String else { return nil }
        guard let result = URL(string: urlString) else { return nil }
        return result
      }
    case .eula:
      if let url = urlEULA {
        return url
      } else {
        guard let urlString = getAccountDictionaryKey("urlEULA") as? String else { return nil }
        guard let result = URL(string: urlString) else { return nil }
        return result
      }
    case .privacyPolicy:
      if let url = urlPrivacyPolicy {
        return url
      } else {
        guard let urlString = getAccountDictionaryKey("urlPrivacyPolicy") as? String else { return nil }
        guard let result = URL(string: urlString) else { return nil }
        return result
      }
    case .annotations:
      if let url = urlAnnotations {
        return url
      } else {
        guard let urlString = getAccountDictionaryKey("urlAnnotations") as? String else { return nil }
        guard let result = URL(string: urlString) else { return nil }
        return result
      }
    }
  }
  
  fileprivate func setAccountDictionaryKey(_ key: String, toValue value: AnyObject) {
    if var savedDict = defaults.value(forKey: self.uuid) as? [String: AnyObject] {
      savedDict[key] = value
      defaults.set(savedDict, forKey: self.uuid)
    } else {
      defaults.set([key:value], forKey: self.uuid)
    }
  }
  
  fileprivate func getAccountDictionaryKey(_ key: String) -> AnyObject? {
    let savedDict = defaults.value(forKey: self.uuid) as? [String: AnyObject]
    guard let result = savedDict?[key] else { return nil }
    return result
  }
}

// MARK: Account
/// Object representing one library account in the app. Patrons may
/// choose to sign up for multiple Accounts.
@objcMembers final class Account: NSObject
{
  let logo:UIImage
  let uuid:String
  let name:String
  let subtitle:String?
  let supportEmail:String?
  let catalogUrl:String?
  var details:AccountDetails?
  
  let authenticationDocumentUrl:String?
  var authenticationDocument:OPDS2AuthenticationDocument? {
    didSet {
      guard let authenticationDocument = authenticationDocument else {
        return
      }
      details = AccountDetails(authenticationDocument: authenticationDocument, uuid: uuid)
    }
  }
  
  var authenticationDocumentCacheUrl: URL {
    let applicationSupportUrl = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let nonColonUuid = uuid.replacingOccurrences(of: ":", with: "_")
    return applicationSupportUrl.appendingPathComponent("authentication_document_\(nonColonUuid).json")
  }
  
  var loansUrl: URL? {
    return details?.loansUrl
  }
  
  init(publication: OPDS2Publication) {
    
    name = publication.metadata.title
    subtitle = publication.metadata.description
    uuid = publication.metadata.id
    
    catalogUrl = publication.links.first(where: { $0.rel == "http://opds-spec.org/catalog" })?.href
    supportEmail = publication.links.first(where: { $0.rel == "help" })?.href.replacingOccurrences(of: "mailto:", with: "")
    
    authenticationDocumentUrl = publication.links.first(where: { $0.type == "application/vnd.opds.authentication.v1.0+json" })?.href
    
    let logoString = publication.images?.first(where: { $0.rel == "http://opds-spec.org/image/thumbnail" })?.href
    if let modString = logoString?.replacingOccurrences(of: "data:image/png;base64,", with: ""),
      let logoData = Data.init(base64Encoded: modString),
      let logoImage = UIImage(data: logoData) {
      logo = logoImage
    } else {
      logo = UIImage.init(named: "LibraryLogoMagic")!
    }
  }
  
  func loadAuthenticationDocument(preferringCache: Bool, completion: @escaping (Bool) -> ()) {
    guard let urlString = authenticationDocumentUrl, let url = URL(string: urlString) else {
      Log.error(#file, "Invalid or missing authentication document URL")
      completion(false)
      return
    }
    
    loadDataWithCache(url: url, cacheUrl: authenticationDocumentCacheUrl, options: preferringCache ? .preferCache : []) { (data) in
      if let data = data {
        do {
          self.authenticationDocument = try OPDS2AuthenticationDocument.fromData(data)
          completion(true)
          
        } catch (let error) {
          Log.error(#file, "Failed to load authentication document for library: \(error.localizedDescription)")
          completion(false)
        }
      } else {
        Log.error(#file, "Failed to load data of authentication document from cache or network")
        completion(false)
      }
    }
  }
}

// MARK: URLType
@objc enum URLType: Int {
  case acknowledgements
  case contentLicenses
  case eula
  case privacyPolicy
  case annotations
}

// MARK: LoginKeyboard
@objc enum LoginKeyboard: Int {
  case standard
  case email
  case numeric
  case none

  init?(_ stringValue: String?) {
    if stringValue == "Default" {
      self = .standard
    } else if stringValue == "Email address" {
      self = .email
    } else if stringValue == "Number pad" {
      self = .numeric
    } else if stringValue == "No input" {
      self = .none
    } else {
      Log.error(#file, "Invalid init parameter for PatronPINKeyboard: \(stringValue ?? "nil")")
      return nil
    }
  }
}
