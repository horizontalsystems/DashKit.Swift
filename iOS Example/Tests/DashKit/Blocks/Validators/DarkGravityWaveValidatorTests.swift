@testable import BitcoinCore
import Cuckoo
@testable import DashKit
import XCTest

class DarkGravityWaveValidatorTests: XCTestCase {
    private let bitsArray = [0x1B10_4BE1, 0x1B10_E09E, 0x1B11_A33C, 0x1B12_1CF3, 0x1B11_951E, 0x1B11_ABAC, 0x1B11_8D9C, 0x1B11_23F9, 0x1B11_41BF, 0x1B11_0764,
                             0x1B10_7556, 0x1B10_4297, 0x1B10_63D0, 0x1B10_E878, 0x1B0D_FAFF, 0x1B0C_9AB8, 0x1B0C_03D6, 0x1B0D_D168, 0x1B10_B864, 0x1B0F_ED89,
                             0x1B11_3FF1, 0x1B10_460B, 0x1B13_B83F, 0x1B14_18D4]

    private let timestampArray = [1_408_728_124, 1_408_728_332, 1_408_728_479, 1_408_728_495, 1_408_728_608, 1_408_728_744, 1_408_728_756, 1_408_728_950, 1_408_729_116, 1_408_729_179,
                                  1_408_729_305, 1_408_729_474, 1_408_729_576, 1_408_729_587, 1_408_729_647, 1_408_729_678, 1_408_730_179, 1_408_730_862, 1_408_730_914, 1_408_731_242,
                                  1_408_731_256, 1_408_732_229, 1_408_732_257, 1_408_732_489] // 123433 - 123456

    private var validator: DarkGravityWaveValidator!
    private var mockBlockHelper: MockIDashBlockValidatorHelper!

    private var blocks = [Block]()

    override func setUp() {
        super.setUp()
        mockBlockHelper = MockIDashBlockValidatorHelper()

        validator = DarkGravityWaveValidator(encoder: DifficultyEncoder(), blockHelper: mockBlockHelper, heightInterval: 24, targetTimeSpan: 3600, maxTargetBits: 0x1E0F_FFFF, firstCheckpointHeight: 123_432)

        blocks.append(Block(
            withHeader: BlockHeader(
                version: 1,
                headerHash: Data(),
                previousBlockHeaderHash: Data(),
                merkleRoot: Data(),
                timestamp: 1_408_732_505,
                bits: 0x1B14_41DE,
                nonce: 1
            ),
            height: 123_457
        ))

        for i in 0 ..< 24 {
            let block = Block(
                withHeader: BlockHeader(version: 1, headerHash: Data(from: i), previousBlockHeaderHash: Data(from: i), merkleRoot: Data(), timestamp: timestampArray[timestampArray.count - i - 1], bits: bitsArray[bitsArray.count - i - 1], nonce: 0),
                height: blocks[0].height - i - 1
            )
            blocks.append(block)
        }
        stub(mockBlockHelper) { mock in
            for i in 0 ..< 24 {
                when(mock.previous(for: equal(to: blocks[i]), count: 1)).thenReturn(blocks[i + 1])
            }
        }
    }

    override func tearDown() {
        validator = nil
        mockBlockHelper = nil

        blocks.removeAll()

        super.tearDown()
    }

    func testValidate() {
        do {
            try validator.validate(block: blocks[0], previousBlock: blocks[1])
        } catch {
            XCTFail("\(error) Exception Thrown")
        }
    }

    func testTrust() {
        do {
            try validator.validate(block: blocks[1], previousBlock: blocks[2])
        } catch {
            XCTFail("\(error) Exception Thrown")
        }
    }
}
