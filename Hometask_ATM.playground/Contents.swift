import Foundation


// ---------------------------------------
// MARK: - Домашнее задание
// ---------------------------------------

/*
 Реализуйте программу `Банкомат`, которая поддерживает финансовые операции выдачи необходимой суммы клиенту

 Программа должна поддерживать:
 1. Выдачу суммы банкнотами различного номинала в соответствующем валютном эквиваленте (евро, доллары и белорусские рубли)
 2. Для данного решения рекомендую использовать Generic Types, Enums, Functions / Closures.
 3. Реализуйте корректную обработку всех возможных ошибок, как минимум 5ти:
    - Закончились деньги в АТМ
    - Закончились деньги на карте клиента
    - Нет нужной валюты
    - и тд */


// MARK: - Solution

enum AtmError: Error {
    case notEnoughMoneyOnTheCard
    case notEnoughMoneyInAtm
    case noCurrency
    case incorrectPin
    case incorrectTypeCard
    case incorrectBanknotes
    case notEnoughBanknotes
    case sumNotEqualsBanknotes
}

enum Currency {
    case usd
    case euro
    case byn
}

class Person {
    var personsMoney: [Currency: Float] = [.byn: 1543.67]
    private var _pin: String = "0000"
    var pin: String {
        get {
            return self._pin
        }
        set {
            self._pin = newValue
        }
    }
    
    init(personsMoney: [Currency: Float], pin: String) {
        self.personsMoney = personsMoney
        self.pin = pin
    }
}

class ATM {
    private(set) var exchangeRates: [Currency: Float] = [.usd: 2.68, .euro: 3.45, .byn: 1]
    private(set) var usdBanknotesOnAtm: [Int: Int] = [5: 50, 10: 50, 20: 50, 50: 150, 100: 50]
    private(set) var euroBanknotesOnAtm: [Int: Int] = [5: 50, 10: 50, 20: 50, 50: 150, 100: 50, 200: 1, 500: 0]
    private(set) var bynBanknotesOnAtm: [Int: Int] = [5: 50, 10: 50, 20: 50, 50: 200, 100: 200, 200: 1, 500: 0]
    
    // Считаем сумму денег в банкомате
    private func sumMoney(arrayBanknotes: [Int: Int]) -> Int {
        var item: Int = 0
        arrayBanknotes.forEach() {
            let a = $0.key * $0.value
            item += a
        }
        return item
    }
    
    func getCash(person: Person, currency: Currency, sumToGetCash: Int, banknotes: [Int: Int], pin: String) throws  {
        
        // Проверка правильно ли введен пин
        guard pin == person.pin else { throw AtmError.incorrectPin }
        let sumOfMoneyOnAtm: [Currency: Int] = [.usd: sumMoney(arrayBanknotes: usdBanknotesOnAtm),
                                                .euro: sumMoney(arrayBanknotes: euroBanknotesOnAtm),
                                                .byn: sumMoney(arrayBanknotes: bynBanknotesOnAtm)]
        
        // Проверка валюты
        guard sumOfMoneyOnAtm.contains(where: { $0.key == currency } ) else { throw AtmError.noCurrency }
        // Проверка достаточно ли средств в банкомате
        // Не уверена что нужна проверка на nil, т.к. мы проверили наличие валюты выше
        if let sum: Int = sumOfMoneyOnAtm[currency] {
            guard sum >= sumToGetCash else { throw AtmError.notEnoughMoneyInAtm }
        } else {
            throw AtmError.noCurrency
        }
        
        // Проверка валюты и достаточно ли средств на счете клиента
        // Проверка на nil денег клиента. Если у клиента карта не в бел. руб, то ошибка - не поддерживаемый тип карты.
        if let count: Float = person.personsMoney[.byn] {
            // Проверка на nil курса выбранной валюты
            if let exchange: Float = self.exchangeRates[currency] {
                guard count / exchange >= Float(sumToGetCash) else { throw AtmError.notEnoughMoneyOnTheCard }
            }
        } else { throw AtmError.incorrectTypeCard }
        
        // Проверка равенства сумм запрошенных банкнот и запрошенной суммы
        guard sumMoney(arrayBanknotes: banknotes) == sumToGetCash else { throw AtmError.sumNotEqualsBanknotes }
        // Проверка наличия запрошенных банкнот
        
        switch currency {
        case .byn:
            for (key, value) in banknotes {
                if let byn: Int = bynBanknotesOnAtm[key] {
                    guard byn >= value else { throw AtmError.notEnoughBanknotes }
                    bynBanknotesOnAtm.updateValue(byn - value, forKey: key)
                }
                else { throw AtmError.incorrectBanknotes }
            }
        case .euro:
            for (key, value) in banknotes {
                if let euro: Int = euroBanknotesOnAtm[key] {
                    guard euro >= value else { throw AtmError.notEnoughBanknotes }
                    euroBanknotesOnAtm.updateValue(euro - value, forKey: key)
                } else { throw AtmError.incorrectBanknotes }
            }
        case .usd:
            for (key, value) in banknotes {
                if let usd: Int = usdBanknotesOnAtm[key] {
                    guard usd >= value else { throw AtmError.notEnoughBanknotes }
                    usdBanknotesOnAtm.updateValue(usd - value, forKey: key)
                } else { throw AtmError.incorrectBanknotes }
            }
        }
        
        if let exchange: Float = exchangeRates[currency] {
            if let item: Float = person.personsMoney[.byn] {
                person.personsMoney.updateValue(item - Float(sumToGetCash) * exchange, forKey: .byn)
        }
        }
    
    print("Get your money")
    }
}

extension AtmError:  LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notEnoughMoneyOnTheCard:
            return NSLocalizedString("Not enough money on the card",
                                     comment: "")
        case .notEnoughMoneyInAtm:
            return NSLocalizedString("Not enough money on the ATM",
                                     comment: "")
        case .noCurrency:
            return NSLocalizedString("No selected currency",
                                     comment: "")
        case .incorrectPin:
            return NSLocalizedString("Pin is wrong",
                                     comment: "")
        case .incorrectTypeCard:
            return NSLocalizedString("Card type isn't supported",
                                     comment: "")
        case .incorrectBanknotes:
            return NSLocalizedString("No selected banknotes",
                                     comment: "")
        case .notEnoughBanknotes:
            return NSLocalizedString("Not enough selected banknotes on the ATM",
                                     comment: "")
        case .sumNotEqualsBanknotes:
            return NSLocalizedString("Total amount isn't equal amount of selected banknotes",
                                     comment: "")
        }
    }
}

let somePerson: Person = Person(personsMoney: [.byn: 1587.76], pin: "4325")
let someAtm: ATM = ATM()
do {
    try someAtm.getCash(person: somePerson, currency: .euro, sumToGetCash: 200, banknotes: [50: 2, 100: 1], pin: "4325")
} catch {
    print(error)
}

someAtm.usdBanknotesOnAtm
somePerson.personsMoney
