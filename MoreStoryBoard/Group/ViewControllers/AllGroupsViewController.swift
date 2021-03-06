//
//  AllGroupsViewController.swift
//  Jome17Wave_iOS
//
//  Created by Karena on 2020/11/11.
//

import UIKit

class AllGroupsViewController: UIViewController {
  
    
    @IBOutlet weak var tableView: UITableView!
    var allGroups = [PersonalGroup]()
    let url = URL(string: "\(common_url)jome_member/GroupOperateServlet")
    var groupInfoViewController: GroupInfoViewController?
    
    struct PropertyKeys {
        static let allGroupsCell = "GroupListTableViewCell"
        static let statusCencel = " 已取消 "
        static let statusLast = " 最新發佈 "
        static let statusComing = " 即將開始 "
        static let statusFinished = " 已結束 "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        loadAllGroups()
//        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "GroupListTableViewCell", bundle: nil), forCellReuseIdentifier: "GroupListTableViewCell")
//        tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
    }
    
    func tableViewAddRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(GroupInfoViewController.fetchAllGroups), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension AllGroupsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.allGroupsCell, for: indexPath) as! GroupListTableViewCell
        cell.groupImageView.image = nil
        cell.dateLabel.text = ""
        let group = allGroups[indexPath.row]
        cell.nameLabel.text = group.groupName
        cell.locationLabel.text = group.surfName
        if let date = group.assembleTime{
            cell.dateLabel.text = dateFormatter(assembleTimeStr: date)
        }
        /* 設定照片 */
        var requestParam = [String: Any]()
        requestParam["action"] = "getImage"
        requestParam["groupId"] = group.groupId
        requestParam["imageSize"] = cell.frame.width
        var image: UIImage?
        executeTask(url!, requestParam) { (data, response, error) in
            if error == nil {
                if data != nil {
                    image = UIImage(data: data!)
                }
                if image == nil {
                    image = UIImage(named: "noImage.jpg")
                }
                DispatchQueue.main.async {cell.groupImageView.image = image}
            } else {
                print(error!.localizedDescription)
            }
        }
        
        /* 設定活動狀態 */
        switch group.groupStatus {
        case 0:
            cell.statusLabel.backgroundColor = UIColor(red: 154/255, green: 208/255, blue: 234/255, alpha: 1) //淺藍
            cell.statusLabel.textColor = UIColor(red: 4/255, green: 66/255, blue: 99/255, alpha: 1) //深藍
            cell.statusLabel.text = PropertyKeys.statusCencel
        case 1:
            cell.statusLabel.backgroundColor = UIColor(red: 84/255, green: 70/255, blue: 231/255, alpha: 1) //紫
            cell.statusLabel.textColor = UIColor(red: 248/255, green: 248/255, blue: 255/255, alpha: 1) //白
            cell.statusLabel.text = PropertyKeys.statusLast
        case 2:
            cell.statusLabel.backgroundColor = UIColor(red: 244/255, green: 3/255, blue: 105/255, alpha: 1) //桃紅
            cell.statusLabel.textColor = UIColor(red: 248/255, green: 248/255, blue: 255/255, alpha: 1) //白
            cell.statusLabel.text = PropertyKeys.statusComing
        case 3:
            cell.statusLabel.backgroundColor = UIColor(red: 4/255, green: 66/255, blue: 99/255, alpha: 1) //深藍
            cell.statusLabel.textColor = UIColor(red: 248/255, green: 248/255, blue: 255/255, alpha: 1) //白
            cell.statusLabel.text = PropertyKeys.statusFinished
        default:
            print("Group Status Error")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectGroup = allGroups[indexPath.row]
        if let controller = storyboard?.instantiateViewController(identifier: "GroupDetailTableViewController") as? GroupDetailTableViewController{
            controller.group = selectGroup
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        // 編輯按鈕
//        let editGroup = allGroups[indexPath.row]
//        let edit = UIContextualAction(style: .normal, title: "編輯") { (action, view, bool) in
//            if let controller = self.storyboard?.instantiateViewController(identifier: "InsertGroupTableViewController") as? InsertGroupTableViewController{
//                controller.editGroup = editGroup
//                self.navigationController?.pushViewController(controller, animated: true)
//            }
//        }
//        edit.backgroundColor = .lightGray
//
//        //刪除按鈕
//        let cancel = UIContextualAction(style: .normal, title: "停團") { (action, view, bool) in
//            self.cancelGroup(groupId: editGroup.groupId)
//        }
//        cancel.backgroundColor = .red
//
//        let swipeActions = UISwipeActionsConfiguration(actions: [cancel, edit])     //delete,edit順序 會影響顯示順序
//        // true代表滑到底視同觸發第一個動作；false代表滑到底也不會觸發任何動作
//        swipeActions.performsFirstActionWithFullSwipe = false
//        return swipeActions
//    }
    
    func dateFormatter(assembleTimeStr: String) -> String {
        var dateStr = ""
        let formatter = DateFormatter()
        if Locale.current.description.contains("TW") {
            formatter.locale = Locale(identifier: "zh_TW")
        }
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let assembleTimeDate = formatter.date(from: assembleTimeStr){
            formatter.dateFormat = "yyyy-MM-dd"
            dateStr = formatter.string(from: assembleTimeDate)
        }
        return dateStr
    }
    
//    func cancelGroup(groupId: String) {
//        var requestParm = [String: Any]()
//        requestParm["action"] = "cancelGroup"
//        requestParm["cancelGroupId"] = groupId
//        executeTask(url!, requestParm) { (data, response, error) in
//            if error == nil{
//                if let data = data,
//                   let result = try? JSONDecoder().decode(changeResponse.self, from: data){
//                    let resultCode = result.resultCode
//                    DispatchQueue.main.async {
//                        if resultCode > 0{
//                            self.tableView.reloadData()
//                        }else{
//                            print("Cancel failed! resultCode: \(resultCode)")
//                        }
//                    }
//                }
//            }else{
//                print(error!.localizedDescription)
//            }
//        }
//    }
}
