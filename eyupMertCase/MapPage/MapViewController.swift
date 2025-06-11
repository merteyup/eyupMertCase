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
    private var isProgrammaticRegionChange = false

    private lazy var trackingButton: UIButton = makeButton(title: Constants.trackingButtonTitle, backgroundColor: .systemBlue)
    private lazy var resetButton: UIButton = makeButton(title: Constants.resetButtonTitle, backgroundColor: .systemRed)
    private lazy var centerMapButton: UIButton = makeButton(title: nil, backgroundColor: .systemRed)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        mapView.delegate = self

        setupMapView()
        setupButtons()

        addObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
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

    // MARK: - Actions
    @objc private func didTapTrackingButton() {
        viewModel.startTracking()
    }

    @objc private func didTapResetButton() {
        // Implement reset logic in viewModel
    }

    @objc private func didTapCenterMapButton() {
        guard let userLocation = currentLocation else {
            print("Konum henüz alınmadı")
            return
        }

        shouldFollowUser = true
        updateRegion(userLocation)
    }

    @objc private func appWillEnterForeground() {
        viewModel.startTracking()
    }

    // MARK: - Helpers

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

        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 300,
                                        longitudinalMeters: 300)
        mapView.setRegion(region, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isProgrammaticRegionChange = false
        }
    }
}

// MARK: - MapViewDelegate
extension MapViewController: MapViewDelegate {
    func handleOutput(_ output: MapVMOutput) {
        switch output {
        case .trackingStarted(let location):
            currentLocation = location
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            annotation.title = "Ziyaret Noktası"
            mapView.addAnnotation(annotation)
            
            if shouldFollowUser {
                updateRegion(location)
            }
            
        case .anyError(let message):
            print("Error: \(message)")
        case .selectedAddress:
            print("selectedAddress")
        case .locationServicesDisabled:
            print("locationServicesDisabled")
        case .trackingStopped:
            print("trackingStopped")
        case .routeReset:
            print("routeReset")
        case .navigateToAppSettings:
            showAlertToOpenSettings()
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if !isProgrammaticRegionChange {
            shouldFollowUser = false
        }
    }
}
