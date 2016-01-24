//
//  Utility.swift
//  SimpleMP4
//
//  Created by 藤原 達郎 on 2016/01/04.
//  Copyright (c) 2016年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit

class Utility: NSObject {
    
    class func getFileType(targetFilename : String?) -> String {
        if(targetFilename == nil){
            return "---"
        }
        
        let filename = targetFilename!
        
        if(filename.hasSuffix(".mp4") || filename.hasSuffix(".MP4")){
            return "MP4"
        } else if(filename.hasSuffix(".mpg") || filename.hasSuffix(".MPG") ||
            filename.hasSuffix(".mpeg") || filename.hasSuffix(".MPEG")){
                return "MPG"
        } else if(filename.hasSuffix(".mov") || filename.hasSuffix(".MOV")){
            return "MOV"
        } else if(filename.hasSuffix(".3gp") || filename.hasSuffix(".3GP")){
            return "3GP"
        } else if(filename.hasSuffix(".wmv") || filename.hasSuffix(".WMV")){
            return "WMV"
        } else if(filename.hasSuffix(".avi") || filename.hasSuffix(".AVI")){
            return "AVI"
        } else if(filename.hasSuffix(".flv") || filename.hasSuffix(".FLV")){
            return "FLV"
        } else {
            return "---"
        }
    }
    
    class func canConvertMP4(targetFileType : String?) -> Bool {
        if(targetFileType == nil){
            return false
        }
        
        // 変換可能なファイル形式（MOVかAVIなら変換可能）
        if(targetFileType! == "MOV" || targetFileType! == "AVI"){
            return true;
        }
        
        return false;
    }
    
    class func makeIndicatorView(view:UIView) -> UIActivityIndicatorView {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.frame = CGRectMake(0, 0, 70, 70)
        indicatorView.center = view.center
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        indicatorView.backgroundColor = UIColor.darkGrayColor()
        indicatorView.layer.masksToBounds = true
        indicatorView.layer.cornerRadius = 5.0
        indicatorView.layer.opacity = 0.8
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }
    
}
