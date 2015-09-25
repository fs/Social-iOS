# **Social**

## Зачем это нужно?

В каждом новом проекте нам постоянно приходится подключать необходимые нам SDK, 
копировать из старого проекта/писать тот же код для авторизации или выхода из соц. сети и выполнение необходимых действий. Причем чаще всего это бывает не унифицировано и тяжело интегрируется в другие места проекта. 
Эта библиотека была реализована для решения этих проблем, где нам не приходится думать, как работает конкретная соц. сеть - мы просто оперируем всеми, как одной. 

## Как это работает?

Для создания соц. сети мы должны реализовать протокол ```SocialNetwork```. 

 - Методом ```static func name() -> String``` соц. сеть должна себя уникально идентифицировать. 
 - Метод ```static func isAuthorized() -> Bool``` должен вернуть Bool значение, есть ли авторизованный пользователь в данный момент. Данная библиотека рассчитана на работу только с одним авторизованным пользователем. 
 - Метод ```static func authorization(completion: ((success: Bool, error: NSError?) -> Void)?)``` должен описать процесс авторизации и в случае провала, вернуть ошибку. 
 - Метод ```static func logout()``` должен удалять локальные данные о текущем пользователя на устройстве.

```SocialNetwork``` расширяет протокол ```Equatable``` и сравнивается через уникальное имя ```static func name() -> String```. 

Все операции должны наследоваться от абстрактного класса ```SocialOperation```, которая должна контролировать текущее состояние переменной ```private(set) var state```, где в случае успеха должен сохраниться ```private(set) var result```, и если произошла ошибка - ```private(set) var error```. Эти состояния не могут быть установлены на прямую, а должны устанавливаться через методы:

 - ```internal final func setSendingState()``` - если операция запустилась и еще в процессе работы 
 - ```internal final func setSuccessedState(result: AnyObject?)``` - если операция завершилось с успехом и желательно сохранить результат 
 - ```internal final func setFailedState(error: NSError?)``` - если произошла какая-то ошибка.

В ```SocialActions.swift``` добавляются все возможные действия, которые может делать соц. сеть. К примеру, протокол ```PostToWallAction``` говорит, что соц. сеть поддерживает возможность добавления на стену/ленту пользователя записи, где данные должны поддерживать протокол ```SocialData```. 

Если есть соц. сеть может работать в каком-то из методов с картинками, желательно использовать для этого ```SocialImage```. В ней мы сохраняем картинку и блок с сериализацией для её отправки. 

# **FACEBOOK**

**Пошаговая инструкция для подключения:**

 1. Для подключения facebook необходимо добавить [framework](https://developers.facebook.com/docs/ios) или подключить [podspecs](https://cocoapods.org)

    ```
    #facebook SDK 
    pod 'Facebook-iOS-SDK', '~> 3.23.0'
    ```
 2. [Создать новое приложение на Facebook](https://developers.facebook.com/apps/)
 3. В ```Setting``` -> ```Basic``` добавить нужный ```Contact Email```,  затем в вкладке ```iOS Bundle ID``` добавить для staging и production.
 4. Скопировать из ```Setting``` -> ```Basic``` значение ```App Id``` и в проекте в info.plist добавить ключ ```FacebookAppID``` с этим значением, создать новую схему с ```identifier``` как ```fb``` и ```URL Schemes``` и вставить в формате ```fbYourFacebookAppID``` (к примеру, ```fb12345678```)
 5. В ```Roles``` приглашаем как ```Administrators``` [Никиту Фомина](https://www.facebook.com/nikita.fomin.96), [Сергея Николаева](https://www.facebook.com/sergei.nikolaev.5) и [Гончарова Владимира](https://www.facebook.com/vladimir1631).

**iOS 9:**

[Для настройки iOS 9](https://developers.facebook.com/docs/ios/ios9)

**Необходимый код:**

 - В AppDelegate добавить следующий код:

    ```
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication) == true {
            return true
        }
        
        return false
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSession.activeSession().handleDidBecomeActive()
    }
    ```

**НАСТРОЙКА LOGIN PERMISSIONS:**

 - Если вы хотите воспользоваться ```protocol PostToWallAction```, то вам нужно иметь подтвержденный ```publish_actions```(неподтвержденный будет работать только для пользователей, присутствующих в ```Roles```). [Инструкция](https://developers.facebook.com/docs/facebook-login/permissions/v2.4#permission-publish_actions).

**ДОСТУП ПРИЛОЖЕНИЯ ДЛЯ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ:**

```Status & Review``` -> ```Status``` -> Напротив иконки с вашим приложением переключаем switcher в ```ON```. **Для остальных пользователей будут доступны только подтвержденные permissions!**

# **TWITTER**

**Пошаговая инструкция для подключения через Fabric:**

1.  Скачать настольное приложение [Fabric для Mac OS](https://fabric.io/downloads/xcode), если оно еще не установлено.
2. [Создать новую организацию](https://fabric.io/settings/organizations) в вашем Fabric аккаунте
3. Добавить через настольное приложение в вашу новую организацию приложение. Для этого нажмите ```+ New App``` -> выберите ваш проект -> выберите вашу новую организацию -> напротив Twitter нажмите Install и следуйте инструкциям по интеграции Fabric, если еще не установлена. Для Twitter нужно выбрать опцию ```Embedded Tweets```.
4. В https://fabric.io/dashboard настроить описание **(пока не сохраняет данные)**.
5. Приглашаем как admin nikita.fomin@flatstack.com, sergey.nikolaev@flatstack.com и vladimir.goncharov@flatstack.com

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
3. Из вкладки ```Application Settings``` копируем ```Consumer Key (API Key)``` и ```Consumer Secret (API Secret)``` и вставляем следуйщий код для инициализации приложения:

    ```
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool     {
        // Override point for customization after application launch.
        
         //setting Twitter
         Twitter.sharedInstance().startWithConsumerKey("YourConsumerKey(ApiKey))", consumerSecret: "YourConsumerSecret(ApiSecret)")

        return true
    }
    ```
    
**ВНИМАНИЕ!** После такого подключения данное приложение должно быть передано Никите Фомину. 

**iOS 9:**

В ```info.plist``` нужно добавить код:

```
<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSExceptionDomains</key>
		<dict>
			<key>twitter.com</key>
			<dict>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
				<key>NSIncludesSubdomains</key>
				<true/>
			</dict>
		</dict>
	</dict>
```

[Более детальная информация](https://dev.twitter.com/mopub/ios/ios9)

**Необходимый код:**

		//setting Fabric
        Fabric.with([Twitter.self()])
        
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
3. Переходим в вкладку ```Настройки``` и добавляем ```App Bundle ID для iOS``` и сохраняем. Можно добавить только один bundle, поэтому *рекомендуется* использовать только для production, а для staging оставить недоступным. Если есть крайняя необходимость иметь оба - тогда нужно добавить в ```AppDelegate```:
    
    ```
    private func vkAppID() -> String {
        #IF STAGING
            return yourStaginAppID
        #ELSE
            return yourProductionAppID
        #ENDIF
    }
    ```
4. Скопировать из ```Настройки``` -> значение ```ID приложения``` и сохранить в проект константой ```kVKAppID = "your API key"``` с этим значением, создать новую схему с ```identifier``` как ```vk``` и ```URL Schemes``` и вставить в формате ```vkYourVKAppID``` (к примеру, ```vk12345678```)
5. Переходим в вкладку ```Руководство``` и добавляем как ```Администратор``` [Никиту Фомина](https://vk.com/ioscto), [Сергея Николаева](https://vk.com/kruperfone) и [Гончарова Владимира](https://vk.com/dfandel)

**iOS 9:**

[Для настройки iOS 9](https://github.com/VKCOM/vk-ios-sdk#configuring-application-for-ios-9)

**Необходимый код:**

Переходим в ```AppDelegate``` и вставляем:

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool     {
        //setting VK
        VKSdk.initializeWithDelegate(self, andAppId: "YourAppID")
        VKSdk.wakeUpSession()
        
        return true
    }


    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if VKSdk.processOpenURL(url, fromApplication: sourceApplication) == true {
            return true
        }
        
        return false
    }

    //MARK: -
    extension AppDelegate : VKSdkDelegate {
        
        func vkSdkReceivedNewToken(newToken: VKAccessToken!) {
            NSNotificationCenter.defaultCenter().postNotificationName(kVKDidUpdateTokenNotification, object: newToken)
        }
        
        func vkSdkRenewedToken(newToken: VKAccessToken!) {
            NSNotificationCenter.defaultCenter().postNotificationName(kVKDidUpdateTokenNotification, object: newToken)
        }
        
        func vkSdkUserDeniedAccess(authorizationError: VKError!) {
            NSNotificationCenter.defaultCenter().postNotificationName(kVKDeniedAccessNotification, object: authorizationError)
        }
        
        func vkSdkTokenHasExpired(expiredToken: VKAccessToken!) {
            NSNotificationCenter.defaultCenter().postNotificationName(kVKHasExperiedTokenNotification, object: expiredToken)
        }
        
        func vkSdkShouldPresentViewController(controller: UIViewController!) {
            self.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        }
        
        func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
            let captchaController        = VKCaptchaViewController.captchaControllerWithError(captchaError)
            self.window?.rootViewController?.presentViewController(captchaController, animated: true, completion: nil)
        }
        
    }

**ДОСТУП ПРИЛОЖЕНИЯ ДЛЯ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ:** 

```Настройки``` -> ```Состояние``` и выбираем из списка ```Приложение включено и видно всем```
