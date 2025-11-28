import UIKit

/// Utility to find the topmost view controller for presenting modals.
enum TopViewControllerFinder {
    
    /// Finds the topmost presented view controller in the app's window hierarchy.
    /// - Returns: The topmost view controller, or nil if none can be found.
    static func find() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            Logger.warning("Could not find active window scene or key window")
            return nil
        }
        
        return findTopViewController(from: window.rootViewController)
    }
    
    /// Recursively finds the topmost view controller starting from a given controller.
    /// - Parameter controller: The starting view controller.
    /// - Returns: The topmost view controller.
    private static func findTopViewController(from controller: UIViewController?) -> UIViewController? {
        guard let controller = controller else { return nil }
        
        // Check for presented view controller first
        if let presented = controller.presentedViewController {
            return findTopViewController(from: presented)
        }
        
        // Handle navigation controllers
        if let navigationController = controller as? UINavigationController {
            return findTopViewController(from: navigationController.visibleViewController)
        }
        
        // Handle tab bar controllers
        if let tabBarController = controller as? UITabBarController {
            return findTopViewController(from: tabBarController.selectedViewController)
        }
        
        // Handle split view controllers
        if let splitViewController = controller as? UISplitViewController {
            return findTopViewController(from: splitViewController.viewControllers.last)
        }
        
        return controller
    }
}

