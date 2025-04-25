// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public class Logger {
    static nonisolated(unsafe) private var level: LogLevel = .debug
    @MainActor static func set(level: LogLevel) {
        self.level = level
    }
    
    static func log(_ log: Log) {
        if log.level.rawValue <= level.rawValue {
            print("[\(log.tag)] \(log.message)")
        }
    }
    
    public static func log(_ message: Any, tag: String = #file, level: LogLevel, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(Log(tag: tag, message: "\(message)", level: level, secure: secure, metadata:  ["file": file,"fileID": fileID,"line": line,"column": column,"function": function]))
    }
    public static func fault(_ message: Any, tag: String? = nil, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(message, tag: tag ?? file, level: .fault, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func error(_ message: Any, tag: String? = nil, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(message, tag: tag ?? file, level: .error, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func info(_ message: Any, tag: String? = nil, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(message, tag: tag ?? file, level: .info, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
    public static func debug(_ message: Any, tag: String? = nil, secure: Bool = false, file: String = #file, fileID: String = #fileID, line: Int = #line, column: Int = #column, function: String = #function) {
        log(message, tag: tag ?? file, level: .debug, secure: secure, file: file, fileID: fileID, line: line, column: column, function: function)
    }
}
