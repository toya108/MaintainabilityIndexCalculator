import XCTest
import class Foundation.Bundle
import SwiftSyntax
import SwiftSyntaxParser
@testable import MaintainabilityIndexCalculator

final class MaintainabilityIndexCalculatorTests: XCTestCase {

    func testsOperators() throws {
        let source = """
            let a = 1 * 2 + 3 * 2
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.operators, ["*", "+", "*"])
    }

    func testsDistinctOperators() throws {
        let source = """
            let a = 1 * 2 + 3 * 2
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.distinctOperators, ["*", "+"])
    }

    func testsOperands() throws {
        let source = """
            let a = 1 * 2 + 3 * 2
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.operands, ["a", "=", "1", "2", "3", "2"])
    }

    func testsDistinctOperands() throws {
        let source = """
            let a = 1 * 2 + 3 * 2
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.distinctOperands, ["a", "=", "1", "2", "3"])
    }

    func testsIfCyclomaticComplecity() throws {
        let source = """
            if foo {
                print(hoge)
            }
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 2)
    }

    func testsIfCaseCyclomaticComplecity() throws {
        let source = """
            if case .foo = hoo {
                print(".foo")
            }
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 2)
    }

    func testsSwitchCyclomaticComplecity() throws {
        let source = """
            let foo = 1
            switch foo {
                case 0:
                    print(zero)
                case 1:
                    print(one)
            }
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 4)
    }

    func testsForCyclomaticComplecity() throws {
        let source = """
            for i in 1..<10 {
                print(i)
            }
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 2)
    }

    func testsGuardCyclomaticComplecity() throws {
        let source = """
            guard let foo = foo else {
                return
            }
            print(foo)
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 2)
    }

    func testsGuardCaseCyclomaticComplecity() throws {
        let source = """
            guard case .foo = hoo else {
                return
            }
            print(".foo")
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 2)
    }

    func testsWhileCyclomaticComplecity() throws {
        let source = """
            var i = 0
            while i == 5 {
                print(i)
                i += 1
            }
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 2)
    }

    func testsRepeatWhileCyclomaticComplecity() throws {
        let source = """
            var i = 1
            repeat {
                print(i)
                i += 1
            } while(i < 1)
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 2)
    }


    func testsCaseCyclomaticComplecity() throws {
        let source = """
            if case .foo = hoo {
                return 1
            }
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 2)
    }

    func testsForEachCyclomaticComplecity() throws {
        let source = """
            foo.forEach {
                print($0)
            }
        """
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        let visitor = MaintainabilityIndexVisitor()
        visitor.walk(sourceFile)

        XCTAssertEqual(visitor.cyclomaticComplecity, 2)
    }

    func testsLineOfCode() throws {
        let source = """
            for i in 1..<10 {  // 1
                print(i)       // 2
            }                  // 3

            if foo {           // 4
                print("true")  // 5
            } else {           // 6
                print("false") // 7
            }                  // 8
        """
        XCTAssertEqual(getLineOfCode(source: source), 8)
    }
}
