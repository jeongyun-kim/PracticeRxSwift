//
//  BirthdayViewModel.swift
//  PracticeRxSwift
//
//  Created by 김정윤 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BirthdayViewModel {
    enum DateCase {
        case year
        case month
        case day
    }
    
    private let disposeBag = DisposeBag()

    struct Input {
        let nextButtonTapped: ControlEvent<Void>
        let birthday: ControlProperty<Date>
    }
    
    struct Output {
        let nextButtonTapped: ControlEvent<Void>
        let year: BehaviorRelay<Int> //
        let month: BehaviorRelay<Int>
        let day: BehaviorRelay<Int>
        let isValidBirth: BehaviorRelay<Bool>
    }
    
    func transform(_ input: Input) -> Output {
        // 기본 날짜(오늘) 세팅
        let yearRelay = BehaviorRelay(value: getDateComponent(dateCase: .year))
        let monthRelay = BehaviorRelay(value: getDateComponent(dateCase: .month))
        let dayRelay = BehaviorRelay(value: getDateComponent(dateCase: .day))
        let isValidBirth = BehaviorRelay(value: false)
        
        // DatePicker에서 날짜 받아올 때마다
        input.birthday
            .bind(with: self) { owner, date in
                let year = owner.getDateComponent(date, dateCase: .year)
                let month = owner.getDateComponent(date, dateCase: .month)
                let day = owner.getDateComponent(date, dateCase: .day)
                yearRelay.accept(year)
                monthRelay.accept(month)
                dayRelay.accept(day)
                isValidBirth.accept(owner.isPassedBirth(date))
            }.disposed(by: disposeBag)

        // output 구성 후 반환
        let output = Output(nextButtonTapped: input.nextButtonTapped, year: yearRelay, month: monthRelay, day: dayRelay, isValidBirth: isValidBirth)
        return output
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
        
        // 현재의 날짜에서 생년월일차이 구하기
        var yearDiff = todayYear - birthYear
        let monthDiff = todayMonth - birthMonth
        let dayDiff = todayDay - birthDay
        // 만약 월/일 차이가 음수로 떨어진다면 두 년의 차이에서 -1 해주기
        if monthDiff < 0 || dayDiff < 0 {
            yearDiff -= 1
        }
        // 두 년도의 차이가 17 이상인지
        return yearDiff >= 17
    }
}
