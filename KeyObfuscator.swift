import Foundation

// MARK: - Console Output

let createFileSucceedMessage = "Successfully created NYPLSecrets.swift."

let writeToFileFailureMessage = "Failed to write to NYPLSecrets.swift. Please try again."
let accessFileFailureMessage = "Invalid file path or file type."

enum OutputType {
  case error
  case standard
}

class ConsoleIO {
  func printUsage() {
    let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
          
    writeMessage("Usage:")
    writeMessage("This script is to obfuscate keys in a json file and generate a .swift file")
    writeMessage("The line below will execute with a default path ../Certificates/SimplyE/iOS/APIKeys.json")
    writeMessage("swift \(executableName)")
    writeMessage("You can also manully input a path")
    writeMessage("swift \(executableName) <json file path>")
  }
    
  func writeMessage(_ message: String, to: OutputType = .standard) {
    switch to {
    case .standard:
      print("\(message)")
    case .error:
      fputs("Error: \(message)\n", stderr)
    }
  }
}

// MARK: - Obfuscation

enum ObfuscatedConstants {
    static let obfuscatedString: [UInt8] = [98, 1, 160, 125, 209, 58, 185, 157, 162, 252, 56, 238, 104, 214, 57, 49, 208, 243, 116, 67]
}

class Obfuscator {
    
    // MARK: - Variables
    
    // Console Output
    let consoleIO = ConsoleIO()
    
    private var salt: [UInt8]
    
    // MARK: - Initialization
    
    init(with salt: [UInt8]) {
      self.salt = salt
    }
    
    // MARK: - Obfuscation/Reveal
    
    func bytesByObfuscatingString(string: String) -> [UInt8] {
      let text = [UInt8](string.utf8)
      let cipher = self.salt
      let length = cipher.count
      
      var encrypted = [UInt8]()
      
      for t in text.enumerated() {
          encrypted.append(t.element ^ cipher[((t.offset + 10) * 3)  % length])
      }
      
//      #if DEBUG
//      consoleIO.writeMessage("Salt used: \(self.salt)\n")
//      consoleIO.writeMessage("Swift Code:\n************")
//      consoleIO.writeMessage("// Original \"\(string)\"")
//      consoleIO.writeMessage("let key: [UInt8] = \(encrypted)\n")
//      #endif
      
      return encrypted
    }
}

// MARK: - Scripts Generator

class Scripts {
  private let secretKey = "secret"
  private let infoKey = "info"
    
  func scripts(from dict: [String: [String: Any]]) -> String {
    let obfuscator = Obfuscator(with: ObfuscatedConstants.obfuscatedString)
    var variables = "  private static let salt: [UInt8] = \(ObfuscatedConstants.obfuscatedString)\n\n"
    
    // Add secret and info to script if they exist
    for (name, d) in dict {
      if let secret = d[secretKey] as? String {
        variables.append(secretScript(with: name, secret: obfuscator.bytesByObfuscatingString(string: secret)))
      }
        
      if let info = d[infoKey] as? [String:Any] {
        variables.append(variableScript(with: name + "Info", info: info))
      }
    }
        
    return header + variables + functions() + "}"
  }
    
  private let header = "import Foundation\n\nenum NYPLSecrets {\n"

  private func variableScript(with name: String, info: [String:Any]) -> String {
    var result = ""
    do {
      // Encode dictionary into json string in order to output it in correct format in a swift file
      let jsonData = try JSONSerialization.data(withJSONObject: info, options: [.withoutEscapingSlashes, .prettyPrinted])
      guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        return result
      }
        
      var modifiedString = jsonString
      modifiedString = modifiedString.replacingOccurrences(of: "\n{", with: "\n[")
      modifiedString = modifiedString.replacingOccurrences(of: "{\n", with: "[\n")
      modifiedString = modifiedString.replacingOccurrences(of: "\n}", with: "\n]")
      modifiedString = modifiedString.replacingOccurrences(of: "}\n", with: "]\n")
      modifiedString = modifiedString.replacingOccurrences(of: "},\n", with: "],\n")
      
      result.append("  static var \(name):[String:Any] {\n")
      result.append("    return \(modifiedString)\n")
      result.append("  }\n\n")
    } catch {
      ConsoleIO().writeMessage("Failed to encode JSON data for \(name)'s info")
    }
    return result
  }
    
  private func secretScript(with name: String, secret: [UInt8]) -> String {
    var result = ""
    
    result.append("  static var \(name):String {\n")
    result.append("    let encoded: [UInt8] = \(secret)\n")
    result.append("    return decode(encoded, cipher: salt)\n")
    result.append("  }\n\n")
    
    return result
  }
    
  private func functions() -> String {
    return "  static func decode(_ encoded: [UInt8], cipher: [UInt8]) -> String {\n"
        + "    var decrypted = [UInt8]()\n\n"
        + "    for k in encoded.enumerated() {\n"
        + "      decrypted.append(k.element ^ cipher[((k.offset + 10) * 3) % cipher.count])\n"
        + "    }\n"
        + "    return String(bytes: decrypted, encoding: .utf8)!\n"
        + "  }\n"
  }
}

// MARK: - File I/O

class FileHandler {
  private static let defaultInputPath = "../Certificates/SimplyE/iOS/APIKeys.json"
  private let outputPath = "/Simplified/NYPLSecrets.swift"
    
  let consoleIO = ConsoleIO()
    
  // MARK: - Read/Write File
    
  func handleJSONFile(with path: String = defaultInputPath) {
    let pathURL = URL(fileURLWithPath: path)
    
    do {
      let data = try Data(contentsOf: pathURL, options: .mappedIfSafe)
      let result = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
      if let jsonDict = result as? [String: [String: Any]] {
        let scripts = Scripts().scripts(from: jsonDict)
        writeToSwiftFile(with: scripts)
      } else {
        handleInvalidFile()
      }
    } catch {
      handleInvalidFile()
    }
  }
    
  func writeToSwiftFile(with message: String) {
    let path = FileManager.default.currentDirectoryPath.appending(outputPath)
    
    do {
      try message.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
    } catch {
      consoleIO.writeMessage(writeToFileFailureMessage, to: .error)
    }
  }
    
  // MARK: - Warnings
    
  func handleInvalidArguments() {
    consoleIO.printUsage()
  }
    
  func handleInvalidFile() {
    consoleIO.writeMessage(accessFileFailureMessage, to: .error)
  }
}

// MARK: Main

let fileHandler = FileHandler()

let argCount = CommandLine.argc
let arguments = CommandLine.arguments

if argCount == 1 {
  fileHandler.handleJSONFile()
} else if argCount == 2 {
  fileHandler.handleJSONFile(with: arguments[1])
} else {
  fileHandler.handleInvalidArguments()
}
