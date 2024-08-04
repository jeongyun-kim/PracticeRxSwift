//
//  ViewController.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 7/30/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class BasicViewController: BaseViewController {
    private let disposeBag = DisposeBag()
    private let button = UIButton()
    private let resultLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        just()
//        of()
//        from()
//        take()
//        replaySubject()
//        asyncSubject()
      //  debounce()
        throttle()
    }
    
    override func setupHierarchy() {
        view.addSubview(button)
        view.addSubview(resultLabel)
    }
    
    override func setupConstraints() {
        resultLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view.safeAreaLayoutGuide).offset(-48)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(56)
        }
        
        button.snp.makeConstraints { make in
            make.top.equalTo(resultLabel.snp.bottom).offset(12)
            make.centerX.equalTo(resultLabel.snp.centerX)
            make.height.equalTo(44)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(48)
        }
    }
    
    override func setupUI() {
        super.setupUI()
        resultLabel.backgroundColor = .systemGray6
        button.backgroundColor = .systemYellow
        button.setTitle("눌러보세용", for: .normal)
    }
    
    override func bind() {
        // Observable : User Interaction, 사용자의 행위를 통해 이벤트를 전달하는 역할
        // - Operator를 통해 보내주는 이벤트(데이터)를 가공할 수 있음
        // ex) 버튼 클릭, 셀 클릭, 텍스트 입력 등
        // Observer : 이벤트가 전달(= 방출)되면 해당 이벤트를 처리하는 역할
        // ex) 버튼 눌렀을 때의 화면전환, 닉네임 유효성 처리 등
        // => Observable은 Subscriber를 통해 Observer에게 관찰당함
        //  => 그래서 무언가 값이 바뀔 때마다 Observer의 처리구문이 실행
        // ex) 유튜브
        // bind : UI와 관련된 구문은 항상 메인스레드에서 실행되어야하며 에러가 발생할 확률이 0%
        // - 이는 곧 Error, Complete에 대한 이벤트 처리가 불필요하다는 의미
        // - 그리고 Rx의 subscribe의 경우 스레드를 가리지않기 때문에 메인스레드에서 처리하는건 꼭 GCD나 .observe(on:)을 통해 명시해줘야했음
        // 이러한 두 가지 사항을 한 번에 개선해낸게 bind!
        // 불필요한 이벤트를 애초에 받지않으면서 개발자가 명시해주지않아도 알아서 메인스레드에서 처리해주도록 만들어짐
        
        // (1)
        // - 기본적인 형태
//        button.rx.tap
//            .subscribe { _ in
//                self.resultLabel.text = "버튼을 클릭했어요!!!"
//            } onError: { error in
//                print(error)
//            } onCompleted: {
//                print("completed!")
//            } onDisposed: {
//                print("disposed!")
//            }.disposed(by: disposeBag)
//
//        // (2)
//        // - Label에 텍스트 세팅은 UI적인 부분이라 Error, Complete(X)
//        // - Error, Complete 이벤트 자체를 받지않는 형태
//        button.rx.tap
//            .subscribe { _ in
//                self.resultLabel.text = "버튼을 클릭했어요!!!"
//            } onDisposed: {
//                print("disposed!")
//            }.disposed(by: disposeBag)
//
//        // (3)
//        // - 메모리 누수 방지 형태
//        button.rx.tap
//            .subscribe { [weak self] _ in
//                guard let self else { return }
//                self.resultLabel.text = "버튼을 클릭했어요!!!"
//            } onDisposed: {
//                print("disposed!")
//            }.disposed(by: disposeBag)
//
//        // (4)
//        // - [weak self] 대신 withUnretained 사용 형태
//        button.rx.tap
//            .withUnretained(self)
//            .subscribe { _ in
//                self.resultLabel.text = "버튼을 클릭했어요!!!"
//            } onDisposed: {
//                print("disposed!")
//            }.disposed(by: disposeBag)
//        
//        // (5)
//        // - subscribe 할 때, with를 통해 self를 옵셔널 바인딩해서 가져옴
//        // - self를 풀어온 owner를 사용해줘야 진짜
//        button.rx.tap
//            .subscribe(with: self) { owner, _ in
//                owner.resultLabel.text = "버튼을 클릭했어요!!!"
//            } onDisposed: { owner in
//                print("disposed!")
//            }.disposed(by: disposeBag)
//        
//        // (6)
//        // - subscribe : 스레드 상관없이 동작해서 백그라운드에서도 동작 가능
//        // - 그러니까 UI와 관련된건 메인에서 처리해달라고 DispatchQueue.main.async 처리해줘야함
//        button.rx.tap
//            .subscribe(with: self, onNext: { owner, _ in
//                DispatchQueue.main.async {
//                    owner.resultLabel.text = "버튼을 클릭했어요!!!"
//                }
//            }, onDisposed: { owner in
//                print("disposed!")
//            }).disposed(by: disposeBag)
//        
//        // (7)
//        // - Rx가 지원해주는 GCD를 사용하자!
//        button.rx.tap
//            .observe(on: MainScheduler.instance)
//            .subscribe(with: self) { owner, _ in
//                owner.resultLabel.text = "버튼을 클릭했어요!!!"
//            } onDisposed: { owner in
//                print("disposed!")
//            }.disposed(by: disposeBag)
//
//        // (8)
//        // - 근데 그럼 또 코드를 한 줄 더 써야하니까 아예 subscribe가 메인스레드에서 동작하게 하자
//        // - 그리고 UI관련 코드는 Error, Complete가 발생할 일이 없으니까 둘을 받지않는 subscribe문을 쓰자
//        // => bind의 등장!
//        button.rx.tap
//            .bind(with: self) { owner, _ in
//                owner.resultLabel.text = "버튼을 클릭했어요!!!"
//            }.disposed(by: disposeBag)
    }
    
    private func just() {
        // 파라미터로 하나의 값만 받아 Observable을 반환
        // = 하나의 값만 방출(emit)
        let items = [3.3, 4.0, 5.0, 2.0, 3.6, 4.8]
        
        Observable.just(items)
            .subscribe { value in
                print("just : \(value)")
            } onError: { error in
                print("just error : \(error)")
            } onCompleted: {
                print("complted!")
            } onDisposed: {
                print("disposed!")
            }.disposed(by: disposeBag)
    }
    
    private func of() {
        // element Parameters가 가변 파라미터로 선언되어있음
        // => 여러 가지의 값을 동시에 전달 가능!
        // = 2개 이상의 값 방출(emit)
        let itemsA = [1, 2, 3, 4, 5]
        let itemsB = [6, 7, 8]
        
        Observable.of(itemsA, itemsB)
            .subscribe { value in
                print("of : \(value)")
            } onError: { error in
                print("of error : \(error)")
            } onCompleted: {
                print("of completed!")
            } onDisposed: {
                print("of disposed")
            }.disposed(by: disposeBag)
    }
    
    private func from() {
        // 배열 내 각각의 데이터를 방출(emit)하고 싶다면 from 사용
        // array Parameters로 배열을 받고, 배열의 각 element를 Observable로 반환
        let itemsA = [1, 2, 3, 4, 5]
        
        Observable.from(itemsA)
            .subscribe { value in
                print("from : \(value)")
            } onError: { error in
                print("from error : \(error)")
            } onCompleted: {
                print("completed!")
            } onDisposed: {
                print("disposed")
            }.disposed(by: disposeBag)
    }
    
    private func take() {
        // 방출된 아이템 중 처음 n개의 아이템을 내보냄
        Observable.repeatElement("Yunie") // Yunie 무한반복
            .take(1) // 1개의 아이템만 내보내고 멈추기
            .subscribe { value in
                print("repeat : \(value)")
            } onError: { error in
                print("reapeat error : \(error)")
            } onCompleted: {
                print("completed!")
            } onDisposed: {
                print("disposed")
            }.disposed(by: disposeBag)
    }
    
    private func replaySubject() {
        // 이벤트가 얼마나 전달되든 subscribe 시에는 최근에 들어온 버퍼 사이즈만큼의 이벤트를 처리
        // 제네릭 통해서 가져올 데이터 정의
        let replay = ReplaySubject<Int>.create(bufferSize: 3)
        
        // 이벤트 전달
        replay.onNext(1)
        replay.onNext(2)
        replay.onNext(3)
        replay.onNext(4)
        
        replay
            .subscribe { value in
                print("replay \(value)")
            } onError: { error in
                print("replay \(error)")
            } onCompleted: {
                print("replay completed!")
            } onDisposed: {
                print("replay disposed!")
            }.disposed(by: disposeBag)
        /*
         replay 2
         replay 3
         replay 4
         */
        
        replay.onNext(5)
        replay.onNext(6)
        replay.onNext(7)
        replay.onNext(8)
        replay.onNext(9)
        /*
         replay 2
         replay 3
         replay 4
         replay 5
         replay 6
         replay 7
         replay 8
         replay 9
         */
        
        print("=====")
        
        replay
            .subscribe { value in
                print("replay \(value)")
            } onError: { error in
                print("replay \(error)")
            } onCompleted: {
                print("replay completed!")
            } onDisposed: {
                print("replay disposed!")
            }.disposed(by: disposeBag)
        /*
         replay 7
         replay 8
         replay 9
         */
    }
    
    private func asyncSubject() {
        // complete를 받아야만 이벤트 전달
        // 그 때엔 가장 최근 시점에 전달된 이벤트 하나를 함께 전달
        // 전달할 이벤트의 타입을 제네릭으로 정의
        let asyncSubject = AsyncSubject<Int>()
        
        asyncSubject.onNext(1)
        asyncSubject.onNext(2)
        asyncSubject.onNext(3)
        
        asyncSubject
            .subscribe { value in
                print("async \(value)")
            } onError: { error in
                print("async \(error)")
            } onCompleted: {
                print("async complted!")
            } onDisposed: {
                print("async disposed!")
            }.disposed(by: disposeBag)

        // Complete 이벤트를 받지않아서 아무런 print문도 실행되지 않음
        asyncSubject.onNext(30)
        asyncSubject.onCompleted()
        // Complete 이후에 최근 이벤트와 함께 전달 => 30이 출력될 것
        /*
         async 30
         async complted!
         async disposed!
         */
    
        // 이미 Complete 처리돼서 더는 이벤트 전달 X
        asyncSubject.onNext(7)
        asyncSubject.onCompleted()
    }
    
    private func debounce() {
        // 버튼탭 -> 이벤트 바로 방출되지 않고 일정 시간 후 처리
        // 그래서 막 눌러도 조금 기다린 후에 count가 1 올라감을 확인할 수 있음
        // = 여러 번 발생하는 이벤트에서 가장 마지막 이벤트만을 실행
        var count = 0
        
        button.rx.tap
            .debounce(.seconds(3), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                count += 1
                print(count)
            }.disposed(by: disposeBag)
    }
    
    private func throttle() {
        // 버튼탭 -> 바로 이벤트 방출
        // 만약 3초 이내에 버튼을 10번 누른다면
        // 맨처음 이벤트가 바로 방출돼서 count 1이 찍힘
        // 그리고 3초가 지났을 때 누적되어있던 이벤트 중 마지막 이벤트가 방출됨
        // = 여러 번 발생하는 이벤트를 일정 시간동안 한 번만 실행
        //  => 마지막 새로고침 시간이 1분이 지나지않았다면 실행X 같은 경우에 사용
        var count = 0
        
        // 만약 오직 한 번만 반영되게 하기위해서는 latest = false 처리
        // 기본값은 true
        // -> 3초에 한 번씩만 이벤트가 처리됨 
        button.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                count += 1
                print(count)
            }.disposed(by: disposeBag)
    }
}

