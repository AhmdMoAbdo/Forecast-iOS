//
//  HourlyCollectionHandler.swift
//  Forecast
//
//  Created by Ahmed on 20/07/2023.
//

import UIKit

class HourlyCollectionHandler: NSObject,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    let cellName: String
    var hourlyDataArr: [Current] = []
    var offset = 0
    
    init(cellName: String) {
        self.cellName = cellName
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if hourlyDataArr.isEmpty {
            return 0
        }else {
            return 23
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! HourlyCollectionViewCell
        cell.setHourlyData(hourlyData: hourlyDataArr[indexPath.row] , offset: offset)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
