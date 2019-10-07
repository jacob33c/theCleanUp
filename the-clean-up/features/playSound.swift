//
//  playSound.swift
//  the-clean-up
//
//  Created by Jacob Fraizer on 10/7/19.
//  Copyright © 2019 Jacob Fraizer. All rights reserved.
//

import Foundation
import AVFoundation
import AudioToolbox

var player: AVAudioPlayer!



func playRequestFoundSound(){
    let soundURL = Bundle.main.url(forResource: "moneyNotification", withExtension: "mp3")
    do {
        player = try AVAudioPlayer(contentsOf: soundURL!)
    }
    catch{
        print(error)
    }
    player.play()
    AudioServicesPlaySystemSound(4095)


}
