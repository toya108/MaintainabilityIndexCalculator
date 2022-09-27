import Accelerate
import SwiftSyntax
import SwiftSyntaxParser

try CommandLine.arguments.forEach { argument in
    if argument == ".build/arm64-apple-macosx/debug/MaintainabilityIndexCalculator" {
        // Unnecessary arguments are passed first, so return here.
        return
    }

    let url = URL(fileURLWithPath: argument)
    let fileData = try Data(contentsOf: url)
    let source = fileData.withUnsafeBytes { buf in
        return String(decoding: buf.bindMemory(to: UInt8.self), as: UTF8.self)
    }
    let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
    let visitor = MaintainabilityIndexVisitor()
    visitor.walk(sourceFile)

    let halsteadVolume = visitor.calcHalsteadVolume()

    let cyclomaticComplexity = visitor.cyclomaticComplecity

    let lineOfCode = getLineOfCode(source: source)

    let rebasedHalsteadVolume = 5.2 * log(Double(halsteadVolume))
    let rebasedCyclomaticComplexity = 0.23 * Double(cyclomaticComplexity)
    let rebasedLineOfCode = 16.2 * log(Double(lineOfCode))
    let maitainabilityIndex = max(0, CGFloat(171 - rebasedHalsteadVolume - rebasedCyclomaticComplexity - rebasedLineOfCode) * 100 / 171)
    print("""
    ------------------------------------------------------------
    source: \(argument)
    halstead_volume: \(halsteadVolume)
    cyclomatic_complexity: \(cyclomaticComplexity)
    line_of_code: \(lineOfCode)
    maitainability_index: \(maitainabilityIndex)
    ------------------------------------------------------------
    """)
}

func getLineOfCode(source: String) -> Int {
    source.split(separator: "\n").count
}

class MaintainabilityIndexVisitor: SyntaxVisitor {

    var operators: [String] = []
    var distinctOperators: Set<String> {
        Set(operators)
    }
    var operands: [String] = []
    var distinctOperands: Set<String> {
        Set(operands)
    }

    var cyclomaticComplecity = 1

    override func visit(_ node: TokenSyntax) -> SyntaxVisitorContinueKind {
        switch node.tokenKind {
            case .spacedBinaryOperator, .unspacedBinaryOperator, .prefixOperator, .postfixOperator:
                operators.append(node.text)
            default:
                // Add non-reserved words to operands
                if !node.tokenKind.isKeyword && !node.text.isEmpty {
                    operands.append(node.text)
                }
        }

        switch node.tokenKind {
            case .ifKeyword, .switchKeyword, .forKeyword, .whileKeyword, .guardKeyword:
                cyclomaticComplecity += 1
            case .caseKeyword:
                if let previousToken = node.previousToken,
                   previousToken.tokenKind == .ifKeyword || previousToken.tokenKind == .guardKeyword {
                    // `if case` and `guard case` are considered as one branch
                    break
                }
                cyclomaticComplecity += 1
            case .identifier(let identifier):
                // swiftlint hadle `forEach`
                // https://github.com/realm/SwiftLint/blob/fd7afedfcfe73443a95041fdc51c31d071b97910/Source/SwiftLintFramework/Rules/RuleConfigurations/CyclomaticComplexityConfiguration.swift#L15
                if identifier == "forEach" {
                    cyclomaticComplecity += 1
                }
            default:
                break
        }
        return .skipChildren
    }

    func calcHalsteadVolume() -> Float {
        let calculatar = HalseadVolumeCalculatar(
            operators: operators,
            distinctOperators: distinctOperators,
            operands: operands,
            distinctOperands: distinctOperands
        )
        return calculatar.halsteadVolume
    }
}

struct HalseadVolumeCalculatar {
    let operators: [String]
    let distinctOperators: Set<String>
    let operands: [String]
    let distinctOperands: Set<String>

    var vocabulary: Float {
        Float(distinctOperators.count + distinctOperands.count)
    }

    var length: Float {
        Float(operators.count + operands.count)
    }

    var halsteadVolume: Float {
        length * log2(vocabulary)
    }
}
