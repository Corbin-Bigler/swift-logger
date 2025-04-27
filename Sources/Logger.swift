// The Swift Programming Language
// https://docs.swift.org/swift-book

import OSLog
import Combine

public final class Logger {
    static private let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.lionenergy.logging", category: "general")
    private static var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    nonisolated(unsafe) public static let shared = Logger()
    
    private let subject = PassthroughSubject<Log, Never>()
    
    private let queue = DispatchQueue(label: "Logger.queue")
    private var subjects: [String: PassthroughSubject<Log, Never>] = [:]
    
    public let level: LogLevel
    public init(level: LogLevel = .info) {
        self.level = level
    }
    
    public func subject(tag: String? = nil) -> PassthroughSubject<Log, Never> {
        queue.sync {
            guard let tag else { return subject }
            if let subject = subjects[tag] { return subject }
            let subject = PassthroughSubject<Log, Never>()
            subjects[tag] = subject
            return subject
        }
    }
    
    func log(_ log: Log) {
        if let subject = queue.sync(execute: {subjects[log.tag]}) {
            subject.send(log)
        }
        
        if log.level.rawValue <= level.rawValue {
            if Self.isPreview {
                print(log.formatted)
            } else {
                Self.logger.log(level: log.level.osLogType, "\(log.formatted, privacy: .private)")
            }
        }
    }
    
    public func log(_ message: Any, tag: String = #file, level: LogLevel, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(Log(tag: tag, message: "\(message)", level: level, secure: secure, metadata:  ["file": file,"fileID": fileID,"line": line,"column": column,"function": function]))
    }
    public func fault(_ message: Any, tag: String? = nil, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(message, tag: tag ?? file, level: .fault, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public func error(_ message: Any, tag: String? = nil, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(message, tag: tag ?? file, level: .error, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public func info(_ message: Any, tag: String? = nil, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(message, tag: tag ?? file, level: .info, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public func debug(_ message: Any, tag: String? = nil, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(message, tag: tag ?? file, level: .debug, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    
    static private func format(tag raw: String) -> String {
        let filename = raw.split(separator: "/").last?.replacingOccurrences(of: ".swift", with: "") ?? raw
        return filename
    }
}
