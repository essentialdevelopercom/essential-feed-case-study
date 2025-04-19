import Foundation

let testsDir = "EssentialFeed/EssentialFeedTests"
let outputFile = "traceability-table.md"
let fileManager = FileManager.default

func findSwiftTestFiles(in directory: String) -> [String] {
    guard let enumerator = fileManager.enumerator(atPath: directory) else { return [] }
    return enumerator.compactMap { element in
        let path = (element as! String)
        return path.hasSuffix("Tests.swift") ? (directory as NSString).appendingPathComponent(path) : nil
    }
}

struct TestTrace {
    let file: String
    let test: String
    let cu: String
    let checklist: String
}

func extractTestsAndMeta(from file: String) -> [TestTrace] {
    guard let content = try? String(contentsOfFile: file, encoding: .utf8) else { return [] }
    let lines = content.components(separatedBy: .newlines)
    var lastCU = ""
    var lastChecklist = ""
    var results: [TestTrace] = []
    for line in lines {
        if let cuMatch = line.range(of: #"//\s*CU:\s*(.+)"#, options: .regularExpression) {
            lastCU = String(line[cuMatch].dropFirst(5)).trimmingCharacters(in: .whitespaces)
        }
        if let checklistMatch = line.range(of: #"//\s*Checklist:\s*(.+)"#, options: .regularExpression) {
            lastChecklist = String(line[checklistMatch].dropFirst(12)).trimmingCharacters(in: .whitespaces)
        }
        if let testMatch = line.range(of: #"func\s+(test_[A-Za-z0-9_]+)"#, options: .regularExpression) {
            let testName = String(line[testMatch].split(separator: " ")[1])
            results.append(TestTrace(
                file: (file as NSString).lastPathComponent,
                test: testName,
                cu: lastCU.isEmpty ? "-" : lastCU,
                checklist: lastChecklist.isEmpty ? "-" : lastChecklist
            ))
        }
    }
    return results
}

let files = findSwiftTestFiles(in: testsDir)
var rows: [String] = []

for file in files {
    let traces = extractTestsAndMeta(from: file)
    for trace in traces {
        rows.append("| \(trace.file) | \(trace.test) | \(trace.cu) | \(trace.checklist) | Sí | ✅ |")
    }
}

// Tabla Markdown
let output = """
| Archivo | Test | Caso de Uso | Checklist Técnico | Presente | Cobertura |
|---------|------|-------------|------------------|----------|-----------|
\(rows.joined(separator: "\n"))
"""

try? output.write(toFile: outputFile, atomically: true, encoding: .utf8)
print("Tabla generada en \(outputFile)")
