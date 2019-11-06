//
//  ViewController.swift
//  SamplerDemo
//
//  Created by Shane Dunne, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import UIKit
import AudioKit
import AudioKitUI

class ViewController: UIViewController {

    let conductor = Conductor.shared
    var isPlaying = false
    var currentSound = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        conductor.midi.addListener(self)
        setupUI()
        conductor.loadSamples(byIndex: currentSound)
    }


    func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let button = AKButton(title: "Change Sound", color: .red) { button in
            self.currentSound += 1
            self.currentSound %= 4
            self.conductor.loadSamples(byIndex: self.currentSound)
        }
        stackView.addArrangedSubview(button)

        let keyboardView = AKKeyboardView()
        keyboardView.delegate = self
        
        stackView.addArrangedSubview(keyboardView)


        view.addSubview(stackView)

        stackView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true

        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }

}

extension ViewController: AKKeyboardDelegate {

    func noteOn(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            self.conductor.playNote(note: note, velocity: 100, channel: 0)
        }
    }

    func noteOff(note: MIDINoteNumber) {
        DispatchQueue.main.async {
            self.conductor.stopNote(note: note, channel: 0)
        }
    }
}
extension ViewController: AKMIDIListener {

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.conductor.playNote(note: noteNumber, velocity: velocity, channel: channel)
        }
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
        DispatchQueue.main.async {
            self.conductor.stopNote(note: noteNumber, channel: channel)
        }
    }

    // MIDI Controller input
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {
        AKLog("Channel: \(channel + 1) controller: \(controller) value: \(value)")
        conductor.controller(controller, value: value)
    }

    // MIDI Pitch Wheel
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {
        conductor.pitchBend(pitchWheelValue)
    }

    // After touch
    func receivedMIDIAfterTouch(_ pressure: MIDIByte, channel: MIDIChannel) {
        conductor.afterTouch(pressure)
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte]) {
        // do nothing: silence superclass's log chatter
    }

    // MIDI Setup Change
    func receivedMIDISetupChange() {
        AKLog("midi setup change, midi.inputNames: \(conductor.midi.inputNames)")
        let inputNames = conductor.midi.inputNames
        inputNames.forEach { inputName in
            conductor.midi.openInput(name: inputName)
        }
    }

}
