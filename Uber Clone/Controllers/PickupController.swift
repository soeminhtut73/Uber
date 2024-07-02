import Foundation
import MapKit

protocol PickupControllerDelegate {
    func didAcceptTrip(trip: Trip)
}

class PickupController: UIViewController {
    
    //MARK: - Properties
    private let mapView = MKMapView()
    
    private var trip: Trip
    
    var delegate: PickupControllerDelegate?
    
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
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Selector
    @objc func handleCancelButton(){
        dismiss(animated: true)
    }
    
    @objc func handleAcceptTripButton() {
        Service.shared.acceptTrip(trip) { error, ref in
            self.delegate?.didAcceptTrip(trip: self.trip)
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
        
        view.addSubview(mapView)
        mapView.dimension(width: 270, height: 270)
        mapView.layer.cornerRadius = 270/2
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -200)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 16)
        
        view.addSubview(acceptTipButton)
        acceptTipButton.centerX(inView: view)
        acceptTipButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingRight: 32, height: 50)
    }
    
}