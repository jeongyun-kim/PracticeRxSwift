//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BirthdayViewController: BaseViewController {
    enum DateCase {
        case year
        case month
        case day
    }
    
    private let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    private let infoLabel = UILabel()
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    private let yearLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    private let monthLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    private let dayLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    private let nextButton = PointButton(title: "가입하기")

    private let disposeBag = DisposeBag()
    private lazy var year = BehaviorRelay(value: getDateComponent(dateCase: .year))
    private lazy var month = BehaviorRelay(value: getDateComponent(dateCase: .month))
    private lazy var day = BehaviorRelay(value: getDateComponent(dateCase: .day))
    private let info = BehaviorRelay(value: false)
    private let bgColor = BehaviorRelay(value: false)
    
    override func setupHierarchy() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    override func setupUI() {
        super.setupUI()
    }

    override func bind() {
        // 다음 버튼 눌렀을 때 Alert
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.showAlert { _ in
                    owner.setNewScene(SearchViewController())
                }
            }.disposed(by: disposeBag)
        
        // 날짜 변경할 때마다 변경
        birthDayPicker.rx.date
            .bind(with: self) { owner, date in
                let year = owner.getDateComponent(date, dateCase: .year)
                let month = owner.getDateComponent(date, dateCase: .month)
                let day = owner.getDateComponent(date, dateCase: .day)
                owner.year.accept(year)
                owner.month.accept(month)
                owner.day.accept(day)
              
                let result = owner.isPassedBirth(date)
                owner.bgColor.accept(result)
                owner.info.accept(result)
            }.disposed(by: disposeBag)
        
        year
            .map { "\($0)년" }
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        month
            .map { "\($0)월" }
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
      
        day
            .map { "\($0)일" }
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        info
            .bind(with: self) { owner, value in
                let textColor: UIColor = value ? .systemGreen : .systemRed
                let info = value ? "가입 가능합니다!" : "만 17세 이상만 가입 가능합니다"
                owner.infoLabel.text = info
                owner.infoLabel.textColor = textColor
            }.disposed(by: disposeBag)
        
        bgColor
            .bind(with: self, onNext: { owner, value in
                let bgColor:UIColor = value ? .systemGreen : .lightGray
                owner.nextButton.backgroundColor = bgColor
                owner.nextButton.isEnabled = value
            }).disposed(by: disposeBag)
    }
    
    private func getDateComponent(_ date: Date = Date(), dateCase: DateCase) -> Int {
        let component = Calendar.current.dateComponents([.day, .month, .year], from: date)
        switch dateCase {
        case .year:
            return component.year ?? 1
        case .month:
            return component.month ?? 1
        case .day:
            return component.day ?? 1
        }
    }
    
    // 생일이 지났으면 true / 아니면 false
    private func isPassedBirth(_ fromDate: Date) -> Bool {
        let birthYear = getDateComponent(fromDate, dateCase: .year)
        let birthMonth = getDateComponent(fromDate, dateCase: .month)
        let birthDay = getDateComponent(fromDate, dateCase: .day)
        
        let todayYear = getDateComponent(dateCase: .year)
        let todayMonth = getDateComponent(dateCase: .month)
        let todayDay = getDateComponent(dateCase: .day)
        
        // 올해의 년과 출생년이 17년 차이가 나는지 확인
        guard todayYear - birthYear >= 17 else { return false }
        // 생월이 지났는지 확인
        // 지나지않았다면 양수가 나오고 지났다면 음수 또는 이번달이라면 0
        guard birthMonth - todayMonth <= 0 else { return false }
        // 생일이 지났는지 확인
        guard birthDay - todayDay <= 0 else { return false }
        // 모든 조건 충족시
        return true
    }
}
