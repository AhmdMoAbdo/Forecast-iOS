//
//  MyTabBarController.swift
//  Forecast
//
//  Created by Ahmed on 22/07/2023.
//

import UIKit

class MyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        adjustTabbarItemPosition()
        self.selectedIndex = 1
        self.tabBar.items?[0].title = "Saved".localiz()
        self.tabBar.items?[2].title = "Alerts".localiz()
    }
    
    func adjustTabbarItemPosition(){
        if UserDefaultsManger.userDefaultHandler.getLanguage() == LanguageType.en.rawValue {
            self.tabBar.items?[0].titlePositionAdjustment.horizontal = 30
            self.tabBar.items?[2].titlePositionAdjustment.horizontal = -30
        }else{
            self.tabBar.items?[0].titlePositionAdjustment.horizontal = -30
            self.tabBar.items?[2].titlePositionAdjustment.horizontal = 30
        }
    }
}
