# **Social**

## Зачем это нужно?

В каждом новом проекте постоянно приходится снова и снова подключать необходимые SDK, 
копировать из старого проекта/писать тот же код для авторизации или выхода из соц. сети или выполнение необходимых действий. И как правило вся логика не унифицирована и в разных проектах отличается друг от друга. 
Эта библиотека была реализована для решения этих проблем, где нам не приходится думать, как работает конкретная соц. сеть - мы просто оперируем всеми, как одной. 

## Как это работает?

Для создания соц. сети мы должны реализовать протокол ```SocialNetwork```. ВНИМАНИЕ! Все соц. сети должны быть реализованы как [Singleton](https://en.wikipedia.org/wiki/Singleton_pattern). 

 - Методом ```static var name: String``` соц. сеть должна себя уникально идентифицировать. 
 - Метод ```static var isAuthorized: Bool``` должен вернуть Bool значение, есть ли авторизованный пользователь в данный момент. Данная библиотека рассчитана на работу только с одним авторизованным пользователем. 
 - Метод ```static func authorization(completion: ...)``` должен описать процесс авторизации и в случае провала, вернуть ошибку. 
 - Метод ```static func logout(completion: ...)``` должен удалять локальные данные о текущем пользователя на устройстве.

```SocialNetwork``` расширяет протокол ```Equatable``` и сравнивается через уникальное свойство ```name```. 

Все операции должны наследоваться от абстрактного класса ```SocialOperation```, которая должна контролировать текущее состояние переменной ```private(set) var state```, где в случае успеха должен сохраниться ```private(set) var result```, и если произошла ошибка - ```private(set) var error```. Эти состояния не могут быть установлены на прямую, а должны устанавливаться через методы:

 - ```setSendingState()``` - если операция запустилась и еще в процессе работы 
 - ```setSuccessedState(result: AnyObject?)``` - если операция завершилось с успехом и желательно сохранить результат 
 - ```setFailedState(error: NSError?)``` - если произошла какая-то ошибка.

## ```PostToWallAction``` протокол

В ```SocialActions.swift``` добавляются все возможные действия, которые может делать соц. сеть. К примеру, протокол ```PostToWallAction``` говорит, что соц. сеть поддерживает возможность добавления на стену/ленту пользователя записи, где данные должны поддерживать протокол ```SocialData```. 

Если есть соц. сеть может работать в каком-то из методов с картинками, желательно использовать для этого ```SocialImage```. В ней мы сохраняем картинку и блок с сериализацией для её отправки. 

# **FACEBOOK**

**Пошаговая инструкция для подключения:**

 1. Для подключения facebook необходимо добавить [podspecs](https://cocoapods.org)

    ```
    #facebook SDK 
    pod 'Facebook-iOS-SDK', '~> 3.23.0'
    ```
    
 2. [Создать новое приложение на Facebook](https://developers.facebook.com/apps/)
 3. В ```Setting``` -> ```Basic``` добавить нужный ```Contact Email```,  затем в вкладке ```iOS Bundle ID``` добавить для staging и production.
 4. Настраиваем приложение как описано в [документации](https://developers.facebook.com/docs/ios/getting-started/) и для [iOS9](https://developers.facebook.com/docs/ios/ios9)
 5. В ```Roles``` добавляем администраторов и разработчиков

**НАСТРОЙКА LOGIN PERMISSIONS:**

 - Если вы хотите воспользоваться ```protocol PostToWallAction```, то вам нужно иметь подтвержденный ```publish_actions```(неподтвержденный будет работать только для пользователей, присутствующих в ```Roles```). [Инструкция](https://developers.facebook.com/docs/facebook-login/permissions/v2.4#permission-publish_actions).

**ДОСТУП ПРИЛОЖЕНИЯ ДЛЯ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ:**

```Status & Review``` -> ```Status``` -> Напротив иконки с вашим приложением переключаем switcher в ```ON```. **Для остальных пользователей будут доступны только подтвержденные permissions!**

# **TWITTER**

**Пошаговая инструкция для подключения через Fabric:**

1. Скачать настольное приложение [Fabric для Mac OS](https://fabric.io/downloads/xcode), если оно еще не установлено.
2. [Создать новую организацию](https://fabric.io/settings/organizations) в вашем Fabric аккаунте
3. Добавить через настольное приложение в вашу новую организацию приложение. Для этого нажмите ```+ New App``` -> выберите ваш проект -> выберите вашу новую организацию -> напротив Twitter нажмите Install и следуйте инструкциям по интеграции Fabric, если еще не установлена. Для Twitter нужно выбрать опцию ```Embedded Tweets```.
4. В https://fabric.io/dashboard настроить Twitter приложение.
5. Приглашаем необходимых админов

**Пошаговая инструкция для подключения через Twitter.com:**

1. Для подключения twitter необходимо подключить [podspecs](https://cocoapods.org)  

    ```
    #twitter SDK
    pod 'TwitterKit'
    pod 'TwitterCore'
    pod 'twitter-text'
    ```
2. Заходим на https://apps.twitter.com и нажимаем ```Create New App```. Вводим ```Name```, ```Description```, ```Website``` и ```Callback URL``` обязательно. Если не знаете, что можно добавить для ```Website``` и ```Callback URL```, то просто вставьте http://www.placeholder.com. Теперь создаем приложение.
2. В вкладке ```Permissions``` проверяем, чтобы ```Access``` был ```Read and Write```
3. Из вкладки ```Application Settings``` копируем ```Consumer Key (API Key)``` и ```Consumer Secret (API Secret)```
4. Настраиваем приложение, как описано в [документации](https://docs.fabric.io/ios/twitter/twitterkit-setup.html) и [iOS9](https://dev.twitter.com/mopub/ios/ios9)
        
**ДОСТУП ПРИЛОЖЕНИЯ ДЛЯ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ:**

Это приложение уже доступно для всех пользователей.

# **VK**

**Пошаговая инструкция для подключения:**

1. Для подключения vk необходимо подключить [podspecs](https://cocoapods.org) 

    ```
    #vk SDK
    pod 'VK-ios-sdk'
    ```
    
2. Заходим на https://vk.com/dev и нажимаем ```Мои приложения``` -> ```Создать приложение```. Выбираем ```Standalone-приложение``` и пишем необходимое ```Название```. Нажимаем ```Подключить приложение```.
3. Переходим в вкладку ```Настройки``` и добавляем ```App Bundle ID для iOS``` и сохраняем. Можно добавить только один bundle, поэтому *нужно* использовать сразу с App Store bundli ID.
4. Настроить приложение, как описано в [документации](https://github.com/VKCOM/vk-ios-sdk)
5. Переходим в вкладку ```Руководство``` и добавляем администраторов
    

**ДОСТУП ПРИЛОЖЕНИЯ ДЛЯ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ:** 

```Настройки``` -> ```Состояние``` и выбираем из списка ```Приложение включено и видно всем```
