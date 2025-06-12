//
//  ViewController.swift
//  eyupMertCase
//
//  Created by Eyüp Mert on 11.06.2025.
//

import UIKit
import MapKit

final class MapViewController: UIViewController {
    
    // MARK: - Properties
    
    private let mapView = MKMapView()
    var viewModel: MapVMProtocol!
    var currentLocation: CLLocationCoordinate2D?
    private var shouldFollowUser = true
    private var isFirstAppearance = true
    private var isProgrammaticRegionChange = false
    
    private lazy var trackingButton: UIButton = makeButton(title: Constants.startTrackingTitle, backgroundColor: .systemBlue)
    private lazy var resetButton: UIButton = makeButton(title: Constants.resetButtonTitle, backgroundColor: .systemRed)
    private lazy var centerMapButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "location.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.isHidden = true
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        mapView.delegate = self
        
        setupMapView()
        setupButtons()
        addObservers()
        showStoredAnnotations()
        
        updateTrackingButton(isTracking: false)
        updateResetButton()
    }
    
    // MARK: - Setup
    
    private func addObservers() {
        trackingButton.addTarget(self, action: #selector(didTapTrackingButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
        centerMapButton.addTarget(self, action: #selector(didTapCenterMapButton), for: .touchUpInside)
    }
    
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
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(centerMapButton)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            centerMapButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            centerMapButton.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -16),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func makeButton(title: String?, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func showStoredAnnotations() {
        let storedPoints = viewModel.loadStoredLocations()
        for point in storedPoints {
            let coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            let annotation = CustomAnnotation(coordinate: coordinate)
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapTrackingButton() {
        viewModel.startTracking()
    }
    
    @objc private func didTapResetButton() {
        viewModel.clearVisitPoints()
    }
    
    @objc private func didTapCenterMapButton() {
        guard let userLocation = currentLocation else {
            print("Konum henüz alınmadı")
            return
        }
        
        shouldFollowUser = true
        updateRegion(userLocation)
    }
    
    // MARK: - UI Updates
    
    private func showAlertToOpenSettings() {
        let alert = UIAlertController(title: Constants.alertTitle,
                                      message: Constants.alertMessage,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Constants.alertGoToSettings, style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        })
        
        alert.addAction(UIAlertAction(title: Constants.alertCancel, style: .cancel))
        present(alert, animated: true)
    }
    
    private func updateRegion(_ coordinate: CLLocationCoordinate2D) {
        isProgrammaticRegionChange = true
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(region, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isProgrammaticRegionChange = false
        }
    }
    
    private func updateTrackingButton(isTracking: Bool) {
        trackingButton.setTitle(isTracking ? Constants.stopTrackingTitle : Constants.startTrackingTitle, for: .normal)
        trackingButton.backgroundColor = isTracking ? .systemBlue : .systemGreen
    }
    
    private func updateResetButton() {
        let hasStoredPoints = !viewModel.loadStoredLocations().isEmpty
        resetButton.isEnabled = hasStoredPoints
        resetButton.backgroundColor = hasStoredPoints ? .systemRed : .systemGray
    }
    
    private func updateCenterMapButton() {
        DispatchQueue.main.async {
            self.centerMapButton.isHidden = false
        }
    }
}

// MARK: - MapViewDelegate

extension MapViewController: MapViewDelegate {
    func handleOutput(_ output: MapVMOutput) {
        switch output {
        case .trackingStarted(let location):
            handleTrackingStarted(location)
        case .anyError(let message):
            handleError(message)
        case .selectedAddress(let address, let coordinate):
            updateAnnotationTitle(address, at: coordinate)
        case .routeReset:
            handleRouteReset()
        case .navigateToAppSettings:
            showAlertToOpenSettings()
        case .trackingStatusChanged(let isTracking):
            updateTrackingButtonAppearance(isTracking)
            if isTracking {
                updateCenterMapButton()
            }
        }
    }
    
    func handleTrackingStarted(_ location: CLLocationCoordinate2D) {
        currentLocation = location
        let annotation = CustomAnnotation(coordinate: location)
        mapView.addAnnotation(annotation)
        updateResetButton()
        
        if shouldFollowUser {
            updateRegion(location)
        }
    }
    
    func handleError(_ message: String) {
        print("Error: \(message)")
    }
    
    func updateAnnotationTitle(_ title: String, at coordinate: CLLocationCoordinate2D) {
        if let annotation = mapView.annotations
            .compactMap({ $0 as? CustomAnnotation })
            .first(where: { $0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude }) {
            
            annotation.title = title
            mapView.removeAnnotation(annotation)
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func handleRouteReset() {
        let annotationsToRemove = mapView.annotations.compactMap { $0 as? CustomAnnotation }
        mapView.removeAnnotations(annotationsToRemove)
        updateResetButton()
    }
    
    private func updateTrackingButtonAppearance(_ isTracking: Bool) {
        DispatchQueue.main.async {
            self.updateTrackingButton(isTracking: isTracking)
        }
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if isFirstAppearance {
            isFirstAppearance = false
            return
        }
        
        if !isProgrammaticRegionChange {
            shouldFollowUser = false
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let coordinate = view.annotation?.coordinate else { return }
        viewModel.fetchAdress(coordinate)
    }
}
