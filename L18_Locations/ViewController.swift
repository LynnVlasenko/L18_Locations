//
//  ViewController.swift
//  L18_Locations
//
//  Created by Алина Власенко on 07.03.2023.
//

import UIKit
import CoreLocation //імпортуємо CoreLocation для формування локації
import MapKit //імрортуємо MapKit для відобрадення локації на мапі

final class ViewController: UIViewController {

    @IBOutlet private weak var locationLabel: UILabel! //лейбла, яка покаже адресу поточного місцезнаходження
    @IBOutlet private weak var mapView: MKMapView! //карта

    let manager = CLLocationManager()

    // MARK: - Lifecycle

    //Lifecycle events
    override func viewDidLoad() {
        super.viewDidLoad()

        manager.delegate = self //вказуємо, що наш ViewController буде обробляти(хендлити) івенти делегата
        //У самого manager через крапку можна викликати різні методи:
        //manager.authorizationStatus = authorizationStatus як метод типу наразі Deprecated. Працює authorizationStatus як Instance Property
        //manager.allowsBackgroundLocationUpdates = true//чи дозволяти BackgroundLocationUpdates
        //ми викличемо desiredAccuracy
        manager.desiredAccuracy = kCLLocationAccuracyBest //тут вказуємо обробку нашої локації, наскільки вона буде точною. Так як у нас демо проект - і він сам по собі займає не багато ресурсів телефона, то оберемо найкращу обробку - щоб найточніше визначити локацію. Якщо через command + touch подивитися definitions - то побачимо ще декілька властивостей CLLocationAccuracy для визначення точності локації = kCLLocationAccuracyBestForNavigation, kCLLocationAccuracyBest, kCLLocationAccuracyNearestTenMeters, kCLLocationAccuracyHundredMeters, kCLLocationAccuracyKilometer, kCLLocationAccuracyThreeKilometers
    }

    //Action вставляємо після Лайфсайкл івентів
    //По натисканню кнопки - отримуємо локацію
    @IBAction private func getLocationDidTouch(_ sender: Any) {
        //Нам потрібно перевірити чи в нас вже є статус, що дозволяє нам отримати локацію
        switch manager.authorizationStatus {
            //Опрацьовуємо успішний кейс - коли юзер надав доступ до локації.
        case .authorizedAlways, .authorizedWhenInUse: //кейс коли юзер вказав, що він згоден надати програмі доступ до локації назавжди або коли використовує застосунок
            manager.startUpdatingLocation() //коли дозволили - менеджер стартує оновлення локації
            //Опрацьовуємо початковий стан програми, коли нічого ще не обрано щодо доступу до локації юзера.
        case .notDetermined:
            manager.requestWhenInUseAuthorization()//запускається метод, що викликає поп-ап в якому юзер обере дозволяти доступ до локації чи ні.
            //Опрацьовуємо випадок, коли немає доступу до локації
        case .denied, .restricted: //denied - коли Додаток не має прав на використання служб визначення місцезнаходження. або restricted - Користувач заборонив використовувати служби локації для програми або їх глобально вимкнено в налаштуваннях.
            print("denied") //просто прінтуємо, що відмовлено - Зробити тут не прінт, а алерт з виходом на зміну налаштувань, щоб дати доступ до локації. Тобто буде 2 кнопки Open Settings та Cansel
        @unknown default: // xcode сам пізказує як попередження, що маємо додати цей @unknown default - він передбачає те, що можуть з'явитися нові кейси, які насправді в даній версії iOS, яка використовується, ще не відомі (тобто, якщо в нас з'явиться якийсь кейс для CLAuthorizationStatus, що ще невідомий певній версії iOS)& То ж для компотібіліті потрібно, щоб опрацювати усі можливі кейси.
            break
        } //Цей екшн не буде працювати поки ми не додамо в Info.plist інформаційну стрінгу з описом для чого нам потрібно, щоб юзер дозволив доступ до локації.
        //Тож в Info.plist  маємо додати новий ключ - Privacy - Location When In Use Usage Description - і в полі String - напишимо нашу причину. Ми написали "Location is needed in order to provide detailed description on the screen" Але маємо пам'ятати, що маємо вказати таку причину що робить якусь корисну роботу у застосунку.
    }

    // MARK: - Private

    //функція для відображення(оновлення) локації на мапі, назвемо її updateLocationOnMap з параметрами location і title(щоб потім створити анотацію)
    private func updateLocationOnMap(location: CLLocation, title: String?) {
        //для того, щоб створити точку на карті нам потрібно спочатку створити об'єкт MapKitPointAnnotation
        let point = MKPointAnnotation()
        point.title = title //передамо об'єкту point тайтл
        point.coordinate = location.coordinate //передаємо координати для point (наша location вже має координати їх і передаємо). Тобто просто змапимо одні координати на інші.

        //переходимо до mapView, і перед тим я к поставити нову позначку на мапі, нам потрібно видалити усі існуючі
        mapView.removeAnnotations(mapView.annotations)//видаляємо старі анотації
        mapView.addAnnotation(point) //встановлюємо наш поінт на мапу (додаємо нову анотацію)

        //тепер нам потрібно, крім анотації, зробити якийсь на мапі регіон і якось масштабувати потрібно нашу карту. Створюємо це за допомогою MKCoordinateRegion - те що ми будемо бачити на карті з відповідним масштабом. Де в center - пердаємо локацію(координати локації ),
        let viewRegion = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 100, //параметри масштабування
                                            longitudinalMeters: 100) //параметри масштабування
        //і робимо сет, що ми сетимо саме цей viewRegion і з анімацією.
        mapView.setRegion(viewRegion, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate { //делегат займається тим, що відображає подробиці опису локації. Тобто вказує місто, вулицю, поштовий індекс і т.д.

    //для того, щоб відбувався якийсь апдейт - є такий метод як locationManagerDidChangeAuthorization. Це новий метод з iOS14. (До iOS14 був інший метод, що мав 2 параметри(для себе, якщо доведеться працювати зі старим проектом - щоб розрізнити.))
    //Робимо метод в якому описуємо ще раз зміну авторизації після вибору підтвердження доступу до локації. Бо виходить так, що функція до кнопки викликає наш поп-ап з запитом на доступ, але коли ми натиснули, то воно вже не повертається до функції, щоб опрацювати дію, коли ми щось обрали у поп-апі.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: //опрацьовуємо лише вдалий випадок, коли доступ до локації дозволений. І тоді locationManagerDidChangeAuthorization нам оновить локацію
            manager.startUpdatingLocation()
        default: break
        }
    }

    //Другий метод, який використаємо - це didUpdateLocation через функцію locationManager - він надає нам наші локації. І на виході у нас буде масив локацій. Але чому не показує реальну локацію?
    
    //При розробці проекту Володимиром була проблема з цією функцією - вона не надавала нам локації. Є пара способів як отримати локацію статичну - обрану: 1. це обрати в XCode внизу - натиснути на Simulate Location - і обрати якусь локацію. 2. Це налаштування самого симулятора - Натиснути на симулятор - зверху з'явиться поле налаштувань - обрати Features -> Lacation - і там є певні цікаві параментри(в нас було Custom Location - через те, що ми обрали в XCode локацію в Simulate Location). Наприклад можна обрати Freeway Drive - і він симулює рух телфону - типу коли ми їдемо на авто, наприклад і змінюється наша локація(за рахунок параметру kCLLocationAccuracyBest - локація змінюється дуже часто (+/- 5 метрів) - бо ми обрали дуже точну локацію. Як би була kCLLocationAccuracyNearestTenMeters - оновнювало б кодні 10 метрів, або kCLLocationAccuracyKilometer - кожен кілометр). Так відбувається трекінг локації - використовують для різних застосунків типу навігатора або для бігу і т.ін.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //CLLocation показує нам дані про локацію такі як географічні координати з певною вказаною точністю, та timestamp інформацію отримання цих координат. - виглядає цей масив так: [<+37.33519572,-122.03254980> +/- 5.00m (speed 1.94 mps / course 179.65) @ 7/19/21, 4:47:13 PM Eastern European Summer Time]
        //нам потрібно дізнатися адресу де ми знаходимося - напишемо певну логіку і для цього використаємо наш Geocoder.
        if let location = locations.first { //беремо перший елемент масиву - він в нас по факту завжди один у масиві - оце все, як 1 елемент -  <+37.33519572,-122.03254980> +/- 5.00m (speed 1.94 mps / course 179.65) @ 7/19/21, 4:47:13 PM Eastern European Summer Time
            //Далі викличимо CLGeocoder() - ми створюємо цей об'єкт і викликаємо на ньому reverseGeocodeLocation  (CLGeocoder().reverseGeocodeLocation(<#T##location: CLLocation##CLLocation#>, completionHandler: <#T##CLGeocodeCompletionHandler##CLGeocodeCompletionHandler##([CLPlacemark]?, Error?) -> Void#>)) - передаємо location object = location(який ми створили вище) і completionHandler - в нього є 2 параметри [CLPlacemark]?, Error? in  - ми для нього прописуємо placemarks, errors - і для початку усунемо усі errors, якщо вони будуть  - прописавши if let error = errors { print(error.localizedDescription) }, а потім пропишемо наші плейсмарки - це назва вулиці, індекс, місто і т.д.
            //[weak self] - це weak посилає на self в середині кложури, тому нам потрібно якусь ссилку зробити слабкою - будемо далі з цим знайомитись в іншому уроці.
            CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, errors in
                if let error = errors { //надрукуємо, якщо в нас виникнуть помилки при reverseGeocodeLocation
                    print(error.localizedDescription)
                }

                if let placemark = placemarks?.first {
                    //Можна прописати прямо стрінгу з екрануваннями параметрів і джоінгу стрінгів, але виглядає це не дуже красиво.
                    //Тож можна зробити так через масив(об'єднати усі наші поля в масив) - зроюимо масив стрінгів з джоін сеператором - комою.
                    self?.locationLabel.text = //вказуємо нашу лейблу, куди буде передаватися текст
                        [
                            placemark.name, //назва вулиці
                            placemark.thoroughfare, //проїзд
                            placemark.subThoroughfare, //підпроїзд
                            placemark.country, //країна
                            placemark.postalCode, //поштовий індекс
                            placemark.administrativeArea, //район
                            placemark.subAdministrativeArea //якийсь підрайон
                        ]
                        .compactMap { $0 } //обробляємо масив компакт мепом - для того, щоб виключити ніли - тобто якщо якихось даних не буде про місце знаходження - типу немаєж підрайонів або проїзів, а тільки вулиця - то вони не будуть відображатися, бо компакт меп працює таким чином, що видаляє порожні дані з масиву. - перебере увесь масив і видалить nil.
                        .joined(separator: ", ") //для того щоб в кінці повернути стрінгу - використаємо метод joined з сепаратором - кома.

                    if let name = placemark.name, let city = placemark.subAdministrativeArea { //анврапаємо опціонали через binding (if let)
                        let title = name + city //створюємо тайтл
                        self?.updateLocationOnMap(location: location, title: title) //відображаємо нашу локацію на мапі одразу після того як отримали локацію - викликаємо нашу иункцію, створенудля цієї дії з локацією і тайтлом. З яким тайтлом - коли ми вже змогли декодувати і взяти першу локацію let placemark = placemarks?.first - ми можемо зробити тайтлом placemark.name
                    }
                }
            }
        }
    }

    //ще нам потрібен метод який може зафейлити наші локації - це didFailWithError, також через locationManager.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)//localizedDescription - покаже в консолі в чому проблема - чому помилка. Тобто роздрукуємо наш error.
    }
}

//! за допомогою команди Control+i - можна вирівняти рядки коду
