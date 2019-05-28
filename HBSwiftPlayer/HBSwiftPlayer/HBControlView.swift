//
//  HBControlView.swift
//  HBSwiftPlayer
//
//  Created by 沈红榜 on 2019/5/26.
//  Copyright © 2019 沈红榜. All rights reserved.
//

import UIKit

class HBControlView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        addSubviews(playBtn, beginLbl, slider, endLbl)
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        beginLbl.translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        endLbl.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["btn": playBtn, "b": beginLbl, "s": slider, "e": endLbl]
        let metricsDic = ["bw": 40, "lw": 50]
        
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[btn(bw)]-|", options: .alignAllLeft, metrics: metricsDic, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[b]-|", options: .alignAllLeft, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[s]-|", options: .alignAllLeft, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[e]-|", options: .alignAllLeft, metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[btn(bw)]-[b]-[s]-[e(lw)]-|", options: .directionLeadingToTrailing, metrics: metricsDic, views: views))

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //    MARK:- Actions
    @objc private func clickedPlayBtn(_ sender: UIButton) {
        
        isPlaying = !isPlaying
        
        clickedPlayBtn?(sender.isSelected)
    }
    
    @objc private func chooseSlider(_ sender: UISlider) {
        
        let time = Float64(sender.value) * videoDuration / Float64(sender.maximumValue)
        chooseTime?(time)
        canSetCurrentTime = true
    }
    
    private var canSetCurrentTime = true
    @objc private func touchDownSlider() {
        canSetCurrentTime = false
        willChooseTime?()
    }
    
    
    //    MARK:-  属性
    private lazy var playBtn: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "play"), for: .normal)
        b.setImage(UIImage(named: "pause"), for: .selected)
        b.addTarget(self, action: #selector(clickedPlayBtn(_:)), for: .touchUpInside)
        return b
    }()
    
    private lazy var beginLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.text = "00:00"
        lbl.font = UIFont.systemFont(ofSize: 15)
        return lbl
    }()
    
    private lazy var endLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.text = "00:00"
        lbl.font = UIFont.systemFont(ofSize: 15)
        return lbl
    }()
    
    private lazy var slider: UISlider = {
       let s = UISlider(frame: .zero)
        s.minimumValue = 0
        s.maximumValue = 100
        s.isEnabled = false
        s.addTarget(self, action: #selector(chooseSlider(_:)), for: [.touchUpInside, .touchUpOutside])
        s.addTarget(self, action: #selector(touchDownSlider), for: .touchDown)
        return s
    }()
    
    
    private func timeStrWith(_ time: Float64) -> String {
        
        let formatter = DateFormatter()
        
        if time >= 60 * 60 {
            formatter.dateFormat = "HH:mm:ss"
        } else {
            formatter.dateFormat = "mm:ss"
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let str = formatter.string(from: date)
        return str
    }
    
    //    MARK:- Public
    var videoDuration: Float64 = 0 {
        willSet {
            let str = timeStrWith(newValue)
            endLbl.text = str
            slider.isEnabled = newValue > 0
        }
    }
    
    func setCurrentTime(_ time: Float64) {
        if time > videoDuration || time < 0 || videoDuration == 0 || !canSetCurrentTime { return }
        
        let sValue =  time / videoDuration * 100
        slider.value = Float(sValue)
        beginLbl.text = timeStrWith(time)
        isPlayToEnd = false
    }
    
    var isPlaying: Bool {
        set {
            playBtn.isSelected = newValue
        }
        get {
            return playBtn.isSelected
        }
    }
    
    var isPlayToEnd = false
    
    var willChooseTime: (()->Void)?
    
    var chooseTime: ((Float64)->Void)?
    var clickedPlayBtn: ((_ showldPlay: Bool)->Void)?
    
    
    
}
