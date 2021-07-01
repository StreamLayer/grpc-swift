import Foundation
import Result

struct NetrcMachine {
    let name: String
    let login: String
    let password: String
}

struct Netrc {
    
    public enum NetrcError: Error {
        case fileNotFound(URL)
        case unreadableFile(URL)
        case machineNotFound
        case missingToken(String)
        case missingValueForToken(String)
    }
    
    public let machines: [NetrcMachine]
    
    init(machines: [NetrcMachine]) {
        self.machines = machines
    }
    
    func authorization(for url: URL) -> String? {
        guard let machine = machines.first(where: { $0.name.lowercased() == url.host?.lowercased() }) else {
            return nil
        }
        if machine.login == "oauth2" {
            return "Bearer \(machine.password)"
        } else {
            let authString = "\(machine.login):\(machine.password)"
            guard let authData = authString.data(using: .utf8) else { return nil }
            return "Basic \(authData.base64EncodedString())"
        }
    }
    
    static func load(from fileURL: URL = URL(fileURLWithPath: "\(NSHomeDirectory())/.netrc")) -> Result<Netrc, NetrcError> {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return .failure(NetrcError.fileNotFound(fileURL)) }
        guard FileManager.default.isReadableFile(atPath: fileURL.path) else { return .failure(NetrcError.unreadableFile(fileURL)) }
        
        return Result(catching: { try String(contentsOf: fileURL, encoding: .utf8) })
            .flatMap { Netrc.from($0) }
    }
    
    static func from(_ content: String) -> Result<Netrc, NetrcError> {
        let trimmedCommentsContent = trimComments(from: content)
        let tokens = trimmedCommentsContent
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter({ $0 != "" })
        
        var machines: [NetrcMachine] = []
        
        let machineTokens = tokens.split { $0 == "machine" }
        guard tokens.contains("machine"), machineTokens.count > 0 else { return .failure(NetrcError.machineNotFound) }
        
        for machine in machineTokens {
            let values = Array(machine)
            guard let name = values.first else { continue }
            guard let login = values["login"] else { return .failure(NetrcError.missingValueForToken("login")) }
            guard let password = values["password"] else { return .failure(NetrcError.missingValueForToken("password")) }
            machines.append(NetrcMachine(name: name, login: login, password: password))
        }
        
        guard machines.count > 0 else { return .failure(NetrcError.machineNotFound) }
        return .success(Netrc(machines: machines))
    }
    
    private static func trimComments(from text: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "\\#[\\s\\S]*?.*$", options: .anchorsMatchLines) else {
            fatalError("Could not parse regular expression which is unexpected")
        }
        let nsString = text as NSString
        let range = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: text, range: range)
        var trimmedCommentsText = text
        matches.forEach {
            trimmedCommentsText = trimmedCommentsText
                .replacingOccurrences(of: nsString.substring(with: $0.range), with: "")
        }
        return trimmedCommentsText
    }
}

extension URLRequest {
    init(url: URL, netrc: Netrc?) {
        self.init(url: url)
        if let netrc = netrc {
            self.configure(with: netrc)
        }
    }

    mutating func configure(with netrc: Netrc) {
        guard let url = self.url else {
            return
        }

        guard let authorization = netrc.authorization(for: url) else {
            return
        }

        self.setValue(authorization, forHTTPHeaderField: "Authorization")
    }
}

fileprivate extension Array where Element == String {
    subscript(_ token: String) -> String? {
        guard let tokenIndex = firstIndex(of: token),
            count > tokenIndex,
            !["machine", "login", "password"].contains(self[tokenIndex + 1]) else {
                return nil
        }
        return self[tokenIndex + 1]
    }
}
