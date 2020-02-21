//
//  NYPLStringAdditionsTests.swift
//  SimplyETests
//
//  Created by Ettore Pasquini on 2/20/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import XCTest
@testable import SimplyE

class NYPLStringAdditionsTests: XCTestCase {
  func testURLEncodingQueryParam() {
    let multiASCIIWord = "Pinco Pallino".stringURLEncodedAsQueryParamValue()
    XCTAssertEqual(multiASCIIWord, "Pinco%20Pallino")

    let queryCharsSeparators = "?=&".stringURLEncodedAsQueryParamValue()
    XCTAssertEqual(queryCharsSeparators, "%3F%3D%26")

    let accentedVowels = "àèîóú".stringURLEncodedAsQueryParamValue()
    XCTAssertEqual(accentedVowels, "%C3%A0%C3%A8%C3%AE%C3%B3%C3%BA")

    let legacyEscapes = ";/?:@&=$+{}<>,".stringURLEncodedAsQueryParamValue()
    XCTAssertEqual(legacyEscapes, "%3B%2F%3F%3A%40%26%3D%24%2B%7B%7D%3C%3E%2C")

    let noEscapes = "-_".stringURLEncodedAsQueryParamValue()
    XCTAssertEqual(noEscapes, "-_")

    let otherEscapes = "~`!#%^*()[]|\\".stringURLEncodedAsQueryParamValue()
    XCTAssertEqual(otherEscapes, "~%60!%23%25%5E*()%5B%5D%7C%5C")
  }
}
