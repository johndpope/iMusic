//
//  MPSearchingView.swift
//  iMusicPlayer
//
//  Created by Modi on 2019/3/20.
//  Copyright © 2019 Modi. All rights reserved.
//

import UIKit

private struct Constant {
    static let identifier = "MPSearchingViewTableViewCell"
    static let rowHeight = SCREEN_WIDTH * (46/375)
}

class MPSearchingView: BaseView {

    var itemClickedBlock: ((_ title: String) -> Void)?
    
    var model = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private let tableView = UITableView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //
        setupTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constant.identifier, bundle: nil), forCellReuseIdentifier: Constant.identifier)
        tableView.tableFooterView = UIView()
    }
    
}
extension MPSearchingView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.identifier) as! MPSearchingViewTableViewCell
        cell.title = model[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 获取当前数据源的标题
        let text = model[indexPath.row]
        if let b = itemClickedBlock {
            b(text)
        }
    }
}
