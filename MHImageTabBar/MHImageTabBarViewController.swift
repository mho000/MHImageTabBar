
import UIKit

struct MainViewController {
    let storyboardName: String
    let imageName: String
}

class MHImageTabBarViewController: UIViewController {
    
    let viewControllers: [UIViewController]
    private let imageViews: [UIImageView]
    
    @IBOutlet var tabBar: UIView!
    @IBOutlet var tabBarSeparator: UIView!
    
    var selectedViewControllerIndex: Int = 0 {
        didSet {
            imageViews[oldValue].tintColor = nil
            imageViews[selectedViewControllerIndex].tintColor = MHImageTabBarConstants.tabBarSelectedItemColor
            
            switchToViewController(viewControllers[selectedViewControllerIndex])
        }
    }
    
    var selectedViewController: UIViewController!
    
    required init(coder aDecoder: NSCoder) {
        
        var vcs = [UIViewController]()
        var ivs = [UIImageView]()
        let bundle = NSBundle.mainBundle()
        for (i, mvc) in enumerate(MHImageTabBarConstants.mainViewControllers) {
            
            vcs.append(UIStoryboard(name: mvc.storyboardName, bundle: bundle).instantiateInitialViewController() as! UIViewController)
            
            let iv = UIImageView(frame: .zeroRect)
            iv.contentMode = .Center
            iv.tag = i
            iv.image = UIImage(named: mvc.imageName)?.imageWithRenderingMode(.AlwaysTemplate)
            iv.setTranslatesAutoresizingMaskIntoConstraints(false)
            ivs.append(iv)
        }
        
        viewControllers = vcs
        imageViews = ivs
        
        super.init(coder: aDecoder)
    }
    
    //MARK: - Setup
    
    func setup() {
        addSubviews()
        setupConstraints()
        addGestureRecognizers()
        
        tabBar.tintColor = MHImageTabBarConstants.tabBarUnselectedItemColor
        tabBar.backgroundColor = MHImageTabBarConstants.tabBarBackgroundColor
        tabBarSeparator.backgroundColor = MHImageTabBarConstants.tabBarSeparatorColor
        tabBar.tintAdjustmentMode = .Normal
    }
    
    func addSubviews() {
        for iv in imageViews {
            tabBar.addSubview(iv)
        }
    }
    
    func setupConstraints() {
        setupImageViewsConstraints()
    }
    
    func setupImageViewsConstraints() {
        if MHImageTabBarConstants.RTL {
            tabBar.alignViews(imageViews, firstAttribute: .Right, secondAttribute: .Left)
        } else {
            tabBar.alignViews(imageViews, firstAttribute: .Left, secondAttribute: .Right)
        }
        
        let firstIV = imageViews.first!
        
        tabBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[firstIV]|", options: nil, metrics: nil, views: ["firstIV":firstIV]))
        
        for i in 1 ..< imageViews.count {
            let iv = imageViews[i]
            tabBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[iv]|", options: nil, metrics: nil, views: ["iv":iv]))
            tabBar.addConstraint(NSLayoutConstraint(item: iv, attribute: .Width, relatedBy: .Equal, toItem: firstIV, attribute: .Width, multiplier: 1, constant: 0))
        }
    }
    
    func addGestureRecognizers() {
        for iv in imageViews {
            iv.userInteractionEnabled = true
            iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("gestureRecognizerTapped:")))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        selectedViewControllerIndex = 0
    }
    
    //MARK: - Actions
    
    func switchToViewController(toVC: UIViewController) {
        
        selectedViewController?.removeFromParentViewController()
        selectedViewController?.view.removeFromSuperview()
        selectedViewController?.didMoveToParentViewController(nil)
        
        addChildViewController(toVC)
        addChildView(toVC.view)
        toVC.didMoveToParentViewController(self)
        
        selectedViewController = toVC
    }
    
    func addChildView(aView: UIView) {
        
        aView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(aView)
        let views = ["child": aView, "tabBar": tabBar]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[child]|", options: .DirectionLeftToRight, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[child][tabBar]", options: nil, metrics: nil, views: views))
        
        view.layoutIfNeeded()
    }
    
    func gestureRecognizerTapped(tgr: UITapGestureRecognizer) {
        selectedViewControllerIndex = tgr.view!.tag
    }
}

//MARK: - Helper

extension UIView {
    
    func alignViews(views: [UIView], firstAttribute: NSLayoutAttribute, secondAttribute: NSLayoutAttribute) {
        var previousView = views.first!
        addConstraint(NSLayoutConstraint(item: previousView, attribute: firstAttribute, relatedBy: .Equal, toItem: self, attribute: firstAttribute, multiplier: 1, constant: 0))
        
        var currentView: UIView
        for i in 1 ..< views.count {
            currentView = views[i]
            addConstraint(NSLayoutConstraint(item: currentView, attribute: firstAttribute, relatedBy: .Equal, toItem: previousView, attribute: secondAttribute, multiplier: 1, constant: 0))
            previousView = currentView
        }
        
        addConstraint(NSLayoutConstraint(item: previousView, attribute: secondAttribute, relatedBy: .Equal, toItem: self, attribute: secondAttribute, multiplier: 1, constant: 0))
    }
}
