//
//  ViewController.swift
//  AlexUninIPad
//
//  Created by Viktor Puzakov on 9/5/19.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var oneCharacterLabel: UILabel!
    @IBOutlet weak var twoCharacterLabel: UILabel!
    @IBOutlet weak var threeCharacterLabel: UILabel!
    @IBOutlet weak var fourCharacterLabel: UILabel!
    @IBOutlet weak var fiveCharacterLabel: UILabel!
    @IBOutlet weak var sixCharacterLabel: UILabel!
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    
    var song: String! {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var buttonCharacters: [Character] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var charactersCount: Int = 0
    
    var textSongCharacters: Set<Character> {
        return Set(song.uppercased())
    }
    
    var textSongWords: [String.SubSequence] {
        if let song = song {
            return song.split(separator: " ")
        } else {
            return []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "tbCell")
        setupConnectivity()
    }

    func setupConnectivity() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    func defaultValue() {
        self.song = "УДАЧНОЙ ИГРЫ"
        buttonCharacters = ["Н", "У", "Ы", "А", "Й", "О", "И", "Ч", "Г", "Р", "Д"]
        clearLabel()
    }
    
    func numberCharacterSetValue(label: UILabel, letter: String) {
        DispatchQueue.main.async {
            label.text = letter
            if self.textSongCharacters.contains(Character(letter)) {
                label.textColor = UIColor.green
            } else {
                label.textColor = UIColor.red
            }
        }
    }
    
    func clearLabel() {
        DispatchQueue.main.async {
            self.oneCharacterLabel.text = nil
            self.twoCharacterLabel.text = nil
            self.threeCharacterLabel.text = nil
            self.fourCharacterLabel.text = nil
            self.fiveCharacterLabel.text = nil
            self.sixCharacterLabel.text = nil
        }
    }
    
    @IBAction func showConnectivityAction(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Соединение с другими устройствами", message: "Хотите подключиться?", preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Подключиться", style: .default, handler: { (action: UIAlertAction) in
        let mcBrowser = MCBrowserViewController(serviceType: "ba-td", session: self.mcSession)
        mcBrowser.delegate = self
        self.present(mcBrowser, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action: UIAlertAction) in
        }))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension ViewController: MCBrowserViewControllerDelegate, MCSessionDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            defaultValue()
            print("Connected: \(peerID.displayName)")
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
        case MCSessionState.notConnected:
            print("Not connected: \(peerID.displayName)")
        @unknown default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let string = String(data: data, encoding: .utf8) {
            if string.count == 1 {
                if buttonCharacters.contains(Character(string)) || charactersCount >= 6 {
                    return
                } else {
                    charactersCount += 1
                    self.buttonCharacters.append(Character(string))
                    switch charactersCount {
                    case 1: numberCharacterSetValue(label: oneCharacterLabel, letter: string)
                    case 2: numberCharacterSetValue(label: twoCharacterLabel, letter: string)
                    case 3: numberCharacterSetValue(label: threeCharacterLabel, letter: string)
                    case 4: numberCharacterSetValue(label: fourCharacterLabel, letter: string)
                    case 5: numberCharacterSetValue(label: fiveCharacterLabel, letter: string)
                    case 6: numberCharacterSetValue(label: sixCharacterLabel, letter: string)
                    default: break
                    }
                }
            } else {
                if string == "getAnswerPlease" {
                    buttonCharacters = Array(Set(song.uppercased()))
                } else if string == "endThisGame" {
                    defaultValue()
                } else {
                    song = string
                    buttonCharacters = []
                    charactersCount = 0
                }
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textSongWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GameTableViewCell = tableView.dequeueReusableCell(withIdentifier: "tbCell", for: indexPath) as! GameTableViewCell
        cell.word = String(textSongWords[indexPath.row])
        cell.buttonTouchedCharacters = self.buttonCharacters
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}
