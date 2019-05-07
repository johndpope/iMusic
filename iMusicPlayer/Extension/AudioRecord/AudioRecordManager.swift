//
//  AudioRecordManager.swift
//  FirstEncounter
//
//  Created by 微标杆 on 2019/3/14.
//  Copyright © 2019年 WBG. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioRecordManagerDelegate {
    func audioRecordTimeMonitor(time:String,manager:AudioRecordManager)
    func audioPlayTimeMonitro(time:String,endTime:String,manager:AudioRecordManager)
    func audioPlayToEnd(manager:AudioRecordManager)
    func audioRecordToEnd(manager:AudioRecordManager,data:Data)
}

class AudioRecordManager: NSObject,AVAudioRecorderDelegate,AVAudioPlayerDelegate {

    static let shared = AudioRecordManager()
    
    private var recorder: AVAudioRecorder!
    private var player: AVAudioPlayer!
    private var meterTimer: Timer!
    private var soundFileURL: URL!
    private var mp3FileURL: URL!
    
    private var capFileName: String!
    private var mp3FileName: String!
    
    var delegate:AudioRecordManagerDelegate?
    
//     MARK: - Public Method
    func startRecord() {
        
        let session = AVAudioSession.sharedInstance()
        
        do {
//            try session.setCategory(AVAudioSession.Category.playback, with: [.defaultToSpeaker,.allowBluetooth])
            try session.setCategory(AVAudioSession.Category.playback, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try session.setActive(true)
        } catch {
            print(error.localizedDescription)
        }
        
        if player != nil && player.isPlaying {
            print("stopping")
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.isRecording {
            print("pausing")
            recorder.pause()
        } else {
            print("recording")
            //            recorder.record()
            recordWithPermission(false)
        }
        
    }
    
    func stopRecord() {
        
        recorder?.stop()
        player?.stop()
        
        if meterTimer != nil {
            ConvertAudioFile.conventToMp3(withCafFilePath: self.capFileName, mp3FilePath: self.mp3FileName, sampleRate: 44100, callback: { (result) in
                print(result)
            })
            meterTimer.invalidate()
        }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
        } catch {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
        
    }
    
    func startPlay() {
        
//        var url: URL?
//        if self.recorder != nil {
//            url = self.recorder.url
//        } else {
//            url = self.soundFileURL!
//        }
//        print("playing \(String(describing: url))")
        let url = URL(fileURLWithPath: self.mp3FileName)

        if FileManager.default.fileExists(atPath: self.mp3FileName) {
            print("--------------->")
        }
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(playtime(_:)), userInfo: nil, repeats: true)
        } catch {
            self.player = nil
            print(error.localizedDescription)
        }
        
    }
    
    func resetRecord() {
        
        self.stopRecord()
        self.deleteAllRecordings()
        self.startRecord()
        
    }
    
    func playerUrl(url:String) {
        
    }
    
    // MARK: - Private Method
    private func setupRecorder() {
        print("\(#function)")
        
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).caf"
        let mp3FileName = "recording-\(format.string(from: Date())).mp3"
        print(currentFileName)
        
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/AudioData"
        let fileManager = FileManager.default
        var isDir:ObjCBool = false
        let isDirExist: Bool = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if !isDirExist {
            do {
               try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch  {
                print(error.localizedDescription)
            }
        }
        self.capFileName = path + "\(currentFileName)"
        self.mp3FileName = path + "\(mp3FileName)"
        self.soundFileURL = URL(fileURLWithPath: self.capFileName)
        print("writing to soundfile url: '\(soundFileURL!)'")
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey: 32000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]

        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    private func recordWithPermission(_ setup: Bool) {
        print("\(#function)")
        
        AVAudioSession.sharedInstance().requestRecordPermission {
            [unowned self] granted in
            if granted {
                
                DispatchQueue.main.async {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target: self,
                                                           selector: #selector(self.updateAudioMeter(_:)),
                                                           userInfo: nil,
                                                           repeats: true)
                }
            } else {
                print("Permission to record not granted")
            }
        }
        
        if AVAudioSession.sharedInstance().recordPermission == .denied {
            print("permission denied")
        }
        
    }
    
    @objc func updateAudioMeter(_ timer: Timer) {
        
        if let recorder = self.recorder {
            if recorder.isRecording {
//                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d", sec)
                recorder.updateMeters()
                if sec >= 60{
                    self.stopRecord()
                    return
                }
                self.delegate?.audioRecordTimeMonitor(time: s, manager: self)
                // if you want to draw some graphics...
                //var apc0 = recorder.averagePowerForChannel(0)
                //var peak0 = recorder.peakPowerForChannel(0)
            }
        }
        
    }
    
    @objc func playtime(_ timer: Timer){
        
        if let player = self.player {
            if player.isPlaying {
                let sec = Int(player.currentTime.truncatingRemainder(dividingBy: 60))
                let s = String(format: "%02d", sec)
                recorder.updateMeters()
                self.delegate?.audioPlayTimeMonitro(time: s, endTime: "\(Int(player.duration))", manager: self)
            }
        }
        
    }
    
    private func deleteAllRecordings() {
        print("\(#function)")
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory,
                                                            includingPropertiesForKeys: nil,
                                                            options: .skipsHiddenFiles)
            //                let files = try fileManager.contentsOfDirectory(at: documentsDirectory)
            var recordings = files.filter({ (name: URL) -> Bool in
                return name.pathExtension == "caf" || name.pathExtension == "mp3"
                //                    return name.hasSuffix("m4a")
            })
            for i in 0 ..< recordings.count {
                //                    let path = documentsDirectory.appendPathComponent(recordings[i], inDirectory: true)
                //                    let path = docsDir + "/" + recordings[i]
                
                //                    print("removing \(path)")
                print("removing \(recordings[i])")
                do {
                    try fileManager.removeItem(at: recordings[i])
                } catch {
                    print("could not remove \(recordings[i])")
                    print(error.localizedDescription)
                }
            }
            
        } catch {
            print("could not get contents of directory at \(documentsDirectory)")
            print(error.localizedDescription)
        }
        
    }
    
    func setSessionPlayAndRecord() {
        
        print("\(#function)")
        
        let session = AVAudioSession.sharedInstance()
        do {
//            try session.setCategory(AVAudioSession.Category.playAndRecord, with: [.defaultToSpeaker,.allowBluetooth])
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        } catch {
            print("could not set session category")
            print(error.localizedDescription)
        }
        
        do {
            try session.setActive(true)
        } catch {
            print("could not make session active")
            print(error.localizedDescription)
        }
        
    }
    
    // MARK: - AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool) {
        
        print("finished recording \(flag)")
        var audioData:Data?
        do {
            audioData = try Data(contentsOf: URL(fileURLWithPath: self.mp3FileName))
        } catch  {
            print(error.localizedDescription)
        }
        self.delegate?.audioRecordToEnd(manager: self, data: audioData!)
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
                                          error: Error?) {
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
    
    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("\(#function)")
        print("finished playing \(flag)")
        self.delegate?.audioPlayToEnd(manager: self)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
    
}
