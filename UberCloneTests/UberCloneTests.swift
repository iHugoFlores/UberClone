//
//  UberCloneTests.swift
//  UberCloneTests
//
//  Created by Hugo Flores Perez on 7/27/20.
//  Copyright © 2020 Hugo Flores Perez. All rights reserved.
//

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import UberClone

struct TestModel: Decodable {
    let test: String
}

class UberCloneTests: XCTestCase {
    func test2Example() throws {
        guard let gitUrl = URL(string: "https://api.github.com/users/shashikant86") else { return }
        let promise = expectation(description: "Simple Request")
        stub(condition: isHost("api.github.com")) { _ in
            let stubPath = OHPathForFile("test.json", type(of: self))
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options:[])
                print(json)
                if let result = json as? NSDictionary {
                    XCTAssertTrue(result["name"] as! String == "Shashikant")
                    XCTAssertTrue(result["location"] as! String == "London")
                    promise.fulfill()
                }
            } catch let err {
                print("Err", err)
            }
        }.resume()
        waitForExpectations(timeout: 5, handler: nil)
    }
}
