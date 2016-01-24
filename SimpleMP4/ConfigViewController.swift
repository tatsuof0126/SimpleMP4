//
//  ConfigViewController.swift
//  SimpleMP4
//
//  Created by 藤原 達郎 on 2016/01/04.
//  Copyright (c) 2016年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import Photos

class ConfigViewController: UIViewController {

    @IBOutlet var versionLabel: UILabel!

    @IBOutlet var qualityLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        qualityLabel.text = ConfigManager.getExportPresetString()
        
        let version:String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as String
//        let build:String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as String
        versionLabel.text = "ver" + version
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func changeButton(sender: AnyObject) {
        let actionSheet:UIAlertController = UIAlertController(title:"",
            message: "変換品質を選択してください",
            preferredStyle: UIAlertControllerStyle.ActionSheet
        )
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
        })
        let highAction:UIAlertAction = UIAlertAction(title: "高品質",
            style: UIAlertActionStyle.Default,
            handler: {
                (action:UIAlertAction!) -> Void in
                self.setExportPreset(AVAssetExportPresetHighestQuality)
        })
        let mediumAction:UIAlertAction = UIAlertAction(title: "中品質",
            style: UIAlertActionStyle.Default,
            handler: {
                (action:UIAlertAction!) -> Void in
                self.setExportPreset(AVAssetExportPresetMediumQuality)
        })
        let lowAction:UIAlertAction = UIAlertAction(title: "低品質",
            style: UIAlertActionStyle.Default,
            handler: {
                (action:UIAlertAction!) -> Void in
                self.setExportPreset(AVAssetExportPresetLowQuality)
        })
        
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(highAction)
        actionSheet.addAction(mediumAction)
        actionSheet.addAction(lowAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func setExportPreset(exportPreset : String) {
        ConfigManager.setExportPreset(exportPreset)
        qualityLabel.text = ConfigManager.getExportPresetString()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
