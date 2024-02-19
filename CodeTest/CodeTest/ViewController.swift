//
//  ViewController.swift
//  CodeTest
//
//  Created by Maple on 2024/2/19.
//

import UIKit
import Combine

struct MeetingTime {
    //开始时间
    let begin: Int
    //结束时间
    let end: Int
}

fileprivate let SongTableViewCellID = "SongTableViewCell"
fileprivate let toggleSelectWidth = (UIScreen.main.bounds.width - 40) / 2


class ViewController: UIViewController {

    var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var toggleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectToggleLeadingConstraint: NSLayoutConstraint!
    
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //题目一
//        let times = [MeetingTime(begin: 0, end: 30), MeetingTime(begin: 5, end: 10), MeetingTime(begin: 15, end: 20)]
//        let times = [MeetingTime(begin: 7, end: 10), MeetingTime(begin: 2, end: 4)]
//        let result = brainTest(meetingTimes: times)
//        print(result ? "true" : "false")
        
        
        
        
        //题目二
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange), name: UITextField.textDidChangeNotification, object: nil)
        
        let cellNib = UINib(nibName: "SongTableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: SongTableViewCellID)
        
        // Do any additional setup after loading the view.
        viewModel.$displaySongList.sink { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }.store(in: &cancellables)
        
        viewModel.$sortType.sink { [weak self] sortType in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.tableView.reloadData()
                self.selectToggleLeadingConstraint.constant = (sortType == 1) ? 2 : (toggleSelectWidth + 2)
                if let offBtn = self.toggleView.viewWithTag(100 + 1) as? UIButton {
                    offBtn.isEnabled = sortType != 1
                }
                if let priceBtn = self.toggleView.viewWithTag(100 + 2) as? UIButton {
                    priceBtn.isEnabled = sortType == 1
                }
            }
        }.store(in: &cancellables)
        self.clearSearchKey()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc fileprivate func textFieldTextDidChange() {
        let searchText = self.textField.text ?? ""
        self.viewModel.requestSongs(songName: searchText) { _, error in
            if let error = error {
                DispatchQueue.main.async{
                    let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @IBAction func clickCancelAction(_ sender: Any) {
        self.clearSearchKey()
    }
    
    @IBAction func clickSortAction(_ sender: UIButton) {
        self.viewModel.updateSortType(type: sender.tag - 100)
    }
    
    fileprivate func clearSearchKey() {
        self.textField.text = ""
        self.textFieldTextDidChange()
    }

}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongTableViewCellID, for: indexPath) as! SongTableViewCell
        cell.configureSong(song: self.viewModel.displaySongList[indexPath.row])
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displaySongList.count
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}


extension UIViewController {
    
    
    fileprivate func brainTest(meetingTimes: [MeetingTime]) -> Bool {
        
        var existMeetingTimes: [MeetingTime] = []
        
        for time in meetingTimes {
            for existTime in existMeetingTimes {
                if (time.begin >= existTime.begin && time.begin <= existTime.end)
                    || (time.end >= existTime.begin && time.end <= existTime.end) {
                    return false
                }
            }
            existMeetingTimes.append(time)
        }
        
        return true
    }
}
