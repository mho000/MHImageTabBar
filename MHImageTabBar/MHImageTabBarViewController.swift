
import UIKit

struct MainViewController {
    let storyboardName: String
    let imageName: String
    let selectedImageName: String
    
    init(storyboardName: String, imageName: String, selectedImageName: String) {
        
        self.storyboardName = storyboardName
        self.imageName = imageName
        self.selectedImageName = selectedImageName
    }
    
    init(storyboardName: String, imageName: String) {
        
        self.init(storyboardName: storyboardName, imageName: imageName, selectedImageName: imageName)
    }
}

class MHImageTabBarViewController: UIViewController {
    
    let viewControllers: [UIViewController]
    private let imageViews: [UIImageView]
    private var tabBarVisibleConstant = CGFloat(0)
    private var tabBarHiddenConstant: CGFloat!
    
    @IBOutlet var tabBar: UIView!
    @IBOutlet var tabBarSeparator: UIView!
    @IBOutlet var tabBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tabBarBottomConstraint: NSLayoutConstraint!
    
    var selectedViewControllerIndex: Int = 0 {
        didSet {
            imageViews[oldValue].tintColor = nil
            imageViews[oldValue].backgroundColor = MHImageTabBarConstants.tabBarBackgroundColor
            imageViews[oldValue].image = UIImage(named: MHImageTabBarConstants.mainViewControllers[selectedViewControllerIndex].imageName)?.withRenderingMode(.alwaysTemplate)
            imageViews[selectedViewControllerIndex].tintColor = MHImageTabBarConstants.tabBarSelectedItemColor
            imageViews[selectedViewControllerIndex].backgroundColor = MHImageTabBarConstants.tabBarSelectedBackgroundColor
            imageViews[selectedViewControllerIndex].image = UIImage(named: MHImageTabBarConstants.mainViewControllers[selectedViewControllerIndex].selectedImageName)?.withRenderingMode(.alwaysTemplate)
            
            switchToViewController(toVC: viewControllers[selectedViewControllerIndex])
        }
    }
    
    var selectedViewController: UIViewController!
    
    required init?(coder aDecoder: NSCoder) {
        
        var vcs = [UIViewController]()
        var ivs = [UIImageView]()
        let bundle = Bundle.main
        for (i, mvc) in MHImageTabBarConstants.mainViewControllers.enumerated() {
            
            vcs.append(UIStoryboard(name: mvc.storyboardName, bundle: bundle).instantiateInitialViewController()!)
            
            let iv = UIImageView(frame: .zero)
            iv.contentMode = .center
            iv.tag = i
            iv.image = UIImage(named: mvc.imageName)?.withRenderingMode(.alwaysTemplate)
            iv.translatesAutoresizingMaskIntoConstraints = false
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
        tabBar.tintAdjustmentMode = .normal
        
        tabBarHiddenConstant = tabBarHeightConstraint.constant
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
            tabBar.alignViews(views: imageViews, firstAttribute: .right, secondAttribute: .left)
        } else {
            tabBar.alignViews(views: imageViews, firstAttribute: .left, secondAttribute: .right)
        }
        
        let firstIV = imageViews.first!
        
        tabBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[firstIV]|", options: [], metrics: nil, views: ["firstIV":firstIV]))
        
        for i in 1 ..< imageViews.count {
            let iv = imageViews[i]
            tabBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[iv]|", options: [], metrics: nil, views: ["iv":iv]))
            tabBar.addConstraint(NSLayoutConstraint(item: iv, attribute: .width, relatedBy: .equal, toItem: firstIV, attribute: .width, multiplier: 1, constant: 0))
        }
    }
    
    func addGestureRecognizers() {
        for iv in imageViews {
            iv.isUserInteractionEnabled = true
            iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MHImageTabBarViewController.gestureRecognizerTapped(tgr:))))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        selectedViewControllerIndex = 0
    }
    
    //MARK: - actions
    
    func switchToViewController(toVC: UIViewController) {
        
        selectedViewController?.removeFromParentViewController()
        selectedViewController?.view.removeFromSuperview()
        selectedViewController?.didMove(toParentViewController: nil)
        
        addChildViewController(toVC)
        addChildView(aView: toVC.view)
        toVC.didMove(toParentViewController: self)
        
        selectedViewController = toVC
    }
    
    func addChildView(aView: UIView) {
        
        aView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(aView)
        let views: [String: UIView] = ["child": aView, "tabBar": tabBar]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[child]|", options: .directionLeftToRight, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[child][tabBar]", options: [], metrics: nil, views: views))
        
        view.layoutIfNeeded()
    }
    
    func gestureRecognizerTapped(tgr: UITapGestureRecognizer) {
        selectedViewControllerIndex = tgr.view!.tag
    }
    
    //MARK: - tab bar hide and show
    
    func setTabBarVisible(visible: Bool, animated: Bool = true) {
        let constant = visible ? tabBarVisibleConstant : tabBarHiddenConstant
        let duration = animated ? MHImageTabBarConstants.tabBarAnimationDuration : 0
        
        UIView.animate(withDuration: duration) {
            [unowned self]
            () -> Void in
            
            self.tabBarBottomConstraint.constant = constant!
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - ui view controller extension for tab bar

extension UIViewController {
    var mhTabBarViewController: MHImageTabBarViewController? {
        var vc = parent
        
        while vc != nil {
            if vc is MHImageTabBarViewController {
                return vc as? MHImageTabBarViewController
            } else {
                vc = vc?.parent
            }
        }
        
        return nil
    }
}
//MARK: - Helper

extension UIView {
    
    func alignViews(views: [UIView], firstAttribute: NSLayoutAttribute, secondAttribute: NSLayoutAttribute) {
        var previousView = views.first!
        addConstraint(NSLayoutConstraint(item: previousView, attribute: firstAttribute, relatedBy: .equal, toItem: self, attribute: firstAttribute, multiplier: 1, constant: 0))
        
        var currentView: UIView
        for i in 1 ..< views.count {
            currentView = views[i]
            addConstraint(NSLayoutConstraint(item: currentView, attribute: firstAttribute, relatedBy: .equal, toItem: previousView, attribute: secondAttribute, multiplier: 1, constant: 0))
            previousView = currentView
        }
        
        addConstraint(NSLayoutConstraint(item: previousView, attribute: secondAttribute, relatedBy: .equal, toItem: self, attribute: secondAttribute, multiplier: 1, constant: 0))
    }
}
