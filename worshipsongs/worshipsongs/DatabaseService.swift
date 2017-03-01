//
//  DatabaseService.swift
//  worshipsongs
//
//  Created by Vignesh Palanisamy on 27/02/2017.
//  Copyright © 2017 Vignesh Palanisamy. All rights reserved.
//

import Foundation

class DatabaseService {
    
    fileprivate let commonService = CommonService()
    let preferences = UserDefaults.standard
    
    func restoreDatabase() {
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        
        if FileManager.default.fileExists(atPath: defaultUrl) {
            if FileManager.default.fileExists(atPath: cacheUrl) {
                try! FileManager.default.removeItem(atPath: cacheUrl)
            }
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: cacheUrl) as URL)
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: defaultUrl) as URL, to: NSURL(fileURLWithPath: databaseUrl) as URL)
            try! FileManager.default.removeItem(atPath: cacheUrl)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "onAfterUpdateDatabase"), object: nil,  userInfo: nil)
        }
        self.preferences.set(true, forKey: "defaultDatabase")
        self.preferences.synchronize()
    }
    
    func revertImport() {
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        if FileManager.default.fileExists(atPath: databaseUrl) {
            try! FileManager.default.removeItem(atPath: databaseUrl)
        }
        if FileManager.default.fileExists(atPath: cacheUrl) {
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: cacheUrl) as URL, to: NSURL(fileURLWithPath: databaseUrl) as URL)
        } else {
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: defaultUrl) as URL, to: NSURL(fileURLWithPath: databaseUrl) as URL)
            self.preferences.set(true, forKey: "defaultDatabase")
            self.preferences.synchronize()
        }
    }
    
    func importDatabase(url: URL) {
        self.preferences.set(true, forKey: "database.lock")
        self.preferences.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "onBeforeUpdateDatabase"), object: nil,  userInfo: nil)
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        if !FileManager.default.fileExists(atPath: defaultUrl) {
            try! FileManager.default.copyItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: defaultUrl) as URL)
            Downloader.load(url: url , to: NSURL(fileURLWithPath: databaseUrl) as URL, completion: {
                () -> Void in
            })
        } else {
            if FileManager.default.fileExists(atPath: cacheUrl) {
                try! FileManager.default.removeItem(atPath: cacheUrl)
            }
            try! FileManager.default.copyItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: cacheUrl) as URL)
            Downloader.load(url: url , to: NSURL(fileURLWithPath: databaseUrl) as URL, completion: {
                () -> Void in
                
            })
        }
    }
    
    func importDriveDatabase(url: URL) {
        self.preferences.set(true, forKey: "database.lock")
        self.preferences.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "onBeforeUpdateDatabase"), object: nil,  userInfo: nil)
        let databaseUrl = commonService.getDocumentDirectoryPath("songs.sqlite")
        let defaultUrl = commonService.getDocumentDirectoryPath("songs-bak.sqlite")
        let cacheUrl = commonService.getDocumentDirectoryPath("songs-cache.sqlite")
        if !FileManager.default.fileExists(atPath: defaultUrl) {
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: defaultUrl) as URL)
            try! FileManager.default.copyItem(at: url, to: NSURL(fileURLWithPath: databaseUrl) as URL)
        } else {
            if FileManager.default.fileExists(atPath: cacheUrl) {
                try! FileManager.default.removeItem(atPath: cacheUrl)
            }
            try! FileManager.default.moveItem(at: NSURL(fileURLWithPath: databaseUrl) as URL, to: NSURL(fileURLWithPath: cacheUrl) as URL)
            try! FileManager.default.copyItem(at: url, to: NSURL(fileURLWithPath: databaseUrl) as URL)
        }
        preferences.setValue("imported.sucessfully", forKey: "import.status")
        preferences.set(false, forKey: "defaultDatabase")
        preferences.set(false, forKey: "database.lock")
        preferences.synchronize()
    }
    
    func verifyDatabase() -> Bool {
        let databaseHelper = DatabaseHelper()
        let songModel = databaseHelper.getSongModel()
        return songModel.count > 0
    }
    
}