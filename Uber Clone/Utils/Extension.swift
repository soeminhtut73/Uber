import UIKit
import MapKit

//MARK: - UIColor Extension
extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static var backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static var mainBlueTint = UIColor.rgb(red: 17, green: 154, blue: 237)
}

//MARK: - UIView Extension
extension UIView {
    
    func inputContainerView(image: String, textField: UITextField? = nil, accountTypeControl: UISegmentedControl? = nil) -> UIView {
        let view = UIView()
        
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.image = UIImage(imageLiteralResourceName: image)
        imageView.alpha = 0.8
        
        if let textField = textField {
            imageView.centerY(inView: view)
            imageView.anchor(left: view.leftAnchor, paddingLeft: 10, width: 26, height: 26)
            
            view.addSubview(textField)
            textField.centerY(inView: view)
            textField.anchor(left: imageView.rightAnchor, right: view.rightAnchor, paddingLeft: 6, paddingRight: 6, height: 26)
        }
        
        if let accountTypeControl = accountTypeControl {
            
            imageView.anchor(top: view.topAnchor, left: view.leftAnchor,paddingTop: -5, paddingLeft: 8, width: 24, height: 24)
            
            view.addSubview(accountTypeControl)
            accountTypeControl.centerX(inView: view)
            accountTypeControl.anchor(top: imageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10)
        }
        
        let separatorView = UIView()
        view.addSubview(separatorView)
        separatorView.backgroundColor = .lightGray
        separatorView.anchor(left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, paddingLeft: 10, paddingRight: 10,paddingBottom: 5, height: 0.75)
        
        return view
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingRight: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
    }
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView,
                 left: NSLayoutXAxisAnchor? = nil,
                 paddingLeft:CGFloat = 0,
                 constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
    }
    
    func dimension(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
    }
    
}

//MARK: - UITextField Extension
extension UITextField {
    
    func textField(withPlaceholder placeholder: String, isSecureTextEntry: Bool) -> UITextField {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.borderStyle = .none
        textField.isSecureTextEntry = isSecureTextEntry
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return textField
        
    }
}

//MARK: - Mapkit Extionsion
extension MKPlacemark {
    var address: String {
        get {
            guard let subThoroughfare = subThoroughfare else { return "" }
            guard let thoroughfare = thoroughfare else { return "" }
            guard let locality = locality else { return "" }
            guard let administrativeArea = administrativeArea else { return "" }
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(administrativeArea)"
        }
    }
}

extension MKMapView {
    /*
     -  create MKMapRect
     -  create MKMapPoint
     -  create MKMapRect
     -  union on zoomRect
     -  add on UIEdgeInset
     -  setVisible MapRect
     */
    func zoomToFit(annotations: [MKAnnotation]) {
        guard annotations.count > 0 else { return }
        
        var zoomRect = MKMapRect.null
        
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0, height: 0)
            zoomRect = zoomRect.union(pointRect)
        }
        
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 350, right: 100), animated: true)
    }
    
    /*
     -  add annotation for placemark coordinate
     -  selectAnnotation
     */
    func addAnnotationAndSelect(forCoordinate coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        addAnnotation(annotation)
        selectAnnotation(annotation, animated: true)
    }
}

extension UIViewController {
    func presentAlertController(withTitle title: String, withMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let loadingView = UIView()
            loadingView.backgroundColor = .black
            loadingView.frame = view.bounds
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = UIActivityIndicatorView.Style.medium
            indicator.color = .white
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.alpha = 0.8
            
            view.addSubview(loadingView)
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            
            label.centerX(inView: view)
            label.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
                indicator.startAnimating()
            }
        } else {
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }

                }
            }
        }
    }
}
