import Foundation
import MapKit

protocol PickupControllerDelegate {
    func didAcceptTrip(trip: Trip)
}

class PickupController: UIViewController {
    
    //MARK: - Properties
    
    var delegate: PickupControllerDelegate?
    private let mapView = MKMapView()
    private var trip: Trip
    
    private lazy var circularProgressView: CircularProgressView = {
        let frame = CGRect(x: 0, y: 0, width: 268, height: 268)
        let cp = CircularProgressView(frame: frame)
        
        // configure mapView in circularProgressView
        cp.addSubview(mapView)
        mapView.dimension(width: 265, height: 265)
        mapView.layer.cornerRadius = 268 / 2
        mapView.centerX(inView: cp)
        mapView.centerY(inView: cp, constant: 32)
        
        return cp
    }()
    
    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: FileNames.crossButton), for: .normal)
        btn.addTarget(self, action: #selector(handleCancelButton), for: .touchUpInside)
        return btn
    }()
    
    private let pickupLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pickup this passenger?"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let acceptTipButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("ACCEPT TRIP", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handleAcceptTripButton), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - Lifecycle
    init(trip: Trip) {
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
             
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureMapView()
        
        self.perform(#selector(animateProgress), with: nil, afterDelay: 0.5)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Selector
    @objc func handleCancelButton(){
        dismiss(animated: true)
    }
    
    @objc func handleAcceptTripButton() {
        DriverService.shared.acceptTrip(trip) { error, ref in
            self.delegate?.didAcceptTrip(trip: self.trip)
        }
    }
    
    @objc func animateProgress() {
        circularProgressView.animatePulsatingLayer()
        circularProgressView.setProgressWithAnimation(value: 0, duration:20) {
//            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Helper Function
    /*
        -   create region for view area
        -   init MKPointAnnotation
     */
    private func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.region = region
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = trip.pickupCoordinate
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingLeft: 16)
        
//        view.addSubview(mapView)
//        mapView.dimension(width: 270, height: 270)
//        mapView.layer.cornerRadius = 270/2
//        mapView.centerX(inView: view)
//        mapView.centerY(inView: view, constant: -200)
        
        view.addSubview(circularProgressView)
        circularProgressView.dimension(width: 268, height: 268)
        circularProgressView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        circularProgressView.centerX(inView: view)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: circularProgressView.bottomAnchor, paddingTop: 80)
        
        view.addSubview(acceptTipButton)
        acceptTipButton.centerX(inView: view)
        acceptTipButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
    }
    
}
