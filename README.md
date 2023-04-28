# README

# 일기장 :notebook: 

> 일기를 작성,수정,저장할 수 있는 일기장 앱 구현
> 
> 프로젝트 기간: 2023.04.24-2023.04.28
> 

## 팀원
| Goat | 리지 |
| :--------: |  :--------: | 
| <Img src ="https://i.imgur.com/yoWVC56.png" width="200" height="200"/>      |<Img src ="https://user-images.githubusercontent.com/114971172/221088543-6f6a8d09-7081-4e61-a54a-77849a102af8.png" width="200" height="200"/>
| [Github Profile](https://github.com/Goatt8) |[Github Profile](https://github.com/yijiye)


## 목차
1. [타임라인](#타임라인)
2. [프로젝트 구조](#프로젝트-구조)
3. [실행 화면](#실행-화면)
4. [트러블 슈팅](#트러블-슈팅) 
5. [핵심경험](#핵심경험)
6. [참고 링크](#참고-링크)


# 타임라인 

### PARTI

|    날짜    | 내용 |
|:----:| ---- |
| 2023.04.24 | JSON객체 생성 및 DiaryTalebleViewCell 구현, DateFormatterManager 구현|
| 2023.04.25 | textView, keyboard 구현 및 notificationCenter로 키보드 textView 가리지않게 설정|
| 2023.04.26 | autolayout 정리|
| 2023.04.27 | keyboarad dismiss button 구현, DiaryListVC -> DiaryDetailVC로 데이터 이동 구현|
| 2023.04.28 | CoreDataManager - CRUD 구현,  README작성|


<br/>


# 프로젝트 구조

## File Tree
```typescript
Diary
├── Diary+CoreDataClass
├── Diary+CoreDataProperties
├── Diary.xcdatamodeld
├── .swiftlint
├── Diary
│   ├── Model
│   │   ├── SampleDiary.swift
│   │   ├── Decoder.swift
│   │   ├── DateFormatterManager.swift
│   │   └── CoreDataManager.swift
│   ├── View
│   │   ├── DiaryTableViewCell.swift
│   │   └── extension + UITextView.swift
│   ├── ViewController
│   │   ├── DiaryListViewController.swift
│   │   └── DiaryDetailViewController.swift
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Assets.xcassets
│   ├── LaunchScreen
│   ├── Info.plist
│   │   └── Assets.xcassets
├── DiaryTests
│   ├── DiaryTests.swift
├── CoreDataManagerTest
└─  └── CoreDataManagerTest.swift 
```


 <br/>  

# 실행 화면

|<center>DiaryListVC -> DiaryDetailVC<br>상단 plus버튼클릭이동</center>|<center>DiaryListVC -> DiaryDetailVC<br>cell 클릭시 이동</center>|
|:----:|:----:|
| <img src = "https://i.imgur.com/E1yQLsF.gif" width = 300>| <img src = "https://i.imgur.com/pywOO9u.gif" width = 300>|
상단 plus버튼 클릭시 DetailVC로 이동하며, 키보드는 자동으로 띄워집니다.| cell클릭시 DetailVC로 이동하며, 키보드는 화면을 클릭했을때 반응해 띄워지며, 키보드 상단 `Done` 버튼을 통해 키보드를 다시 내려줄 수 있습니다. |


<br/>

# 트러블 슈팅

## 1️⃣ DateFormatterManager, Locale 관련 이슈

### 🔍 문제점
지역화를 하여 지역에 따라 맞는 날짜 표현이 가능하도록 구현해야 했습니다. 처음엔 단순히 대한민국이니 Locale 값에 "ko-KR"을 주고 "yyyy년 MM월 DD일"로 고정을 시켰습니다.
이렇게 하니 다른 지역에서 적용이 되지 않는 문제가 있었습니다.
또한 enum의 namespace 메서드 안에서 DateFormatter를 선언해주어 이 메서드를 호출할 때 마다 DateFormatter() 인스턴스가 생기는 문제가 있었습니다.
```swift
enum DateFormatterManager {
     static func convertToFomattedDate(of date: Int) -> String? {
         let dateFormatter = DateFormatter()
         let date = Date(timeIntervalSince1970: TimeInterval(date))

         dateFormatter.locale = Locale(identifier: "ko-KR")
         dateFormatter.dateFormat = "yyyy년 MM월 dd일"
     }
}
```
### 🛠️ 해결방법
이를 해결하고자 enum을 class로 변경하여 싱글톤으로 구현하였고, DateFormatter는 클로저 형식으로 선언해주도록 리팩토링하였습니다. 또한 지역에 맞게 설정이 변화하도록 Locale의 identifier를 `Locale.current.identifier`로 리팩토링하여 지역화를 해주었습니다. 그리고 년,월,일이 맞게 화면에 보여지도록 `dateStyle = .long`으로 주어 불필요한 dateFormat은 삭제하였습니다.

```swift
final class DateFormatterManager {
     static let shared = DateFormatterManager()
     private init() { }

     private let dateFormatter: DateFormatter = {
         let dateFormatter = DateFormatter()
         dateFormatter.locale = Locale(identifier: Locale.current.identifier)
         dateFormatter.dateStyle = .long

         return dateFormatter
     }()

     func convertToFomattedDate(of date: Int) -> String? {
         let date = Date(timeIntervalSince1970: TimeInterval(date))

         return dateFormatter.string(from: date)
     }
}
```

<br>


## 2️⃣ plus 버튼 화면과 tableViewCell 터치로 넘어가는 화면 구현
    
### 🔍 문제점
plus 버튼을 누르면 새로운 일기장을 추가할 수 있는 화면이 나오고 일기장 리스트에서 tableViewCell을 터치하면 저장된 일기장 화면이 보여지도록 구현해야 했습니다. 
처음 고민했던 점은 ViewController를 각각 구현하여 다른 화면으로 구현하였고, 두 화면의 layout이나 키보드 구현 등 많은 요소가 공통되어 이를 protocol + extension으로 구현하였습니다.

```swift
protocol DiaryTextViewProtocol {
     func configureNavigationBar(viewController: UIViewController)
     func configureDiaryTextView(view: UIView, textView: UITextView)
     func setUpNotification() 
 }

extension DiaryTextViewProtocol {
    ... 
    기본 구현 코드 
    ...
}
```

그러나 굳이 두개의 ViewController를 구현하는 것 보다 하나의 ViewController로 관리하고 화면에 보여지는 것을 분기처리하여 띄워주는게 더 적절하다고 생각하여 수정하였습니다.

### 🛠️ 해결방법

먼저 첫 번째 화면에서 plus 버튼을 눌렀을 때와 TableViewCell을 터치했을 때 화면전환 하는 곳에서 두 번째 화면의 diary 변수에 값을 다르게 넘겨주었습니다. 하나의 ViewController로 관리하여 불필요한 파일 생성을 줄일 수 있엇습니다. 

**plus 버튼으로 화면전환시 nil 값 전달**
```swift
private func configureNavigationBar() {
        self.navigationItem.title = "일기장"
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonTapped))
        navigationItem.rightBarButtonItem = plusButton
    }
    
    @objc private func plusButtonTapped() {
        let diaryDetailViewController = DiaryDetailViewController(diary: nil, isAutomaticKeyboard: true)
        self.navigationController?.pushViewController(diaryDetailViewController, animated: true)
    }
```

**TableViewCell 터치하여 화면전환시 diary 값 전달**
```swift
extension DiaryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let diary = sampleDiary else { return }
        let diaryDetailViewController = DiaryDetailViewController(diary: diary[indexPath.row], isAutomaticKeyboard: false)
        self.navigationController?.pushViewController(diaryDetailViewController, animated: true)
    }
}
```

<br>

## 3️⃣ 화면 전환시 키보드 자동으로 띄우기
plus 버튼을 눌러 새로운 일기 작성화면으로 넘어가면 자동으로 키보드가 올라오도록 구현하고 싶었습니다. UITextView 공식문서를 확인해보면 아래와 같은 내용이 있었습니다.

```bash
Manage the keyboard
When the user taps in an editable text view, that text view becomes the first responder and automatically asks the system to display the associated keyboard. 
```

이를 통해 TextView를 클릭하면 자동으로 first responder가 되어 화면에 올라오도록 되므로 저희는 first responder를 이용하고자 찾아보니 `.becomeFirstResponder()` 프로퍼티가 있어 이를 활용하고자 했습니다.

### 🔍 문제점
화면이 넘어오면서 나타나야 하므로 `viewDidLoad()`에 호출하였습니다. 그러나 화면이 넘어오면서 같이 나타나기때문에 키보드가 옆에서 넘어오고 또한 일기장에 작성된 내용이 있다면 로딩되는 시간차 때문에 어색함이 있엇습니다.

### 🛠️ 해결방법
따라서 화면이 넘어가고 나서 키보드가 뜨도록 구현하고자 View의 생명주기를 활용하였습니다.

```swift
 override func viewDidAppear(_ animated: Bool) {
    if isAutomaticKeyboard == true {
        diaryTextView.becomeFirstResponder()
    }
}
```

`viewDidAppear`에 띄워주어 화면이 넘어가고 나서 키보드가 올라오도록 설정하였고, 화면에따라 자동으로 나타나거나 또는 클릭시 나타나도록 분기처리를 하였습니다.

<br>

## 4️⃣ contentInset - DiaryDetailViewController.textView 상단잘림현상

### 🔍 문제점
DiaryDetailViewController로 이동시 첫화면에서 TextView 상단이 아래사진과 같이 잘리는 현상이 발생했습니다. Autolayout을 정상적으로 잡았음에도 잘리는 현상이 발생했습니다.
<img src ="https://i.imgur.com/R4Sok34.png" width=30%>

### 🛠️ 해결방법
```swift!
  private func configureDiaryTextView() {
      diaryTextView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
   }
```
Scollview에도 적용되며, Scrollview의 성격을 갖고있는 TextView에도 적용되는 개념인 `contentInset`의 top값에 10을 넣어주자 상단에서 10만큼 거리를 벌리며 content가 정상적으로 view안에 들어왔습니다. content의 상하좌우에 padding을 주는 현상이 발생했고 이를통해 문제를 해결했습니다.

<br>

# 핵심경험

<details>
<summary><big>✅ TextView, TextField 시스템 제공 키보드 옵션 - InputAccessaryView</big></summary> 

<img src ="https://i.imgur.com/S8JSaxt.png" width=30%>

```swift
extension UITextView {
    func addDoneButton(title: String, target: Any, selector: Selector) {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                       target: nil,
                                       action: nil)
        let barButton = UIBarButtonItem(title: title,
                                        style: .plain,
                                        target: target,
                                        action: selector)
        
        toolBar.setItems([flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}
```
* 위와같이 코드 구현시 text가 fisrtResponder가 된다면 `UITextField, UITextView` 의 시스템제공 키보드에 악세사리 뷰를 연결하면 키보드 상단에 AccessaryView가 구현되는 것을 발견할 수 있습니다.
</details>

</br>

<details>
<summary><big>✅ StackView-layoutMargins</big></summary> 
TableViewCell에 넣는 요소를 StackView에 넣어 Autolayout을 잡았습니다. 이때 StackView의 Autolayout을 safeArea로 잡는 방법도 있지만 이 자체의 layoutMargins 을 이용하여 잡을 수 있는 방법을 학습하여 적용해보았습니다.
    
```swift
private let mainStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.spacing = 10
    stakView.axis = .vertical
    stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 40)
    stackView.isLayoutMarginsRelativeArrangement = true
        
    return stackView
}()
```
    
UIEdgeInsets에 값을 주어 View에 Stackview를 위치시킬 때 어느정도 margin을 줄 것인지 설정하여 autolayout을 잡았습니다. 또한 `isLayoutMarginsRelativeArrangement`의 기본값이 false이기 때문에 `isLayoutMarginsRelativeArrangement` 값을 `true`로 변경해주어 화면에 적용되도록 하였습니다.
    
</details>


----

# 참고 링크
## 블로그
- [StackView layoutMargin](https://velog.io/@dvhuni/UIStackView-Margin-적용하기)
            
## 공식 문서
- [Dateformatter](https://developer.apple.com/documentation/foundation/dateformatter)
- [UITextview](https://developer.apple.com/documentation/uikit/uitextview)
- [UIStackView](https://developer.apple.com/documentation/uikit/uistackview)
- [isLayoutMarginsRelativeArrangement](https://developer.apple.com/documentation/uikit/uistackview/1616220-islayoutmarginsrelativearrangeme)
- [Locale](https://developer.apple.com/documentation/foundation/locale)
- [contentInset](https://developer.apple.com/documentation/uikit/uiscrollview/1619406-contentinset)
