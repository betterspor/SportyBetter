import SwiftUI

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "backColor")
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView, at: 0)
    }
    
    
    func openApp() {
        DispatchQueue.main.async {
            let view = MainView()
            let hostingController = UIHostingController(rootView: view)
            self.setRootViewController(hostingController)
        }
    }
    
    func openPrivacyPolicy(stringURL: String) {
        DispatchQueue.main.async {
            let webView = PrivacyPolicyViewController(url: stringURL)
            self.setRootViewController(webView)
        }
    }
    
    func setRootViewController(_ viewController: UIViewController) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController = viewController
        }
    }
}
