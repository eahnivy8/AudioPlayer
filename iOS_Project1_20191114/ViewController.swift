//
//  ViewController.swift
//  iOS_Project1_20191114
//
//  Created by Eddie Ahn on 2019/11/14.
//  Copyright © 2019 Eddie Ahn. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {
    var player: AVAudioPlayer?
    var timer: Timer?
    
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initializePlayer()
    }
    
    func initializePlayer() {
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            return
        }
        do {
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player?.delegate = self
        } catch let error as NSError {
            print(error.code)
        }
        self.progressSlider.maximumValue = Float(self.player?.duration ?? 0.0)
        self.progressSlider.minimumValue = 0
        self.progressSlider.value = Float(self.player?.currentTime ?? 0.0)
    }
    
    func updateTimeLabelText(time: TimeInterval) {
        let minute = Int(time / 60)
        let second = Int(time.truncatingRemainder(dividingBy: 60))
        let mileSecond = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        let timeText = String(format: "%02ld:%02ld:%02ld", minute, second, mileSecond)
        self.timeLabel.text = timeText
    }
    
    func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true
            , block: { (timer: Timer) in
                if self.progressSlider.isTracking { return }
                self.updateTimeLabelText(time: self.player?.currentTime ?? 0.0)
                self.progressSlider.value = Float(self.player?.currentTime ?? 0.0)
        })
        self.timer?.fire()
    }
    
    func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @IBAction func playPauseButton(_ sender: UIButton) {
        print("button tapped")
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player?.play()
            self.makeAndFireTimer()
        } else {
            self.player?.pause()
            self.invalidateTimer()
        }
    }
    
    @IBAction func sliderAction(_ sender: UISlider) {
        print("slider selected")
        self.updateTimeLabelText(time: TimeInterval(sender.value))
        if sender.isTracking { return }
        self.player?.currentTime = TimeInterval(sender.value)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false
        self.progressSlider.value = 0
        self.updateTimeLabelText(time: 0)
        self.invalidateTimer()
    }
}

