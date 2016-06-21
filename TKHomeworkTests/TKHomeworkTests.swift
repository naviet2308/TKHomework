//
//  TKHomeworkTests.swift
//  TKHomeworkTests
//
//  Created by NAV on 6/15/16.
//  Copyright © 2016 Nguyen Anh Viet. All rights reserved.
//

import XCTest
@testable import TKHomework

/** Todo list
 TODO: Method name: checkValidInput
 * - Test checkValidInput, should return true, when input valid
 * - Test checkValidInput, should return false, when input is empty
**/


class TKHomeworkTests: XCTestCase {
    
    var viewController : TKViewController!
    
    // Define Error Message
    let Error_Message_Invalid = "Invalid input"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("TKViewController") as! TKViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        viewController = nil
    }
    
    func testcheckValidInput_ShoudReturnTrue_WhenInputValid() {
        
        //GIVEN
        let input   = "01 Út Tịch"
        let result  : Bool!
        
        //WHEN
        result = viewController.checkValidInput(input)
        
        //THEN
        XCTAssertTrue(result, Error_Message_Invalid)
    }
    
    func testcheckValidInput_ShoudReturnFalse_WhenInputIsEmpty() {
        
        //GIVEN
        let input   = ""
        let result  : Bool!
        
        //WHEN
        result = viewController.checkValidInput(input)
        
        //THEN
        XCTAssertFalse(result, Error_Message_Invalid)
    }

    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
