//
//  DailyTableHandler.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import UIKit

class DailyTableHandler:NSObject,UITableViewDataSource,UITableViewDelegate{
    
    let cellName: String
    var dailyDataArr: [Daily] = []
    var offset = 0
    
    init(cellName: String) {
        self.cellName = cellName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName) as! DailyTableViewCell
        cell.setDailyData(dayData: dailyDataArr[indexPath.row], offset: offset)
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
