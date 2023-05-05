# README
# 일기장 :notebook: 
> 일기를 작성,수정,저장할 수 있는 일기장 앱 구현
> 
> 프로젝트 기간: 2023.04.24-2023.05.05
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

### week1

|    날짜    | 내용 |
|:----:| ---- |
| 2023.04.24 | JSON객체 생성 및 DiaryTalebleViewCell 구현, DateFormatterManager 구현|
| 2023.04.25 | TextView, keyboard 구현 및 NotificationCenter로 키보드 TextView 가리지않게 설정|
| 2023.04.26 | autolayout 정리|
| 2023.04.27 | keyboarad dismiss button 구현, DiaryListVC -> DiaryDetailVC로 데이터 이동 구현|
| 2023.04.28 | CoreDataManager - CRUD 구현,  README작성|


### week2

|    날짜    | 내용 |
|:----:| ---- |
| 2023.05.01 | TextField 구현|
| 2023.05.02 | keyboard Done 버튼, CoreData 구현, CoreData 자동저장 기능추가|
| 2023.05.03 | ActivityView, TextField -> TextView로 수정|
| 2023.05.04 | AlertManager 구현, 빈 화면 로직 수정 및 알림 기능 추가 |
| 2023.05.05 | README 작성|

<br/>


# 프로젝트 구조

## File Tree
```typescript
Diary
├── .swiftlint
├── DiaryCoreData
│   ├── Diary+CoreDataClass
│   ├── Diary+CoreDataProperties
│   ├── Diary.xcdatamodeld
│   └── CoreDataManager.swift
├── Diary
│   ├── Model
│   │   ├── DiaryProtocol.swift
│   │   ├── MyDiary.swift
│   │   └── DiaryError.swift
│   ├── JSON
│   │   ├── SampleDiary.swift
│   │   └── Decoder.swift
│   ├── Manager
│   │   ├── DateFormatterManager.swift
│   │   └── AlertManager.swift
│   ├── View
│   │   ├── DiaryTableViewCell.swift
│   │   └── extension + UITextView.swift
│   ├── ViewController
│   │   ├── DiaryListViewController.swift
│   │   └── DiaryDetailViewController.swift
│   ├── Application
│   │   ├── AppDelegate.swift
│   │   ├── LaunchScreen
│   │   └── SceneDelegate.swift
│   ├── Assets.xcassets
│   ├── Info.plist
├── DiaryTests
│   ├── DiaryTests.swift
├── CoreDataManagerTest
└─  └── CoreDataManagerTest.swift 

```
![]()


 <br/>

# 실행 화면


|<center>DiaryListVC -> DiaryDetailVC<br>상단 plus버튼클릭이동</center>|<center>DiaryListVC -> DiaryDetailVC<br>cell 클릭시 이동</center>|<center>DiaryDetailVC<br>(createMode, editMode)</center>|
| -- | -- | -- |
| <img src = "https://i.imgur.com/E1yQLsF.gif" width= 250, height= 400> |<img src = "https://i.imgur.com/pywOO9u.gif" width= 250, height= 400> |<img src = "https://i.imgur.com/HVoXHps.gif" width= 250, height= 400> |
상단 plus버튼 클릭시 DetailVC로 이동하며, 키보드는 자동으로 띄워집니다.|cell클릭시 DetailVC로 이동하며, 키보드는 화면을 클릭했을때 반응해 띄워지며, 키보드 상단 `Done` 버튼을 통해 키보드를 다시 내려줄 수 있습니다. |detailVC에서 일기를 편집후에 ListVC로 돌아와 다시 셀을 클릭해 detailVC 이동시 일기를 편집할 수 있는 화면입니다.|

<br/>

|<center>ActivityView</center>|<center>Error Alert</center>|<center>Delete</center>|
| -- | -- | -- |
| <img src = "https://i.imgur.com/24nMigy.gif" width= 250, height= 400> |<img src = "https://i.imgur.com/eCEWTQw.gif" width= 250, height= 400> |<img src = "https://i.imgur.com/0bFhA9V.gif" width= 250, height= 400> |
셀을 `swipe`했을 때 `share`버튼 또는 detailVC의 우측상단버튼을 통해 ActivityView(공유)를 띄워줄 수 있습니다.|내용이 없는 상태에서 일기를 저장 혹은 공유하려고 할때 `ErrorAlert`을 띄워주는 화면을 구현했습니다. |셀을 `swipe`해서 `delete`버튼 클릭시 셀과 코어데이터, 즉 일기가 삭제되는 기능을 구현했습니다.|


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

## 5️⃣ 첫 번째 줄, 나머지 줄 title, body로 나누기

### 🔍 문제점

처음엔 타이틀과 바디를 각각 `textField`와 `textView`로 구현을 하였으나, 명세에 "textView의 첫 번째 줄이 title, 나머지가 body가 되도록 한다는 내용"이 있어 하나의 `textView`로 묶어주고 아래와 같이 title, body로 나뉘게끔 분기처리를 하였습니다.

### 🛠️ 해결방법

```swift
  func textViewDidChange(_ textView: UITextView) {
        guard let text = diaryTextView.text else { return }
        self.titleText = text.components(separatedBy: "\n").first
        self.bodyText = text.replacingOccurrences(of: "\(String(describing: titleText)) \n", with: "")
    }
    
```
띄어쓰기를 기준으로 나눠 first 값은 title이 되고, title이 된 부분을 ""으로 바꾼 text가 body가 되도록 구현하였습니다.

# 핵심경험

<details>
<summary><big>✅ TextView, TextField Keyboard - InputAccessaryView</big></summary> 

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



<details>
<summary><big>✅ CoreData </big></summary> 
 
이번 프로젝트에서 작성한 일기를 CoreData에 저장하여 관리하였습니다. 이때 CoreData를 적용하면서 배운 핵심경험에는 크게 3가지가 있습니다.
    
- CRUD 구현
Create, Read, Update, Delete기능을 구현하고 선택적 삭제와 업데이트를 위해 `NSPredicate`를 활용하였습니다. 
    
<details>
<summary>코드확인하기</summary> 
    
```swift
import Foundation
import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() { }
    
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.newBackgroundContext()
    
    func create(diary: DiaryProtocol) {
        guard let context = self.context,
              let entity = NSEntityDescription.entity(forEntityName: "DiaryCoreData", in: context),
              let storage = NSManagedObject(entity: entity, insertInto: self.context) as? DiaryCoreData else { return }
        
        setValue(at: storage, diary: diary)
        save()
    }
    
    func readAll() -> [DiaryCoreData]? {
        guard let context = self.context else { return nil }
        
        do {
            let data = try context.fetch(DiaryCoreData.fetchRequest())
            return data
        } catch {
            return nil
        }
    }
    
    func read(key: String) -> DiaryCoreData? {
        guard let context = self.context else { return nil }
        let filter = filteredDataRequest(key: key)
        
        do {
            let data = try context.fetch(filter)
            return data.first as? DiaryCoreData
        } catch {
            return nil
        }
    }
    
    func update(key: String, diary: DiaryProtocol) {
        guard let fetchedData = read(key: key) else { return }
        
        setValue(at: fetchedData, diary: diary)
        save()
    }
    
    func deleteAll() {
        guard let context = self.context else { return }
        
        let request: NSFetchRequest<NSFetchRequestResult> = DiaryCoreData.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete(key: String) {
        guard let context = self.context else { return }
        
        let request: NSFetchRequest<NSFetchRequestResult> = DiaryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", key)
        let delete = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(delete)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func filteredDataRequest(key: String) -> NSFetchRequest<NSManagedObject> {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DiaryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", key)
        
        return fetchRequest
    }
    
    private func setValue(at target: DiaryCoreData, diary: DiaryProtocol) {
        target.setValue(diary.title, forKey: "title")
        target.setValue(diary.body, forKey: "body")
        target.setValue(diary.createdDate, forKey: "date")
    }
    
    private func save() {
        guard let context = self.context else { return }
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

```
</details>

    
- 자동저장하는 3가지 경우 설정하기
   - 사용자가 입력을 멈추는 경우 : UITextViewDelegate의 메서드인 `textViewDidEndEditing(: )`에 저장하도록 하여 TextView의 입력리 멈추는 순간마다 저장하도록 하였습니다.
    ```swift
    func textViewDidEndEditing(_ textView: UITextView) {
        saveDiary()
    ```
    
   - 앱이 백그라운드로 이동하는 경우 : UIScene.willDeactivateNotification 을 활용하여 앱이 사라지는 것을 알려 저장되도록 하였습니다.
    
    ```swift
    private func setUpBackgroundNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveDiary),
            name: UIScene.willDeactivateNotification,
            object: nil
        )
    }
    ```
    - 이전 화면을 돌아오는 경우 : 이전 화면으로 돌아갈 때 반드시 2가지 방법 중 1개를 거쳐야 하므로 자동으로 저장이 되는 것을 확인하였습니다.
    
- CoreData 저장위치확인

<img src="https://i.imgur.com/qzx6Ppu.png" width="400">



저희는 scheme에 위와 같은 argument를 추가하여 CoreData 저장위치를 확인하였습니다. Tool을 이용하여 확인해보니 Application/Support에 저장되어있어 파일 위치를 변경하지 않았습니다.

<img src="https://i.imgur.com/pvVdObz.png" width="400">
</details>
    
    
<details>
<summary><big>✅ UISwipeActionsConfiguration </big></summary> 
    
table의 row를 스와이핑 할 때 수행하는 액션의 set으로 유저가 tableView의 cell을 왼쪽에서 오른쪽 또는 오른쪽에서 왼쪽으로 쓸어넘길 때, 버튼을 띄워 액션을 취할 수 있습니다.

`UITableViewDelegate`에서 
`tableView(_:leadingSwipeActionsConfigurationForRowAt:)`
`tableView(_:trailingSwipeActionsConfigurationForRowAt:)`를 활용할 수 있고, 앞쪽에 달고싶다면 leading, 뒤쪽에 달고싶다면 trailing을 사용하면 됩니다. 저희는 뒤쪽에 달기 위해 trailing을 사용하여 구현했습니다.

**코드**

```swift
func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    guard let diary = myDiary,
          let title = diary[indexPath.row].title,
          let body = diary[indexPath.row].body else { return UISwipeActionsConfiguration() }
        
    let share = UIContextualAction(style: .normal, title: "공유") { [weak self] (_, _, success: @escaping (Bool) -> Void) in
        ...
        }
    share.backgroundColor = .systemTeal
        
    let delete = UIContextualAction(style: .normal, title: "삭제") { [weak self] (_, _, success: @escaping (Bool) -> Void) in
            
        success(true)
    }
    delete.backgroundColor = .systemPink
        
    return UISwipeActionsConfiguration(actions: [share, delete])
}
```   
</details>
    
    
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
- [CoreData Zedd](https://zeddios.tistory.com/987)
            
## 공식 문서
- [AppleDevelopment - Dateformatter](https://developer.apple.com/documentation/foundation/dateformatter)
- [AppleDevelopment - UITextview](https://developer.apple.com/documentation/uikit/uitextview)
- [AppleDevelopment - UIStackView](https://developer.apple.com/documentation/uikit/uistackview)
- [AppleDevelopment - isLayoutMarginsRelativeArrangement](https://developer.apple.com/documentation/uikit/uistackview/1616220-islayoutmarginsrelativearrangeme)
- [AppleDevelopment - Locale](https://developer.apple.com/documentation/foundation/locale)
- [AppleDevelopment - contentInset](https://developer.apple.com/documentation/uikit/uiscrollview/1619406-contentinset)
- [AppleDevelopment - UISwipeActionsConfiguration](https://developer.apple.com/documentation/uikit/uiswipeactionsconfiguration)
- [AppleDevelopment - UITextViewDelegate](https://developer.apple.com/documentation/uikit/uitextviewdelegate)
- [AppleDevelopment - CoreData](https://developer.apple.com/documentation/coredata)
- [AppleDevelopmet - willdeactivatenotification](https://developer.apple.com/documentation/uikit/uiscene/3197924-willdeactivatenotification)
- [AppleDevelopmet - ActivityViewController]
(https://developer.apple.com/documentation/uikit/uiactivityviewcontroller)
