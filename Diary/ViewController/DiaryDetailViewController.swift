//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by 리지, goat on 2023/04/27.
//

import UIKit
import CoreLocation

final class DiaryDetailViewController: UIViewController, CLLocationManagerDelegate {
    enum Mode {
        case edit
        case create
    }
    
    private let fetchedDiary: DiaryCoreData?
    private var mode: Mode
    private var titleText: String?
    private var bodyText: String?
    
    private let locationManager = CLLocationManager()
    private var latitude: String?
    private var longitude: String?
    private var weatherState: String?
    private var icon: String?
    
    private let networkManager = NetworkManager()
    
    private lazy var diaryTextView: UITextView = {
        let textView = UITextView()
        
        switch mode {
        case .edit:
            guard let title = fetchedDiary?.title,
                  let body = fetchedDiary?.body else { return textView }
            textView.text = title + "\n" + body
        case .create:
            textView.text = "내용을 입력하세요"
            textView.textColor = .secondaryLabel
        }
        
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.addDoneButton(title: "Done", target: self, selector: #selector(dismissKeyboard))
        
        textView.delegate = self
        
        return textView
    }()
    
    init(fetchedDiary: DiaryCoreData?, mode: Mode, titleText: String?, bodyText: String?) {
        self.fetchedDiary = fetchedDiary
        self.mode = mode
        self.titleText = titleText
        self.bodyText = bodyText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureNavigationBar()
        configureDiaryView()
        setUpKeyboardNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           
           if mode == .create {
               setUpLocation()
               diaryTextView.addDoneButton(title: "Done", target: self, selector: #selector(dismissKeyboard))
               diaryTextView.becomeFirstResponder()
           }
       }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveDiary()
    }
    
    // MARK: CLLocation
    private func setUpLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location = locations.first {
            latitude = String(location.coordinate.latitude)
            longitude = String(location.coordinate.longitude)
            fetchWeatherAPI()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        default:
            AlertManager.shared.showAlert(target: self,
                                          title: "위치 정보 필요",
                                          message: "날씨를 표시하려면 위치 권한이 필요합니다. \n 허용하지 않으면 날씨표시 없이 일기를 작성합니다.",
                                          defaultTitle: "날씨없는 일기 작성",
                                          destructiveTitle: "권한 변경",
                                          destructiveHandler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            })
        }
    }
    
    // MARK: Autolayout
    private func configureDiaryView() {
        view.addSubview(diaryTextView)
        
        let safeArea = view.safeAreaLayoutGuide
        
        diaryTextView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        let textViewHeight = diaryTextView.heightAnchor.constraint(equalTo: safeArea.heightAnchor)
        textViewHeight.priority = .defaultHigh
        
        diaryTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            diaryTextView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            diaryTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            diaryTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -14),
            diaryTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            textViewHeight
        ])
    }
    
    // MARK: NavigationBar
    private func configureNavigationBar() {
        let ellipsisButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), style: .plain, target: self, action: #selector(ellipsisButtonTapped))
        navigationItem.rightBarButtonItem = ellipsisButton
        
        switch mode {
        case .edit:
            guard let date = fetchedDiary?.date else { return }
            navigationItem.title = DateFormatterManager.shared.convertToFomattedDate(of: date)
        case .create:
            let today = Date().timeIntervalSince1970
            navigationItem.title = DateFormatterManager.shared.convertToFomattedDate(of: today)
        }
    }
    
    @objc func ellipsisButtonTapped() {
        AlertManager.shared.showActionSheet(target: self,
                                            title: nil,
                                            message: nil,
                                            defaultTitle: "Share...",
                                            destructiveTitle: "Delete",
                                            defaultHandler: { _ in self.showActivityView() },
                                            destructiveHandler: { _ in self.showDeleteAlert() })
    }
    
    private func showActivityView() {
        guard let titleText = titleText,
              let bodyText = bodyText else {
            AlertManager.shared.showAlert(target: self,
                                          title: "일기를 작성해주세요!",
                                          message: "비어있는 일기는 공유되지 않습니다.",
                                          defaultTitle: "확인",
                                          destructiveTitle: nil,
                                          destructiveHandler: nil)
            return }
        
        let textToShare = DiaryActivityItemSource(title: titleText, body: bodyText)
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func showDeleteAlert() {
        AlertManager.shared.showAlert(target: self,
                                      title: "진짜요?",
                                      message: "정말로 삭제하시겠어요?",
                                      defaultTitle: "취소",
                                      destructiveTitle: "삭제",
                                      destructiveHandler: { _ in
            guard let id = self.fetchedDiary?.id else { return }
            CoreDataManager.shared.delete(id: id)
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    // MARK: Keyboard
    private func setUpKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              var keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        keyboardFrame = view.convert(keyboardFrame, from: nil)
        var contentInset = diaryTextView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        diaryTextView.contentInset = contentInset
        diaryTextView.scrollIndicatorInsets = diaryTextView.contentInset
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        diaryTextView.contentInset = UIEdgeInsets.zero
        diaryTextView.scrollIndicatorInsets = diaryTextView.contentInset
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func saveDiary() {
        guard let titleText = titleText,
              let bodyText = bodyText else {
            AlertManager.shared.showAlert(target: self,
                                          title: "일기를 작성해주세요!",
                                          message: "비어있는 일기는 저장되지 않습니다.",
                                          defaultTitle: "확인",
                                          destructiveTitle: nil,
                                          destructiveHandler: nil)
            return }
        
        switch mode {
        case .edit:
            guard let date = fetchedDiary?.date,
                  let id = fetchedDiary?.id else { return }
            
            if let weatherState = self.weatherState,
               let icon = self.icon {
                let diary = MyDiary(id: UUID(), title: titleText, body: bodyText, createdDate: date, weatherState: weatherState, icon: icon)
                CoreDataManager.shared.update(id: id, diary: diary)
            } else {
                let diary = MyDiary(id: UUID(), title: titleText, body: bodyText, createdDate: date)
                CoreDataManager.shared.update(id: id, diary: diary)
            }
            
        case .create:
            let today = Double(Date().timeIntervalSince1970)
            
            if let weatherState = self.weatherState,
               let icon = self.icon {
                let diary = MyDiary(id: UUID(), title: titleText, body: bodyText, createdDate: today, weatherState: weatherState, icon: icon)
                CoreDataManager.shared.create(diary: diary)
            } else {
                let diary = MyDiary(id: UUID(), title: titleText, body: bodyText, createdDate: today)
                CoreDataManager.shared.create(diary: diary)
            }
        }
        mode = .edit
    }
    
    // MARK: weatherAPI
    private func fetchWeatherAPI() {
        guard let latitude = self.latitude,
              let longitude = self.longitude else { return }
        
        let information = WeatherEndpoint.weatherInformation(latitude: latitude, longitude: longitude)
        networkManager.startLoad(endPoint: information, returnType: WeatherInformation.self) {
            switch $0 {
            case .failure(let error):
                DispatchQueue.main.async {
                    AlertManager.shared.showErrorAlert(target: self, error: error)
                }
            case .success(let result):
                self.weatherState = result.weather[0].weatherState
                self.icon = result.weather[0].icon
            }
        }
    }
}

extension DiaryDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard diaryTextView.textColor == .secondaryLabel else { return }
        diaryTextView.textColor = .label
        diaryTextView.text = nil
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        saveDiary()
        
        if diaryTextView.text.isEmpty {
            diaryTextView.text = "내용을 입력하세요"
            diaryTextView.textColor = .secondaryLabel
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let text = diaryTextView.text,
              let titleText = text.components(separatedBy: "\n").first else { return }
        
        self.titleText = titleText
        
        if text.components(separatedBy: "\n").count == 1 {
            self.bodyText = ""
        } else {
            self.bodyText = text.replacingOccurrences(of: "\(String(describing: titleText))\n", with: "")
        }
    }
}
