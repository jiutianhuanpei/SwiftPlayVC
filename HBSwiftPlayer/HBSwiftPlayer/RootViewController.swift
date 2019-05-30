//
//  RootViewController.swift
//  HBSwiftPlayer
//
//  Created by 沈红榜 on 2019/5/25.
//  Copyright © 2019 沈红榜. All rights reserved.
//

import UIKit
import AVFoundation

let videoUrlStr = "http://video.komect.com/upload/others/Sequence12.mp4"

class RootViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        guard let url = URL(string: videoUrlStr) else {
            print("url is nil   ")
            return
        }
        
        print("URL is \(url)")
        
        view.addSubview(playView)
        playView.frame = .init(x: 20, y: 150, width: view.frame.width - 40, height: 250)
        playView.backgroundColor = .lightGray
        
        playView.player = AVPlayer(url: url)
        
        
        
        view.addSubview(btn)
        btn.sizeToFit()
        btn.center = .init(x: view.center.x, y: playView.frame.maxY + 80)
        
        view.addSubview(pushBtn)
        pushBtn.sizeToFit()
        
        pushBtn.center = .init(x: btn.center.x, y: btn.center.y + 100)
        
    }
    
    
    //    MARK: - action
    @objc func clickedBtn(_ sender: UIButton) {
        
        if sender.isSelected {
            playView.pause()
        } else {
            playView.play()
        }

        sender.isSelected = !sender.isSelected
        
    }
    
    @objc func pushToPlayVC() {
        
        
        guard let url = URL(string: videoUrlStr) else {
            print("url is nil   ")
            return
        }
        
        let player = HBPlayerViewController(url: url, autoPlay: false)
        player.showControlToolsDurationTime = 5
        present(player, animated: true, completion: nil)
    }
    
    
    //    MARK:- getter
    var playView = HBPlayView(frame: .zero)
    
    
    lazy var btn: UIButton = {
        let bt = UIButton(type: .custom)
        bt.setTitle("播放", for: .normal)
        bt.setTitle("暂停", for: .selected)
        bt.setTitleColor(.red, for: .normal)
        bt.addTarget(self, action: #selector(clickedBtn(_:)), for: .touchUpInside)
        return bt
    }()
    
    
    lazy var pushBtn: UIButton = {
        let bt = UIButton(type: .custom)
        bt.setTitle("Play", for: .normal)
        bt.setTitleColor(.red, for: .normal)
        bt.addTarget(self, action: #selector(pushToPlayVC), for: .touchUpInside)
        return bt
    }()
    
}


