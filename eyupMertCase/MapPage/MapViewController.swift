//
//  ViewController.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: - Variables
    private let mapView = MKMapView()
    var viewModel: MapVMProtocol!
    
    private let trackingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Konumu Takip Et", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rotayı Sıfırla", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let centerMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - LifeCycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(UIApplication.willEnterForegroundNotification)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        
        setupMapView()
        setupButtons()
        
        trackingButton.addTarget(self, action: #selector(didTapTrackingButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        centerMapButton.addTarget(self, action: #selector(didTapCenterMapButton), for: .touchUpInside)
    }
    
    // MARK: - Functions
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupButtons() {
        let stackView = UIStackView(arrangedSubviews: [resetButton, trackingButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        
        view.addSubview(centerMapButton)
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            centerMapButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            centerMapButton.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func didTapTrackingButton() {
        viewModel.startTracking()
    }
    
    @objc private func didTapResetButton() {
        
    }
    
    @objc private func didTapCenterMapButton() {
        mapView.userTrackingMode = .follow
    }
    
    @objc func appWillEnterForeground() {
        viewModel.startTracking()
    }
    
    
    private func drawRouteBetweenCoordinates() {
        let sourceCoordinate = CLLocationCoordinate2D(latitude: 41.09826186843273, longitude: 28.984044094927143)
        let destinationCoordinate = CLLocationCoordinate2D(latitude: 41.11040168728024, longitude: 29.02485892762797)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                print("Rota bulunamadı: \(error?.localizedDescription ?? "bilinmeyen hata")")
                return
            }
            
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                           edgePadding: UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20),
                                           animated: true)
        }
    }
 
    
    // MARK: - MKMapViewDelegate
  
    func showAlert(on viewController: UIViewController) {
        let alert = UIAlertController(title: "Attention",
                                      message: "Our app needs your permission to work properly",
                                      preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension MapViewController: MapViewDelegate {
    func handleOutput(_ output: MapVMOutput) {
        
        switch output {
        case .trackingStarted(let location):
            mapView.showsUserLocation = true
            
            if let userLocation = mapView.userLocation.location {
                let region = MKCoordinateRegion(center: userLocation.coordinate,
                                                latitudinalMeters: 300,
                                                longitudinalMeters: 300)
                mapView.setRegion(region, animated: true)
            }
            
        case .anyError(let string):
            print("anyError \(string)")
        case .selectedAddress(let _):
            print("selectedAddress")
        case .locationServicesDisabled:
            print("locationServicesDisabled")
        case .trackingStopped:
            print("trackingStopped")
        case .routeReset:
            print("routeReset")
        case .navigateToAppSettings:
            showAlert(on: self)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated animated: Bool) {
        mapView.userTrackingMode = .none
    }
}


extension MapViewController {
    func navigateToAppSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
    }
}
