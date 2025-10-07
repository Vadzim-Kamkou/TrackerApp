import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "6ec5a7ab-c5d8-44c2-a644-c738cc1910bf") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: String, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
    
    // MARK: - Analytics Events
    static func trackScreenOpen(screen: String) {
        let params: [AnyHashable: Any] = [
            "event": "open",
            "screen": screen
        ]
        
        let service = AnalyticsService()
        service.report(event: "screen_open", params: params)
        print("Analytics: screen = \"\(screen)\", event = \"open\"")
    }
    
    static func trackScreenClose(screen: String) {
        let params: [AnyHashable: Any] = [
            "event": "close",
            "screen": screen
        ]
        
        let service = AnalyticsService()
        service.report(event: "screen_close", params: params)
        print("Analytics: screen = \"\(screen)\", event = \"close\"")
    }
    
    static func trackClick(screen: String, item: String) {
        let params: [AnyHashable: Any] = [
            "event": "click",
            "screen": screen,
            "item": item
        ]
        
        let service = AnalyticsService()
        service.report(event: "button_click", params: params)
        print("Analytics Track Click: screen = \"\(screen)\", event = \"click\", item = \"\(item)\"")
    }
}
