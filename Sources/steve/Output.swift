import Foundation

enum UitoolExit: Int32 {
    case success = 0
    case notFound = 1
    case appNotFound = 2
    case timeout = 3
    case permissionDenied = 4
    case invalidArguments = 5
}

enum OutputFormat: String {
    case text
    case json
}

struct Output {
    static var format: OutputFormat = .text
    private static let labelKeys = ["title", "name", "label", "id"]

    static func configure(format: OutputFormat) {
        self.format = format
    }

    static func okPayload(_ data: Any? = nil) -> [String: Any] {
        if let data {
            return ["ok": true, "data": data]
        }
        return ["ok": true]
    }

    static func errorPayload(_ message: String) -> [String: Any] {
        ["ok": false, "error": message]
    }

    static func encode(_ obj: Any) -> Data? {
        try? JSONSerialization.data(withJSONObject: obj, options: [])
    }

    static func ok(_ data: Any? = nil, quiet: Bool = false) {
        guard !quiet else { return }
        switch format {
        case .json:
            printJSON(okPayload(data), to: FileHandle.standardOutput)
        case .text:
            printTextOk(data, to: FileHandle.standardOutput)
        }
    }

    static func error(_ message: String, quiet: Bool = false) {
        guard !quiet else { return }
        switch format {
        case .json:
            printJSON(errorPayload(message), to: FileHandle.standardError)
        case .text:
            printTextError(message, to: FileHandle.standardError)
        }
    }

    private static func printJSON(_ obj: Any, to handle: FileHandle) {
        guard let data = encode(obj) else {
            let fallback = "{\"ok\":false,\"error\":\"Failed to encode JSON\"}"
            if let fallbackData = fallback.data(using: .utf8) {
                handle.write(fallbackData)
                handle.write(Data("\n".utf8))
            }
            return
        }
        handle.write(data)
        handle.write(Data("\n".utf8))
    }

    private static func printTextOk(_ data: Any?, to handle: FileHandle) {
        guard let data else { return }
        if isScalar(data) {
            write(lines: [renderScalar(data)], to: handle)
            return
        }
        write(lines: renderText(data, indent: 0), to: handle)
    }

    private static func printTextError(_ message: String, to handle: FileHandle) {
        write(lines: ["error: \(message)"], to: handle)
    }

    private static func write(lines: [String], to handle: FileHandle) {
        let text = lines.joined(separator: "\n") + "\n"
        if let data = text.data(using: .utf8) {
            handle.write(data)
        }
    }

    private static func renderText(_ value: Any, indent: Int) -> [String] {
        if let dict = coerceDict(value) {
            return renderDict(dict, indent: indent)
        }
        if let array = coerceArray(value) {
            return renderArray(array, indent: indent)
        }
        let prefix = String(repeating: " ", count: indent)
        return [prefix + renderScalar(value)]
    }

    private static func isScalar(_ value: Any) -> Bool {
        if value is String { return true }
        if value is Bool { return true }
        if value is Int || value is Int32 || value is Int64 { return true }
        if value is UInt || value is UInt32 || value is UInt64 { return true }
        if value is Double || value is Float { return true }
        if value is NSNumber { return true }
        if value is NSNull { return true }
        return false
    }

    private static func renderScalar(_ value: Any) -> String {
        if let value = value as? String { return value }
        if let value = value as? Bool { return value ? "true" : "false" }
        if let value = value as? Int { return String(value) }
        if let value = value as? Int32 { return String(value) }
        if let value = value as? Int64 { return String(value) }
        if let value = value as? UInt { return String(value) }
        if let value = value as? UInt32 { return String(value) }
        if let value = value as? UInt64 { return String(value) }
        if let value = value as? Double { return String(value) }
        if let value = value as? Float { return String(value) }
        if let value = value as? NSNumber {
            if CFGetTypeID(value) == CFBooleanGetTypeID() {
                return value.boolValue ? "true" : "false"
            }
            return value.stringValue
        }
        if value is NSNull { return "null" }
        return String(describing: value)
    }

    private static func coerceDict(_ value: Any) -> [String: Any]? {
        if let dict = value as? [String: Any] { return dict }
        if let dict = value as? NSDictionary {
            var result: [String: Any] = [:]
            for (key, entry) in dict {
                let keyString = key as? String ?? String(describing: key)
                result[keyString] = entry
            }
            return result
        }
        return nil
    }

    private static func coerceArray(_ value: Any) -> [Any]? {
        if let array = value as? [Any] { return array }
        if let array = value as? NSArray { return array.map { $0 } }
        return nil
    }

    private static func renderDictItem(_ dict: [String: Any], indent: Int) -> [String] {
        let prefix = String(repeating: " ", count: indent)
        if let (labelKey, labelValue) = firstScalar(in: dict, keys: labelKeys) {
            var lines = [prefix + "- \(renderScalar(labelValue))"]
            let rest = dict.filter { $0.key != labelKey }
            if !rest.isEmpty {
                lines.append(contentsOf: renderText(rest, indent: indent + 2))
            }
            return lines
        }
        var lines = [prefix + "-"]
        lines.append(contentsOf: renderText(dict, indent: indent + 2))
        return lines
    }

    private static func renderDict(_ dict: [String: Any], indent: Int) -> [String] {
        let prefix = String(repeating: " ", count: indent)
        if dict.isEmpty { return [prefix + "{}"] }
        var lines: [String] = []
        for key in dict.keys.sorted() {
            guard let entry = dict[key] else { continue }
            if key == "frame", let inline = renderFrameInline(entry) {
                lines.append(prefix + inline)
            } else if key == "children", let flattened = flattenMenuChildren(entry) {
                lines.append(prefix + "children:")
                lines.append(contentsOf: renderText(flattened, indent: indent + 2))
            } else if isScalar(entry) {
                lines.append(prefix + "\(key): \(renderScalar(entry))")
            } else {
                lines.append(prefix + "\(key):")
                lines.append(contentsOf: renderText(entry, indent: indent + 2))
            }
        }
        return lines
    }

    private static func renderArray(_ array: [Any], indent: Int) -> [String] {
        let prefix = String(repeating: " ", count: indent)
        if array.isEmpty { return [prefix + "[]"] }
        var lines: [String] = []
        for item in array {
            if isScalar(item) {
                lines.append(prefix + "- \(renderScalar(item))")
            } else if let dict = coerceDict(item) {
                lines.append(contentsOf: renderDictItem(dict, indent: indent))
            } else {
                lines.append(prefix + "-")
                lines.append(contentsOf: renderText(item, indent: indent + 2))
            }
        }
        return lines
    }

    private static func firstScalar(in dict: [String: Any], keys: [String]) -> (String, Any)? {
        for key in keys {
            guard let value = dict[key] else { continue }
            if isScalar(value) {
                return (key, value)
            }
        }
        return nil
    }

    private static func renderFrameInline(_ value: Any) -> String? {
        guard let dict = coerceDict(value) else { return nil }
        guard let x = dict["x"], let y = dict["y"], let width = dict["width"], let height = dict["height"] else {
            return nil
        }
        return "frame: x=\(renderScalar(x)) y=\(renderScalar(y)) w=\(renderScalar(width)) h=\(renderScalar(height))"
    }

    private static func flattenMenuChildren(_ value: Any) -> Any? {
        guard let array = coerceArray(value), array.count == 1 else { return nil }
        guard let menu = coerceDict(array[0]) else { return nil }
        guard let role = menu["role"] as? String, role == "AXMenu" else { return nil }
        return menu["children"]
    }
}
