//
//  ViewController.swift
//  StopWatch
//
//  Created by Saikumar on 8/1/20.
//  Copyright © 2020 Saikumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var recordTable: UITableView!
    @IBOutlet weak var timerLabel: UILabel!
    
    var isRunning = false {
        didSet {
            if isRunning == true {
                leftButton.setTitle("Lap", for: .normal)
                rightButton.setTitle("Stop", for: .normal)
                start()
                mainNSTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                    self.timerLabel.text = self.inString
                }
            } else {
                leftButton.setTitle("Reset", for: .normal)
                rightButton.setTitle("Start", for: .normal)
                mainNSTimer.invalidate()
                pause()
            }
        }
    }
    var mainNSTimer = Timer()
    var records = [String]()
    
    var startTime: TimeInterval?
    var currentTime: TimeInterval {
        return NSDate.timeIntervalSinceReferenceDate
    }
    var lapsTime: TimeInterval {
        return currentTime - startTime!
    }
    var freezedTime: TimeInterval = 0.0
    var inString: String {
        let time = lapsTime
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let fraction = Int(time * 100) % 100
        let string = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds) + ":" + String(format: "%02d", fraction)
        return string
    }
    
    func start() {
        if startTime == nil {
            startTime = currentTime
        } else {
            startTime = currentTime - freezedTime
        }
    }
    func reset() {
        startTime = nil
    }
    func pause() {
        freezedTime = lapsTime
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordTable.dataSource = self
        recordTable.delegate = self
        
        leftButton.setTitle("Reset", for: .normal)
        rightButton.setTitle("Start", for: .normal)
        
        records = loadRecords()
        recordTable.reloadData()
        if records.count > 0 {
            recordTable.scrollToRow(at: IndexPath(row: records.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LapsTableViewCell", for: indexPath) as! LapsTableViewCell
        cell.orderNumber.text = String(indexPath.row + 1) + "."
        cell.recordTime.text = records[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func leftButtonAction(_ sender: UIButton) {
        if isRunning {
            let newIndexPath = IndexPath(row: records.count, section: 0)
            records.append(timerLabel.text!)
            DispatchQueue.main.async {
                self.recordTable.insertRows(at: [newIndexPath], with: .top)
                self.recordTable.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
            }
            
        } else {
            records.removeAll()
            DispatchQueue.main.async {
                self.recordTable.reloadData()
            }
            reset()
            timerLabel.text = "00:00:00"
        }
        saveRecords()
    }
    @IBAction func rightButtonAction(_ sender: UIButton) {
        isRunning = !isRunning
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func saveRecords() {
        UserDefaults.standard.set(records, forKey: "savedRecords")
    }
    private func loadRecords() -> [String] {
        guard let records = UserDefaults.standard.object(forKey: "savedRecords") as? [String] else {
            return []
        }
        return records
    }
    
}

class LapsTableViewCell: UITableViewCell {
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var recordTime: UILabel!
}
