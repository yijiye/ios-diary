//
//  Diary - DiaryViewController.swift
//  Created by 리지, Goat
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class DiaryListViewController: UIViewController {
    private let diaryTableView: UITableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var myDiary: [DiaryCoreData]?
    private var filteredDiary: [DiaryCoreData] = []
    private var weatherIcon: [String: UIImage] = [:]
    
    private let group = DispatchGroup()
    
    private var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        
        return isActive && isSearchBarHasText
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLayout()
        setUpView()
        configureSearchController()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpMyDiary()
    }
    
    private func setUpMyDiary() {
        guard let diary = CoreDataManager.shared.readAll() else { return }
        myDiary = diary
        
        diary.forEach {
            if let icon = $0.icon {
                fetchWeatherIcon(icon: icon)
            }
        }
        
        group.notify(queue: .main) {
            self.diaryTableView.reloadData()
        }
    }
    
    private func fetchWeatherIcon(icon: String) {
        group.enter()
        let weatherEndpoint = WeatherEndpoint.weatherIcon(icon: icon)
        NetworkManager.shared.imageLoad(endPoint: weatherEndpoint) { [self] in
            switch $0 {
            case .failure(let error):
                DispatchQueue.main.async {
                    AlertManager.shared.showErrorAlert(target: self, error: error)
                }
            case .success(let result):
                guard let fetchedIconImage = UIImage(data: result) else { return }
                self.weatherIcon[icon] = fetchedIconImage
                self.group.leave()
            }
        }
    }
    
    // MARK: Autolayout
    private func setUpLayout() {
        view.backgroundColor = .white
        view.addSubview(diaryTableView)
        let safeArea = view.safeAreaLayoutGuide
        
        diaryTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            diaryTableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            diaryTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            diaryTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            diaryTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    private func setUpView() {
        diaryTableView.register(DiaryTableViewCell.self, forCellReuseIdentifier: DiaryTableViewCell.identifier)
        diaryTableView.dataSource = self
        diaryTableView.delegate = self
    }
    
    // MARK: SearchController
    private func configureSearchController() {
        searchController.searchBar.placeholder = "검색"
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    // MARK: NavigationBar
    private func configureNavigationBar() {
        navigationItem.title = "일기장"
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonTapped))
        navigationItem.rightBarButtonItem = plusButton
    }
    
    @objc private func plusButtonTapped() {
        let diaryDetailViewController = DiaryDetailViewController(fetchedDiary: nil, mode: .create, titleText: nil, bodyText: nil)
        navigationController?.pushViewController(diaryDetailViewController, animated: true)
    }
    
    private func showDeleteAlert(handler: ((UIAlertAction) -> Void)?) {
        AlertManager.shared.showAlert(target: self,
                                      title: "진짜요?",
                                      message: "정말로 삭제하시겠어요?",
                                      defaultTitle: "취소",
                                      destructiveTitle: "삭제",
                                      destructiveHandler: handler)
    }
}

extension DiaryListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sampleDiary = myDiary else { return 0 }
        
        return isFiltering ? filteredDiary.count : sampleDiary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let diaryCell: DiaryTableViewCell = tableView.dequeueReusableCell(withIdentifier: DiaryTableViewCell.identifier) as? DiaryTableViewCell,
              let myDiary = myDiary else { return UITableViewCell() }
    
        if isFiltering {
            sendfilteredDiary(to: diaryCell, item: myDiary, indexPath: indexPath)
        } else {
            sendMyDiary(to: diaryCell, item: myDiary, indexPath: indexPath)
        }
        return diaryCell
    }
    
    private func sendfilteredDiary(to cell: DiaryTableViewCell, item: [DiaryCoreData], indexPath: IndexPath) {
        let image = setUpIconImage(item: item, indexPath: indexPath)
        cell.setupItem(item: filteredDiary[indexPath.row], iconImage: image)
    }
    
    private func sendMyDiary(to cell: DiaryTableViewCell, item: [DiaryCoreData], indexPath: IndexPath) {
        let image = setUpIconImage(item: item, indexPath: indexPath)
        cell.setupItem(item: item[indexPath.row], iconImage: image)
    }
    
    private func setUpIconImage(item: [DiaryCoreData], indexPath: IndexPath) -> UIImage? {
        var image: UIImage?
        
        if let icon = item[indexPath.row].icon,
           let iconImage = weatherIcon[icon] {
            image = iconImage
        } else {
           image = nil
        }
        
        return image
    }
}

extension DiaryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let diary = myDiary,
              let id = diary[indexPath.row].id,
              let fetchedDiary = CoreDataManager.shared.read(id: id) else { return }
        
        let diaryDetailViewController = DiaryDetailViewController(fetchedDiary: fetchedDiary, mode: .edit, titleText: fetchedDiary.title, bodyText: fetchedDiary.body)
        
        self.navigationController?.pushViewController(diaryDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let diary = myDiary,
              let title = diary[indexPath.row].title,
              let body = diary[indexPath.row].body else { return UISwipeActionsConfiguration() }
        
        let share = UIContextualAction(style: .normal, title: "공유") { [weak self] (_, _, success: @escaping (Bool) -> Void) in
            
            let textToShare = DiaryActivityItemSource(title: title, body: body)
            let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
            
            self?.present(activityViewController, animated: true, completion: nil)
            
            success(true)
        }
        share.backgroundColor = .systemTeal
        
        let delete = UIContextualAction(style: .normal, title: "삭제") { [weak self] (_, _, success: @escaping (Bool) -> Void) in
            
            self?.showDeleteAlert(handler: { _ in
                guard let id = diary[indexPath.row].id else { return }
                CoreDataManager.shared.delete(id: id)
                self?.setUpMyDiary()
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            })
            success(true)
        }
        delete.backgroundColor = .systemPink
        
        return UISwipeActionsConfiguration(actions: [share, delete])
    }
}

extension DiaryListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text,
              let myDiary = self.myDiary else { return }
        
        self.filteredDiary = myDiary.filter {
            guard let title = $0.title,
                  let body = $0.body else { return false }
            return title.localizedCaseInsensitiveContains(text) || body.localizedCaseInsensitiveContains(text)
        }
        
        self.diaryTableView.reloadData()
    }
}
