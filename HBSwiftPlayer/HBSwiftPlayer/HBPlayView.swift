//
//  HBPlayView.swift
//  HBSwiftPlayer
//
//  Created by 沈红榜 on 2019/5/27.
//  Copyright © 2019 沈红榜. All rights reserved.
//

import UIKit
import AVFoundation


class HBPlayView: UIView {
    
    override internal class var layerClass: AnyClass {
        return AVPlayerLayer.classForCoder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init is wrong")
    }
    
    //    MARK:- 属性
    var player: AVPlayer? {
        willSet {
            let playLayer = self.playLayer
            playLayer.player = newValue
        }
    }
    
    var playLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var isPlaying: Bool {
        if player == nil {
            return false
        }
        let p = player!
        return p.rate <= 0 ? false : true
    }
    
}

extension HBPlayView {
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    convenience init(url: URL) {
        self.init()
        player = AVPlayer(url: url)
    }
}


