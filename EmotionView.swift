//
//  EmotionView.swift
//  EmotionView
//
//  Created by 孙亚东 on 15/7/3.
//  Copyright © 2015年 sunyadong. All rights reserved.
//

import UIKit

private let emoViewH: CGFloat = 197
private let stackH: CGFloat = 35


class EmotionView: UIView {
    
    
    
    override init(frame: CGRect) {
        
        let Frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: emoViewH + stackH)
        
        super.init(frame: Frame)
        
        backgroundColor = UIColor.redColor()
        
        setupUI()
        
        print("View Init")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        
        addSubview(EmotionCollectionView)
        addSubview(stackview)
        
        
    }
    
    private lazy var EmotionCollectionView: EmotionCollectView = {
        
        let cv = EmotionCollectView()
        
        cv.backgroundColor = UIColor.whiteColor()
        
        cv.scrollToIndex = { (index: Int) -> () in
            
            self.selectedButton(index)
        }
        
        return cv
    }()
    
    private var selectedBtn: UIButton?
    
    private lazy var stackview: UIStackView = {
        
        let stack = UIStackView(frame: CGRect(x: 0, y: emoViewH, width: UIScreen.mainScreen().bounds.width, height: stackH))
        
        stack.axis = .Horizontal
        stack.distribution = .FillEqually
        
        let arr:[EmoticonsModels] = EmotionViewModel.shareInstance.emotionModels
        
        for i in 0..<arr.count {
            
            let btn = UIButton()
            
            let path = NSBundle.mainBundle().pathForResource("Emoticons.bundle", ofType: nil)
            var imgpath = (path! as NSString).stringByAppendingPathComponent("Emoticon")
            imgpath = (imgpath as NSString).stringByAppendingPathComponent("compose_emotion_table")
            
            btn.setTitle(arr[i].group_name_cn!, forState: .Normal)
            btn.setBackgroundImage(UIImage(named:"\(imgpath)_normal.png"), forState: .Normal)
            btn.setBackgroundImage(UIImage(named:"\(imgpath)_selected.png"), forState: .Selected)
            
            btn.tag = i
            
            btn.addTarget(self, action: "scrollSection:", forControlEvents: .TouchUpInside)
            
            if i == 1 {
                self.scrollSection(btn)
            }
            
            stack.addArrangedSubview(btn)
        }
        
        return stack
    }()
    
    private func selectedButton(index: Int) {
        
        for button in stackview.subviews {
            
            let btn = button as! UIButton
            
            if btn.tag == index {
                selectedBtn?.selected = false
                selectedBtn = btn
                btn.selected = true
                
            }
        }
        
    }
    
    @objc private func scrollSection(sender: UIButton) {
        
        selectedBtn?.selected = false
        
        selectedBtn = sender
        
        sender.selected = true
        
        let indexpath = NSIndexPath(forItem: 0, inSection: sender.tag)
        
        EmotionCollectionView.scrollToItemAtIndexPath(indexpath, atScrollPosition: .CenteredHorizontally, animated: false)
        
    }
    
}

private class EmotionCollectView: UICollectionView {
    
    typealias scrollMake = (index: Int) -> ()
    
    var scrollToIndex: scrollMake?
    
    init () {
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: emoViewH)
        
        let flowlayout = UICollectionViewFlowLayout()
        
        flowlayout.itemSize = frame.size
        
        flowlayout.minimumLineSpacing = 0
        flowlayout.minimumInteritemSpacing = 0
        
        flowlayout.scrollDirection = .Horizontal
        
        super.init(frame: frame, collectionViewLayout: flowlayout)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        pagingEnabled = true
        
        dataSource = self
        delegate = self
        
        registerClass(EmotionCell.self, forCellWithReuseIdentifier: "cell")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension EmotionCollectView: UICollectionViewDelegate,UICollectionViewDataSource {
    
    @objc func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        if visibleCells().count < 2 {
            
            return
        }
        
        var firstSection = indexPathForCell(visibleCells().first!)?.section
        var lastSection = indexPathForCell(visibleCells().last!)?.section
        
        if firstSection > lastSection {
            
            firstSection = firstSection! ^ lastSection!
            lastSection = firstSection! ^ lastSection!
            firstSection = firstSection! ^ lastSection!
        }
        
        if firstSection != lastSection {
            
            var firstRange: CGFloat = -bounds.width * 0.5
            
            for i in 0...firstSection! {
                
                let model: EmoticonsModels = EmotionViewModel.shareInstance.emotionModels[i]
                
                let page = ((model.emotionGroup.count - 1) / 20) + 1
                
                firstRange += CGFloat(page) * bounds.width
                
            }
            
            if contentOffset.x < firstRange {

                self.scrollToIndex!(index: firstSection!)
            }else{
                
                self.scrollToIndex!(index: lastSection!)
            }
            
            
        }
        
    }
    
    @objc func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return EmotionViewModel.shareInstance.emotionModels.count
    }
    
    
    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let model:EmoticonsModels = EmotionViewModel.shareInstance.emotionModels[section]
        
        let pageCount = (model.emotionGroup.count - 1) / 20 + 1
        
        return pageCount ?? 0
        
    }
    
    
    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! EmotionCell
        
        //        cell.backgroundColor = RandomColor()
        
        cell.indexpath = indexPath
        
        cell.model = EmotionViewModel.shareInstance.emotionModels[indexPath.section]
        
        return cell
    }
    
}

private class EmotionCell: UICollectionViewCell{
    
    var model: EmoticonsModels?{
        
        didSet{
            
            setupButton()
            
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var indexpath: NSIndexPath?
    
    func setupUI(){
        
        for index in 0...20 {
            let colnum: Int = index % 7
            
            let rownum: Int = index / 7
            
            let btnW: CGFloat = UIScreen.mainScreen().bounds.width / 7
            let btnH: CGFloat = emoViewH / 3
            
            let btn = UIButton(frame: CGRect(x: CGFloat(colnum) * btnW, y: CGFloat(rownum) * btnH, width: btnW, height: btnH))
            
            if index == 20 {
                btn.setImage(UIImage(named: "compose_emotion_delete"), forState: .Normal)
                btn.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: .Highlighted)
                btn.highlighted = true
            }
            
            btn.highlighted = false
            
            contentView.addSubview(btn)
            
        }
        
    }
    
    func setupButton() {
        
        for (i, button) in contentView.subviews.enumerate(){
            
            let btn: UIButton = button as! UIButton
            let index: Int = i
            
            if index == 20 {
                break
            }
            
            if indexpath!.item * 20 + index >= model?.emotionGroup.count{
                
                btn.hidden = true
                continue
                
            }else{
                
                btn.hidden = false
            }
            
            let imgModel = model?.emotionGroup[indexpath!.item * 20 + index]
            
            btn.setImage(nil, forState: .Normal)
            btn.setTitle(nil, forState: .Normal)
            
            if imgModel?.code != nil {
                
                btn.setTitle(imgModel?.code, forState: .Normal)
                
            }else{
                
                btn.setImage(UIImage(named: imgModel!.png!), forState: .Normal)
                
            }
            
        }
        
    }
}

private class EmotModel: NSObject {
    
    var code: String?
    var png: String?
    var chs: String?
    var id: String?{
        didSet{
            if let img = png{
                
                var pngpath = NSBundle.mainBundle().pathForResource("Emoticons.bundle", ofType: nil)
                pngpath = (pngpath! as NSString).stringByAppendingPathComponent(id!)
                pngpath = (pngpath! as NSString).stringByAppendingPathComponent(img)
                png = pngpath
                
            }
        }
    }
    
    init(dict: [String: String]) {
        super.init()
        
        png = dict["png"]
        chs = dict["chs"]
        
        if dict["code"] != nil{
            
            let scanner = NSScanner(string: (dict["code"]! as String))
            
            var result: UInt32 = 0
            scanner.scanHexInt(&result)
            
            let unicode = UnicodeScalar(result)
            
            let character = Character(unicode)
            
            code = "\(character)"
        }
    }
    
    private override func setValue(value: AnyObject?, forUndefinedKey key: String) {
    }
    
}

private class EmoticonsModels: NSObject, NSCoding {
    
    var id: String?
    var group_name_cn: String?
    var emotionGroup: [EmotModel] = [EmotModel]()
    
    init(dict: [String: AnyObject]) {
        super.init()
        
        id = dict["id"] as? String
        group_name_cn = dict["group_name_cn"] as? String
        
        for emotionDict in dict["emoticons"] as! [[String: String]]{
            let model = EmotModel(dict: emotionDict)
            model.id = dict["id"] as? String
            emotionGroup.append(model)
        }
        
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        
        id = aDecoder.decodeObjectForKey("id") as? String
        group_name_cn = aDecoder.decodeObjectForKey("group_name_cn") as? String
        emotionGroup = aDecoder.decodeObjectForKey("emotionGroup") as! [EmotModel]
        
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(group_name_cn, forKey: "group_name_cn")
        aCoder.encodeObject(emotionGroup, forKey: "emotionGroup")
        
    }
    
    func saveData(path: String){
        
        NSKeyedArchiver.archiveRootObject(self, toFile: path)
    }
    
    class func readData(path: String) -> (EmoticonsModels?){
        
        let model = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? EmoticonsModels
        
        return model
    }
}

private class EmotionViewModel: NSObject {
    
    
    var emotionModels: [EmoticonsModels] = [EmoticonsModels]()
    
    static var shareInstance: EmotionViewModel = {
        
        let instance  = EmotionViewModel()
        
        return instance
        
    }()
    
    override init() {
        super.init()
        
        setupModels()
        
    }
    
    func setupModels() {
        
        let path = NSBundle.mainBundle().pathForResource("Emoticons.bundle", ofType: nil)
        
        let filepath = (path! as NSString).stringByAppendingPathComponent("emoticons.plist")
        
        let emotionDict = NSDictionary(contentsOfFile: filepath)
        
        let packages = emotionDict!["packages"] as! [[String: AnyObject]]
        
        let sandPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last! as NSString).stringByAppendingPathComponent("emotion.recent")
        
        let recentModel = EmoticonsModels.readData(sandPath)
        
        if let recentmodel = recentModel{
            
            emotionModels.append(recentmodel)
            
        }else{
            
            let recentDict: [String: AnyObject] = ["group_name_cn" : "最近",
                                                   "emoticons" : [[String: AnyObject]]()]
            
            let recentmodel = EmoticonsModels(dict: recentDict)
            
            recentmodel.saveData(sandPath)
            
            emotionModels.append(recentmodel)
            
        }
        
        for dict in packages {
            
            let emotionpath = (path! as NSString).stringByAppendingPathComponent(dict["id"] as! String)
            
            let infopath = (emotionpath as NSString).stringByAppendingPathComponent("info.plist")
            
            let infoDict = NSDictionary(contentsOfFile: infopath)
            
            let model = EmoticonsModels(dict: infoDict as! [String: AnyObject])
            
            emotionModels.append(model)
            
        }
    }
    
    
    
}




