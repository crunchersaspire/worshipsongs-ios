//
// Author: James Selvakumar
// Since: 3.0.0
// Copyright © 2021 mCruncher. All rights reserved.
// 

import Foundation
import SwiftyJSON

class OpenLPServiceConverter : IOpenLPServiceConverter {
    private let databaseHelper = DatabaseHelper()
    
    func toOszlJson(favouriteList: [FavoritesSongsWithOrder]) -> JSON {
        var openLPService = [getGeneralServiceInfo()]
        for favouriteSong in favouriteList {
            let songs = databaseHelper.findSongsByTitles([favouriteSong.songName])
            if songs.count > 0 {
                openLPService.append(getServiceItem(forSong: songs[0]))
            }
        }
        return JSON(openLPService)
    }
    
    private func getGeneralServiceInfo() -> [String: Any?] {
        let openLPCoreInfo = ["lite_service": true, "service_theme": ""] as [String: Any?]
        let generalServiceInfo = ["openlp_core": openLPCoreInfo] as [String: Any?]
        return generalServiceInfo
    }
    
    private func getServiceItem(forSong song: Songs) -> [String: Any?] {
        let serviceItem = ["serviceitem": getServiceItemHeader(forSong: song)] as [String: Any?]
        return serviceItem
    }
    
    // The elements are ordered based on the OpenLP api.
    // Ref: https://gitlab.com/openlp/openlp/-/blob/master/openlp/core/lib/serviceitem.py
    private func getServiceItemHeader(forSong song: Songs) -> [String: Any?] {
        let serviceItemHeaderContent  = [
            "name": "songs",
            "plugin": "songs",
            "theme": NSNull(),
            "title": song.title,
            "footer": getFooter(forSong: song),
            "type": 1, // not sure what is this, need to check OpenLP docs
            "icon": ":/plugins/plugin_songs.png",
            "audit": getAudit(forSong: song),
            "notes": "",
            "from_plugin": false,
            "capabilities": [2, 1, 5, 8, 9, 13], // not sure what is this, need to check OpenLP docs
            "search": "",
            "data": getData(forSong: song),
            "xml_version": getXmlVersion(ofSong: song),
            "auto_play_slides_once": false,
            "auto_play_slides_loop": false,
            "timed_slide_interval": 0,
            "start_time": 0,
            "end_time": 0,
            "media_length": 0,
            "background_audio": [],
            "theme_overwritten": false,
            "will_auto_start": false,
            "processor": NSNull()
        ] as [String : Any?]
        
        let serviceItemHeader = [
            "header": serviceItemHeaderContent
        ] as [String: Any?]
        return serviceItemHeader
    }
    
    private func getFooter(forSong song: Songs) -> [String] {
        let footer = [song.title, "Written by: "]
        return footer
    }
    
    private func getAudit(forSong song: Songs) -> [Any] {
        let audit = [song.title, [""], "", ""] as [Any]
        return audit
    }
    
    private func getData(forSong song: Songs) -> [String : String] {
        let data = [
            "title": "\(song.title.lowercased())@\(song.alternateTitle.lowercased())",
            "authors": ""
        ]
        return data
    }
    
    private func getXmlVersion(ofSong song: Songs) -> String {
        return ""
    }
}
