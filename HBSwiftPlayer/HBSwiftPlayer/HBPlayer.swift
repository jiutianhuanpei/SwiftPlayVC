//
//  HBPlayer.swift
//  HBSwiftPlayer
//
//  Created by 沈红榜 on 2019/5/25.
//  Copyright © 2019 沈红榜. All rights reserved.
//

import UIKit
import AVFoundation
import ObjectiveC

/// 继承自 UINavigationController 显示导航栏
class HBPlayerViewController: UINavigationController {
    var showControlToolsDurationTime: TimeInterval {
        willSet {
            playVC.showControlToolsDurationTime = newValue
        }
    }
    
    private var playVC: _HBPlayerViewController
    
    
    init(url: URL, autoPlay: Bool = false) {
        showControlToolsDurationTime = 0
        
        if autoPlay {
            playVC = _HBPlayerViewController(url: url, isAutoPlay: autoPlay)
        } else {
            playVC = _HBPlayerViewController(url: url)
        }
        super.init(nibName: nil, bundle: nil)
        
        addChild(playVC)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override internal var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override internal var shouldAutorotate: Bool {
        return true
    }
}


//MARK:-
//MARK:- 真正的 playVC
fileprivate class _HBPlayerViewController: UIViewController {
    
    init(url: URL) {
        currentUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var controlBottom: NSLayoutConstraint!
    private let timeScale: Int32 = 72
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = .init(image: UIImage(named: "nav_icon_back_nor"), style: .plain, target: self, action: #selector(dismissVC))
        view.backgroundColor = .lightGray
        title = currentUrl.lastPathComponent
        
        view.addSubviews(playView, controlView)
        
        playView.player = AVPlayer(url: currentUrl)
        
        
        playView.translatesAutoresizingMaskIntoConstraints = false
        controlView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let views = ["p" : playView, "c": controlView]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[p]|", options: .alignAllLeft, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[p]|", options: .alignAllLeft, metrics: nil, views: views))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[c]|", options: .alignAllLeft, metrics: nil, views: views))
        controlBottom = NSLayoutConstraint.init(item: controlView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(controlBottom)
        
        controlViewActions()
        addTapGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObserver()
        if isAutoPlay {
            navigationController?.isNavigationBarHidden = true
            view.layoutIfNeeded()
            controlBottom.constant = controlView.frame.height + 21
            playView.play()
            controlView.isPlaying = true
        } else {
            endTouchControlView()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playView.pause()
        if let add = addPer {
            playView.player?.removeTimeObserver(add)
        }
    }
    
    private var addPer: Any!
    private func addObserver() {
        
        playView.player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        addPer = playView.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: timeScale), queue: DispatchQueue.main, using: { [unowned self] time in
            
            let ct = CMTimeGetSeconds(time)
            self.controlView.setCurrentTime(ct)
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoPlayEnd), name: .AVPlayerItemDidPlayToEndTime, object: playView.player?.currentItem)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if "status" != keyPath {
            return
        }
        
        guard let dic = change else { return }
        
        let value = dic[NSKeyValueChangeKey.newKey] as? Int
        
        if value == AVPlayer.Status.readyToPlay.rawValue, let dur = playView.player?.currentItem?.asset.duration {
            
            let tmp = CMTimeGetSeconds(dur)
            
            controlView.videoDuration = tmp
        }
    }
    
    @objc private func videoPlayEnd() {
        controlView.isPlaying = false
        
//        标记播放结束，用于在进度最后时点击播放按钮
        controlView.isPlayToEnd = true
    }
    
    private func controlViewActions() {
        
        controlView.clickedPlayBtn = { [unowned self, weak playView, weak controlView] shouldPlay in
            
            self.continueShowControlView()
            
            if shouldPlay {
                
                if let con = controlView {
                    if con.isPlayToEnd {
                        playView?.player?.seek(to: CMTimeMake(value: 0, timescale: self.timeScale))
                    }
                }
                
                playView?.play()
            } else {
                playView?.pause()
            }
            self.endTouchControlView()
        }
        
        controlView.willChooseTime = { [unowned self] in
            self.continueShowControlView()
        }
        
        controlView.chooseTime = { [unowned self, weak playView] time in
            
            let cmTime = CMTimeMakeWithSeconds(Float64(time), preferredTimescale: self.timeScale)
            playView?.player?.seek(to: cmTime)
            self.endTouchControlView()
        }
    }
    
    @objc private func dismissVC() {
        playView.pause()
        controlView.isPlaying = false
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate var isTouchAnimating = false

    //    MARK:- getter
    private lazy var playView: HBPlayView = {
       let p = HBPlayView(frame: .zero)
        return p
    }()
    
    private lazy var controlView: HBControlView = {
        let v = HBControlView(frame: .zero)
        return v
    }()
    
    private var currentUrl: URL
}

// MARK: - 显隐控制条模块
fileprivate extension _HBPlayerViewController {
    
    /// 不触动工具条后几秒隐藏
    var showControlToolsDurationTime: TimeInterval {
        set {
            objc_setAssociatedObject(self, &PlayKey.TimeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let num = objc_getAssociatedObject(self, &PlayKey.TimeKey) as? NSNumber
            if let a = num {
                
                return TimeInterval(truncating: a)
            }
            return 5
        }
    }
    
    
    /// 标记要继续显示工具条
    @objc func continueShowControlView() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    /// 标记可以隐藏工具条了，showControlToolsDurationTime 时间后将隐藏
    @objc func endTouchControlView() {
        self.perform(#selector(hideControlView(_:)), with: nil, afterDelay: showControlToolsDurationTime)
    }
    
    /// 显示工具条，showControlToolsDurationTime 时间后将自动隐藏
    ///
    /// - Parameter finished: 动画结束回调
    @objc func showControlView(_ finished: @escaping ()->Void) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        setControlToolsShow(true, finished: finished)
        
        self.perform(#selector(hideControlView(_:)), with: nil, afterDelay: showControlToolsDurationTime)
    }
    
    /// 隐藏工具条
    ///
    /// - Parameter finished: 动画结束回调
    @objc func hideControlView(_ finished: (()->Void)?) {
        
        setControlToolsShow(false, finished: finished)
    }
    
    private func setControlToolsShow(_ isShow: Bool, finished:(()->Void)?) {
        
        guard let na = self.navigationController else { return }
        
        self.controlBottom.constant = isShow ? 0 : controlView.frame.height
        
        UIView.animate(withDuration: 0.2, animations: {
            [unowned self] in
            
            na.isNavigationBarHidden = !isShow
            self.view.layoutIfNeeded()
            
        }) { _ in
            finished?()
        }
    }
}

// MARK: - 自动播放模块
fileprivate extension _HBPlayerViewController {
    
    /// 是否自动播放
    var isAutoPlay: Bool {
        set {
            objc_setAssociatedObject(self, &PlayKey.AutoPlay, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let ret = objc_getAssociatedObject(self, &PlayKey.AutoPlay)
            return (ret as? Bool) ?? false
        }
    }
    
    /// 自动播放对应的初始化方法
    ///
    /// - Parameters:
    ///   - url: url
    ///   - isAutoPlay: 是否自动播放
    convenience init(url: URL, isAutoPlay: Bool) {
        self.init(url: url)
        
        self.isAutoPlay = isAutoPlay
    }
}


// MARK: - 手势模块
fileprivate extension _HBPlayerViewController {
    
    func addTapGestures() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapPlayView(_:)))
        playView.isUserInteractionEnabled = true
        playView.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        playView.addGestureRecognizer(pan)
        
    }
    
    private var isVolume: Bool {
        set {
            objc_setAssociatedObject(self, &PlayKey.IsVolume, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            if let obj = objc_getAssociatedObject(self, &PlayKey.IsVolume) as? NSNumber {
                
                return obj.boolValue
            }
            return true
        }
    }
    
    @objc private func panGesture(_ sender: UIPanGestureRecognizer) {
        
        
        if sender.state == .began {
            let p = sender.location(in: playView)
            isVolume = p.x >= playView.frame.midX
        }
        
        
        if isVolume {
//            音量调节
            guard let player = playView.player else { return  }

            var value = player.volume
            
            let v = sender.velocity(in: playView)
            
            if abs(v.x) > abs(v.y) { return }
            
            if v.y > 0 {
                value -= 0.2
                value = max(0, value)
            } else {
                value += 0.2
                value = min(10, value)
            }
            
            player.volume = value
            
        } else {
//            亮度调节
            var value = UIScreen.main.brightness
            
            let v = sender.velocity(in: playView)
            
            if abs(v.x) > abs(v.y) { return }
            
            if v.y > 0 {
                value -= 0.04
                value = max(0, value)
            } else {
                value += 0.04
                value = min(1, value)
            }
            UIScreen.main.brightness = value
        }
    }
    
    /// 用于隐藏 controlView 及 导航栏
    ///
    /// - Parameter tap: tap
    @objc private func tapPlayView(_ tap: UITapGestureRecognizer) {
        
        if isTouchAnimating {return }
        
        guard let na = self.navigationController else { return }
        
        isTouchAnimating = true
        
        if na.isNavigationBarHidden {
            
            showControlView { [unowned self] in
                self.isTouchAnimating = false
            }
            
        } else {
            
            hideControlView { [unowned self] in
                self.isTouchAnimating = false
            }
        }        
    }
}

fileprivate extension _HBPlayerViewController {
    struct PlayKey {
        static var AutoPlay = "autoPlay"
        static var TimeKey = "HBTimeKey"
        static var IsVolume = "IsVolume"
    }
}




