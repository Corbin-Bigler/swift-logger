// The Swift Programming Language
// https://docs.swift.org/swift-book

import OSLog
import Combine

public final class Logger: @unchecked Sendable {
    static private let logger = os.Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.lionenergy.logging", category: "general")
    private static var isPreview: Bool { ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" }
    public static let shared = Logger()
    
    private let subject = PassthroughSubject<Log, Never>()
    
    private let queue = DispatchQueue(label: "Logger.queue")
    private var subjects: [String: PassthroughSubject<Log, Never>] = [:]
    
    public let level: LogLevel
    public init(level: LogLevel = {
        #if DEBUG
        return .debug
        #else
        return .info
        #endif
    }()) {
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
    
    public func log(tag: String? = nil, _ message: Any, level: LogLevel, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        let tag = tag ?? file.split(separator: "/").last?.split(separator: ".").first.flatMap { String($0) } ?? file
        log(Log(tag: tag, message: "\(message)", level: level, secure: secure, metadata:  ["file": file,"fileID": fileID,"line": line,"column": column,"function": function]))
    }
    public func fault(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .fault, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public func error(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .error, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public func info(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .info, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public func debug(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .debug, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    
    public static func log(tag: String? = nil, _ message: Any, level: LogLevel, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        shared.log(tag: tag, message, level: level, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func fault(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .fault, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func error(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .error, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func info(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .info, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func debug(tag: String? = nil, _ message: Any, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(tag: tag, message, level: .debug, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
}
