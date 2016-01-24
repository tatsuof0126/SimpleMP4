//
//  ConfigManager.swift
//  SimpleMP4
//
//  Created by 藤原 達郎 on 2016/01/07.
//  Copyright (c) 2016年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import Photos

class ConfigManager: NSObject {
    
    class func getExportPreset() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        let retString:String? = defaults.stringForKey("EXPORT_PRESET")
        if(retString == nil){
            return AVAssetExportPresetHighestQuality
        }
        return retString!
    }

    class func getExportPresetString() -> String {
        let exportPreset = ConfigManager.getExportPreset()
        if(exportPreset == AVAssetExportPresetHighestQuality){
            return "高品質"
        } else if (exportPreset == AVAssetExportPresetMediumQuality){
            return "中品質"
        } else if (exportPreset == AVAssetExportPresetLowQuality){
            return "低品質"
        }
        return ""
    }
    
    class func setExportPreset(exportPreset : String){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(exportPreset, forKey: "EXPORT_PRESET")
        defaults.synchronize()
    }
    
}
