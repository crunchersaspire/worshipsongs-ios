//
// Author: James Selvakumar
// Since: 3.0.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import Quick
import Nimble
import SwiftyJSON
@testable import worshipsongs

class OpenLPServiceConverterSpec : QuickSpec {
    override func spec() {
        describe("OpenLPServiceConverter") {
            let openLPServiceConverter = OpenLPServiceConverter()
            let songsModel: [Songs] = DatabaseHelper().getSongModel()
            var favouriteList: [FavoritesSongsWithOrder]!
            var expectedJson: JSON!
            var result: JSON!
            
            describe("Convert favourite list to OpenLP Service Lite JSON format") {
                context("given a favourite list exist with some songs") {
                    beforeEach {
                        print(songsModel[0].title)
                        print(songsModel[1].title)
                        
                        let favouriteSong1 = FavoritesSongsWithOrder(orderNo: 1, songName: songsModel[0].title, songListName: "foo")
                        let favouriteSong2 = FavoritesSongsWithOrder(orderNo: 2, songName: songsModel[1].title, songListName: "foo")
                        favouriteList = [favouriteSong1, favouriteSong2]
                    }
                    
                    context("and a oszl (OpenLP Service Lite) json generated by OpenLP exists for the same songs in the same order") {
                        beforeEach {
                            let bundle = Bundle(for: type(of: self))
                            let path = bundle.path(forResource: "sample", ofType: "osj")!
                            let jsonData = NSData(contentsOfFile: path)!
                            //let jsonString = String(data: jsonData as Data, encoding: .utf8)
                            expectedJson = try! JSON(data: jsonData as Data)
                            print("Expected Json:\n \(expectedJson)")
                        }
                        
                        context("when converting the favourite list to oszl json format") {
                            beforeEach {
                                result = openLPServiceConverter.toOszlJson(favouriteList: favouriteList!)
                            }
                            
                            it("should have a top level array with three elements") {
                                expect(result.count).to(equal(expectedJson.count))
                            }
                            
                            it("the first element of the array should have general service info") {
                                let generalServiceInfo = result[0]
                                let openlpCore = generalServiceInfo["openlp_core"]
                                
                                expect(openlpCore["lite_service"].bool).to(beTrue())
                                expect(openlpCore["service_theme"].string).to(beEmpty())
                            }
                        }
                    }
                }
            }            
        }
    }
}
