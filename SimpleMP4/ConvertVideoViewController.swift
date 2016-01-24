//
//  ConvertVideoViewController.swift
//  SimpleMP4
//
//  Created by 藤原 達郎 on 2016/01/04.
//  Copyright (c) 2016年 Tatsuo Fujiwara. All rights reserved.
//

import UIKit
import Photos

class ConvertVideoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var accessDeniedView: UITextView!
    
    var indicator:UIActivityIndicatorView!
    
    var videoList:Array<PHAsset>!
    var converting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib:UINib = UINib(nibName:"MovieCollectionViewCell", bundle:nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: "MovieCell")
        
        videoList = []
        
        // iPhone4s対応（CollectionViewのサイズ調節）
        collectionView.frame = CGRectMake(0, 64, 320, self.view.frame.size.height-64)
        
        initView()
    }
    
    func initView() {
        // カメラロールへのアクセス許可を確認
        var status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.Authorized) {
            // 許可済みなら処理なし
            accessDeniedView.hidden = true
        } else if(status == PHAuthorizationStatus.NotDetermined){
            // 許可/不許可の判断をしていない
            accessDeniedView.hidden = true
        } else if(status == PHAuthorizationStatus.Denied || status == PHAuthorizationStatus.Restricted){
            // 不許可の場合はメッセージを出す
            accessDeniedView.hidden = false
            return;
        }
        
        //全てのカメラロールの画像を取得する。
        var updatedVideoList:Array<PHAsset>! = []
        var assets:PHFetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Video, options: nil)
        assets.enumerateObjectsUsingBlock({ obj, index, stop in
            if obj is PHAsset {
                
                // 取得してきたPHFetchResultから "assetSource=3" のレコードを間引く
                // fetchOptions.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO], ]; // ソートしたりとか楽勝
                
                let asset = obj as PHAsset;
                updatedVideoList.append(asset)
            }
        });
        
        videoList = updatedVideoList
        collectionView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let movieCell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as MovieCollectionViewCell
        
        let asset:PHAsset = videoList[indexPath.row]
        
        // サムネイル
        PHImageManager.defaultManager().requestImageForAsset(asset,
            targetSize: CGSize(width: 78, height: 78),
            contentMode: .AspectFill, options: nil) {
                image, info in
                movieCell.imageView.image = image
        }
        
        // ファイルタイプ
        let filename = (asset as AnyObject).filename!
        movieCell.filetypeLabel.text = Utility.getFileType(filename)
        
        // 再生時間
        let second = (Int)(asset.duration + 0.5) // 秒以下を四捨五入
        let secondStr = NSString(format: "%d:%02d", (Int)(second/60), second%60)
        movieCell.durationLabel.text = secondStr
        
        return movieCell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if(converting == true){return}
        
        let asset:PHAsset = videoList[indexPath.row]
        
        let filename = (asset as AnyObject).filename!
        let filetype = Utility.getFileType(filename)
        
        // ファイルタイプのチェック
        var errorMsg = ""
        if(filetype == "MP4"){
            errorMsg = "すでにMP4形式のため変換できません"
        } else if(Utility.canConvertMP4(filetype) == false){
            errorMsg = "変換できないファイル形式です"
        }
        if(errorMsg != ""){
            let alertController = UIAlertController(title: "", message: errorMsg, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            presentViewController(alertController, animated: true, completion: nil)
            return;
        }
        
        let alertController = UIAlertController(title: "",
            message: "選択したファイルをMP4に変換します。\nよろしいですか？", preferredStyle: .Alert)
        let otherAction = UIAlertAction(title: "OK", style: .Default) {
            action in
            // ぐるぐるを回す
            self.indicator = Utility.makeIndicatorView(self.view)
            self.indicator.startAnimating()
            self.view.addSubview(self.indicator)
            self.converting = true
            
            // 別スレッドで変換を実行
            let operationQueue = NSOperationQueue()
            operationQueue.addOperationWithBlock({
                self.convertMovie(asset)
            })
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func convertMovie(phAsset:PHAsset){
        // 一時ファイルの保存先を確保
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let dirPath = documentsPath + "/temp/"
        let outputFilePath = dirPath + "temp.mp4"
        
        //ディレクトリとファイルの有無を調べる
        let fileManager = NSFileManager.defaultManager()
        var isDir : ObjCBool = false
        let existDir = fileManager.fileExistsAtPath(dirPath, isDirectory: &isDir)
        let existFile = fileManager.fileExistsAtPath(outputFilePath, isDirectory: &isDir)
        
        // ディレクトリが存在しない場合は作る
        if(existDir == false){
            fileManager.createDirectoryAtPath(dirPath ,withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        // ファイルが存在する場合は削除
        if(existFile == true){
            fileManager.removeItemAtPath(outputFilePath, error: nil)
        }
        
        // AVAssetExportSessionオブジェクトを作る
        var exportSession:AVAssetExportSession!
        let option = PHVideoRequestOptions()
        let preset = ConfigManager.getExportPreset()

        var waiting = true
        PHImageManager.defaultManager().requestExportSessionForVideo(
            phAsset, options: option, exportPreset: preset){
            exSession, info in
            exportSession = exSession
            waiting = false
        }
        while(waiting){}

        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.outputURL = NSURL(fileURLWithPath: outputFilePath)
        
        // println("exportSession:\(exportSession.debugDescription)")
        
        // MP4への変換
        exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
            switch exportSession.status {
            case AVAssetExportSessionStatus.Completed:
                // println("Completed");
                
                // 一時ファイルに出力したMP4をカメラロールに保存
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFilePath)) {
                    // println("カメラロール保存可能")
                    UISaveVideoAtPathToSavedPhotosAlbum(outputFilePath, self, "video:didFinishSavingWithError:contextInfo:", nil)
                } else {
                    // println("カメラロール保存不可")
                    self.showResult(false, errorMsg: "変換後の保存に失敗しました")
                }
                break
            case AVAssetExportSessionStatus.Failed:
                // println("Failed");
                println("Error:\(exportSession.error.debugDescription)")
                self.showResult(false, errorMsg: "変換に失敗しました")
                break
            case AVAssetExportSessionStatus.Cancelled:
                // println("Cancelled");
                self.showResult(false, errorMsg: "変換がキャンセルされました")
                break
            default:
                break
            }
        }
    }

    func video(videoPath: String, didFinishSavingWithError error: NSError!, contextInfo info: UnsafeMutablePointer<Void>) {
        
        // 一時ファイルを削除
        NSFileManager.defaultManager().removeItemAtPath(videoPath, error: nil)
        
        if (error != nil) {
            // println("保存失敗")
            self.showResult(false, errorMsg: "変換後の動画の保存に失敗しました")
        } else {
            // println("成功")
            self.showResult(true, errorMsg: "")
        }
    }
    
    func showResult(result : Bool, errorMsg : String){
        var message = "完了しました"
        if(result == false){
            message = errorMsg
        }
        
        let mainQueue = NSOperationQueue.mainQueue()
        mainQueue.addOperationWithBlock({
            self.indicator.stopAnimating()
            self.converting = false
            
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
            // 読み込み直し
            self.initView()
        })
    }
    
    @IBAction func reloadButton(sender: AnyObject) {
        if(converting == true){return}
        
        // 表示を更新
        initView()
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
