//
//  ViewController.swift
//  TorchModeIsOn
//
//  Created by robinsonhus0 on 26.12.19.
//  Copyright © 2019 robinsonhus0. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var recognizedTextLabel: UILabel!
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var torchLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    
    let audioEngine = AVAudioEngine()
    
    //change your language here
    // z.B. "de-DE", "en-US"
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "de-DE"))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        animateCompanyLabel()
    }
    
    func animateCompanyLabel() {
        let companyName = "YourFirstApp🔦"
        
        for char in companyName {
            appLabel.text! += "\(char)"
            RunLoop.current.run(until: Date()+0.08)
        }
    }
    
    func recordAndRecognizeSpeech() {
      let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(title: "Speech Recognizer Error", message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = String(bestString[indexTo...])
                    
                    self.recognizedTextLabel.text = lastString
                    
                    
                    // insert your Triggerwords here
                    // pay attention to capital letters
                    if lastString == "Taschenlampe" || lastString == "an" || lastString == "An"{
                        self.🔦()
                        self.torchLabel.text = "Taschenlampe an!"
                    }else {
                        self.torchLabel.text = "Taschenlampe aus!"
                    }
                    if lastString == "aus" || lastString == "Aus" {
                        self.disableTorch()
                        self.torchLabel.text = "Taschenlampe aus!"
                    }
                }
                self.checkForColorsSaid(resultString: lastString)
            } else if let error = error {
                self.sendAlert(title: "Speech Recognizer Error", message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    
    enum Color: String {
        case Rot, Orange, Gelb, Grün, Blau, Lila, Schwarz, Grau, Pink,
        rot, orange, gelb, grün, blau, lila, schwarz, grau, pink
        
        var create: UIColor {
            switch self {
            case .Rot:
                return UIColor.red
            case .Orange:
                return UIColor.orange
            case .Gelb:
                return UIColor.yellow
            case .Grün:
                return UIColor.green
            case .Blau:
                return UIColor.blue
            case .Lila:
                return UIColor.purple
            case .Schwarz:
                return UIColor.black
            case .Grau:
                return UIColor.gray
            case .Pink:
                return UIColor.systemPink
            case .rot:
                return UIColor.red
            case .orange:
                return UIColor.orange
            case .gelb:
                return UIColor.yellow
            case .grün:
                return UIColor.green
            case .blau:
                return UIColor.blue
            case .lila:
                return UIColor.purple
            case .schwarz:
                return UIColor.black
            case .grau:
                return UIColor.gray
            case .pink:
                return UIColor.systemPink
            }
        }
    }
    
    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil
        
        // stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    
    @IBAction func startButton(_ sender: Any) {
        if isRecording == true {
            cancelRecording()
            isRecording = false
            startButton.backgroundColor = UIColor.gray
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            startButton.backgroundColor = UIColor.red
        }
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.recognizedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.recognizedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.recognizedTextLabel.text = "Speech recognition not yet authorized"
                @unknown default:
                    return
                }
            }
        }
    }
        
    //MARK: - UI / Set view color.
        func checkForColorsSaid(resultString: String) {
            guard let color = Color(rawValue: resultString) else { return }
            colorView.backgroundColor = color.create
            self.recognizedTextLabel.text = resultString
        }
        
    //MARK: - Alert
        func sendAlert(title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    
    func 🔦(){
        let date = Date()
        let hour = Calendar.current.component(.hour, from: date)
        
        if let avDevice = AVCaptureDevice.default(for: AVMediaType.video){
            if (avDevice.hasTorch){
                do {
                    try avDevice.lockForConfiguration()
                } catch {
                    print("something: \(error)")
                }
                if (avDevice.isTorchAvailable && hour >= 16 || hour <= 6){
                    do {
                     let _ = try avDevice.setTorchModeOn(level: 0.1)
                    } catch {
                        print("bbb: \(error)")
                    }
                }
                else if (avDevice.isTorchAvailable){
                    do {
                        let _ = try avDevice.setTorchModeOn(level: 1)
                    } catch {
                        print("bbb: \(error)")
                    }
                }
            }
            avDevice.unlockForConfiguration()
        }
    }
    
    func disableTorch(){
        if let avDevice = AVCaptureDevice.default(for: AVMediaType.video){
            if (avDevice.hasTorch){
                do {
                    try avDevice.lockForConfiguration()
                } catch {
                    print("something: \(error)")
                }
                if avDevice.isTorchActive {
                    avDevice.torchMode = AVCaptureDevice.TorchMode.off
                }
            }
            avDevice.unlockForConfiguration()
        }
    }
    
    @IBAction func turnOffButtonTapped(_ sender: Any) {
        disableTorch()
    }
    
}

