//
// Author: James Selvakumar
// Since: 3.0.0
// Copyright © 2021 mCruncher. All rights reserved.
//

import Foundation
import Quick
import Nimble
import SwiftyJSON
import AEXML
@testable import worshipsongs

class ConvertFavouritesToOpenLPServiceAcceptanceSpec : QuickSpec {
    override func spec() {
        let openLPServiceConverter = OpenLPServiceConverter()
        let databaseHelper = DatabaseHelper()
        var favouriteList: [FavoritesSong]!
        var song1: Songs!
        var song2: Songs!
        var expectedJson: JSON!
        var result: JSON!
        
        beforeEach {
            song1 = databaseHelper.findSongs(byTitle: "Amazing Grace")[0]
            song2 = databaseHelper.findSongs(byTitle: "God is good")[0]
        }
        
        describe("Convert favourite list to OpenLP Service Lite JSON format") {
            context("given a favourite list exist with some songs") {
                beforeEach {
                    let song1WithOrder = FavoritesSongsWithOrder(orderNo: 1, songName: song1.title, songListName: "foo")
                    let song2WithOrder = FavoritesSongsWithOrder(orderNo: 2, songName: song2.title, songListName: "foo")
                    favouriteList = [FavoritesSong(songTitle: song1.title, songs: song1, favoritesSongsWithOrder: song1WithOrder), FavoritesSong(songTitle: song2.title, songs: song2, favoritesSongsWithOrder: song2WithOrder)]
                }
                
                context("and a oszl (OpenLP Service Lite) json generated by OpenLP exists for the same songs in the same order") {
                    beforeEach {
                        let bundle = Bundle(for: type(of: self))
                        let path = bundle.path(forResource: "openlp-service-lite", ofType: "osj")!
                        let jsonData = NSData(contentsOfFile: path)!
                        expectedJson = try! JSON(data: jsonData as Data)
                        print("Expected JSON:\n \(expectedJson!)")
                    }
                    
                    context("when converting the favourite list to oszl json format") {
                        beforeEach {
                            result = openLPServiceConverter.toOszlJson(favouriteList: favouriteList!)
                            print("Actual JSON:\n \(result.rawString()!)")
                        }
                        
                        it("should have a top level array with three elements") {
                            expect(result.count).to(equal(expectedJson.count))
                        }
                        
                        it("should have general service info as the first element of the array") {
                            let generalServiceInfo = result[0]
                            let openlpCore = generalServiceInfo["openlp_core"]
                            
                            expect(openlpCore["lite_service"].bool).to(beTrue())
                            expect(openlpCore["service_theme"]).to(beEmpty())
                        }
                        
                        it("should have a service header for the first song") {
                            let expectedSongTitle = "Amazing Grace (my chains are gone)"
                            let expectedAuthor = "John Newton"
                            
                            let serviceItem = result[1]["serviceitem"]
                            let serviceItemHeader = serviceItem["header"]
                            
                            print("No. of elements in service item header: \(serviceItemHeader.count)")
                            expect(serviceItemHeader.count).to(equal(expectedJson[1]["serviceitem"]["header"].count))
                            
                            expect(serviceItemHeader["name"]).to(equal("songs"))
                            expect(serviceItemHeader["plugin"]).to(equal("songs"))
                            expect(serviceItemHeader["theme"].null).to(beAnInstanceOf(NSNull.self))
                            expect(serviceItemHeader["title"].string).to(equal(expectedSongTitle))
                            
                            let footer = serviceItemHeader["footer"]
                            expect(footer.count).to(equal(2))
                            expect(footer[0].string).to(equal(expectedSongTitle))
                            expect(footer[1].string).to(equal("Written by: \(expectedAuthor)"))
                            
                            expect(serviceItemHeader["type"]).to(equal(1))
                            expect(serviceItemHeader["icon"]).to(equal(":/plugins/plugin_songs.png"))
                            
                            let audit = serviceItemHeader["audit"]
                            let expectedAudit = expectedJson[1]["serviceitem"]["header"]["audit"]
                            expect(audit.count).to(equal(expectedAudit.count))
                            expect(audit[0].string).to(equal(expectedSongTitle))
                            expect(audit[1]).to(equal(["\(expectedAuthor)"]))
                            expect(audit[2]).to(equal(""))
                            expect(audit[3]).to(equal(""))
                            
                            expect(serviceItemHeader["notes"]).to(equal(""))
                            expect(serviceItemHeader["from_plugin"].bool).to(beFalse())
                            expect(serviceItemHeader["capabilities"]).to(equal([2, 1, 5, 8, 9, 13]))
                            expect(serviceItemHeader["search"]).to(equal(""))
                            
                            let data = serviceItemHeader["data"]
                            let expectedData = expectedJson[1]["serviceitem"]["header"]["data"]
                            expect(data.count).to(equal(2))
                            expect(data["title"].string).to(equal(expectedData["title"].string))
                            expect(data["authors"].string).to(equal(expectedData["authors"].string))
                            
                            let expectedXmlVersion = expectedJson[1]["serviceitem"]["header"]["xml_version"].string!
                            let actualXmlVersion = serviceItemHeader["xml_version"].string!
                            print("Expected xml: \n \(expectedXmlVersion)")
                            print("Actual xml: \n \(actualXmlVersion)")
                            expect(actualXmlVersion).toNot(beEmpty())
                            
                            expect(serviceItemHeader["auto_play_slides_once"].bool).to(beFalse())
                            expect(serviceItemHeader["auto_play_slides_loop"].bool).to(beFalse())
                            expect(serviceItemHeader["timed_slide_interval"]).to(equal(0))
                            expect(serviceItemHeader["start_time"]).to(equal(0))
                            expect(serviceItemHeader["end_time"]).to(equal(0))
                            expect(serviceItemHeader["media_length"]).to(equal(0))
                            expect(serviceItemHeader["background_audio"]).to(equal([]))
                            expect(serviceItemHeader["theme_overwritten"].bool).to(beFalse())
                            expect(serviceItemHeader["will_auto_start"].bool).to(beFalse())
                            expect(serviceItemHeader["processor"].null).to(beAnInstanceOf(NSNull.self))
                        }
                        
                        it("should have a data element for the first song") {
                            let data = result[1]["serviceitem"]["data"]
                            print("Data: \(data)")
                            
                            let expectedData = expectedJson[1]["serviceitem"]["data"]
                            
                            expect(data.count).to(equal(8))
                            
                            expectedData.enumerated().forEach {index, element in
                                expect(data[index]["title"].string).to(equal(expectedData[index]["title"].string))
                                expect(data[index]["verseTag"].string).to(equal(expectedData[index]["verseTag"].string))
                                expect(data[index]["raw_slide"].string).to(equal(expectedData[index]["raw_slide"].string))
                            }
                        }
                        
                        it("should have a service header for the second song") {
                            let expectedSongTitle = "God Is Good All The Time"
                            let expectedAuthor1 = "Don Moen"
                            let expectedAuthor2 = "Paul Overstreet"
                            
                            let serviceItem = result[2]["serviceitem"]
                            let serviceItemHeader = serviceItem["header"]
                            
                            print("No. of elements in service item header: \(serviceItemHeader.count)")
                            expect(serviceItemHeader.count).to(equal(expectedJson[1]["serviceitem"]["header"].count))
                            
                            expect(serviceItemHeader["name"]).to(equal("songs"))
                            expect(serviceItemHeader["plugin"]).to(equal("songs"))
                            expect(serviceItemHeader["theme"].null).to(beAnInstanceOf(NSNull.self))
                            expect(serviceItemHeader["title"].string).to(equal(expectedSongTitle))
                            
                            let footer = serviceItemHeader["footer"]
                            expect(footer.count).to(equal(2))
                            expect(footer[0].string).to(equal(expectedSongTitle))
                            expect(footer[1].string).to(equal("Written by: \(expectedAuthor1) and \(expectedAuthor2)"))
                            
                            expect(serviceItemHeader["type"]).to(equal(1))
                            expect(serviceItemHeader["icon"]).to(equal(":/plugins/plugin_songs.png"))
                            
                            let audit = serviceItemHeader["audit"]
                            expect(audit.count).to(equal(4))
                            expect(audit[0].string).to(equal(expectedSongTitle))
                            expect(audit[1]).to(equal([expectedAuthor1, expectedAuthor2]))
                            expect(audit[2]).to(equal(""))
                            expect(audit[3]).to(equal(""))
                            
                            expect(serviceItemHeader["notes"]).to(equal(""))
                            expect(serviceItemHeader["from_plugin"].bool).to(beFalse())
                            expect(serviceItemHeader["capabilities"]).to(equal([2, 1, 5, 8, 9, 13]))
                            expect(serviceItemHeader["search"]).to(equal(""))
                            
                            let data = serviceItemHeader["data"]
                            let expectedData = expectedJson[2]["serviceitem"]["header"]["data"]
                            expect(data.count).to(equal(2))
                            expect(data["title"].string).to(equal(expectedData["title"].string))
                            expect(data["authors"].string).to(equal(expectedData["authors"].string))
                            
                            expect(serviceItemHeader["xml_version"].string).toNot(beEmpty())
                            
                            expect(serviceItemHeader["auto_play_slides_once"].bool).to(beFalse())
                            expect(serviceItemHeader["auto_play_slides_loop"].bool).to(beFalse())
                            expect(serviceItemHeader["timed_slide_interval"]).to(equal(0))
                            expect(serviceItemHeader["start_time"]).to(equal(0))
                            expect(serviceItemHeader["end_time"]).to(equal(0))
                            expect(serviceItemHeader["media_length"]).to(equal(0))
                            expect(serviceItemHeader["background_audio"]).to(equal([]))
                            expect(serviceItemHeader["theme_overwritten"].bool).to(beFalse())
                            expect(serviceItemHeader["will_auto_start"].bool).to(beFalse())
                            expect(serviceItemHeader["processor"].null).to(beAnInstanceOf(NSNull.self))
                        }
                        
                        it("should have a data element for the second song") {
                            let data = result[2]["serviceitem"]["data"]
                            print("Data: \(data)")
                            
                            let expectedData = expectedJson[2]["serviceitem"]["data"]
                            
                            expect(data.count).to(equal(13))
                            
                            expectedData.enumerated().forEach {index, element in
                                expect(data[index]["title"].string).to(equal(expectedData[index]["title"].string?.toAscii()))
                                expect(data[index]["verseTag"].string).to(equal(expectedData[index]["verseTag"].string))
                                expect(data[index]["raw_slide"].string).to(equal(expectedData[index]["raw_slide"].string?.toAscii()))
                            }
                        }
                    }
                }
            }
        }
    }
}
