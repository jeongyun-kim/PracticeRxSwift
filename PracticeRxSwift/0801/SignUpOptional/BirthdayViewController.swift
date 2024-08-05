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
    private let vm = BirthdayViewModel()
    
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
        // input 생성 후 보내서
        let input = BirthdayViewModel.Input(nextButtonTapped: nextButton.rx.tap, birthday: birthDayPicker.rx.date)
        // output 받아오기
        let output = vm.transform(input)
        
        // 다음 버튼 눌렀을 때 Alert
        output.nextButtonTapped
            .bind(with: self) { owner, _ in
                owner.showAlert { _ in
                    owner.setNewScene(SearchViewController())
                }
            }.disposed(by: disposeBag)
        
        output.year
            .map { "\($0)년" }
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.month
            .map { "\($0)월" }
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.day
            .map { "\($0)일" }
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.isValidBirth
            .bind(with: self) { owner, isValid in
                let textColor: UIColor = isValid ? .systemGreen : .systemRed
                let info = isValid ? "가입 가능한 나이입니다!" : "만 17세 이상만 가입 가능합니다"
                owner.infoLabel.text = info
                owner.infoLabel.textColor = textColor
                
                let bgColor:UIColor = isValid ? .systemGreen : .lightGray
                owner.nextButton.backgroundColor = bgColor
                owner.nextButton.isEnabled = isValid
            }.disposed(by: disposeBag)
        
    }
}
