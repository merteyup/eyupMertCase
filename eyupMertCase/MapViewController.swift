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
    private let viewModel = MapViewModel()
    
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
    
    // MARK: - Statements
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
        viewModel.toggleTracking()
    }
    
    @objc private func didTapResetButton() {
        viewModel.resetRoute()
    }
    
    @objc private func didTapCenterMapButton() {
        viewModel.centerMap()
    }
}

extension MapViewController: MapViewModelDelegate {
    func handleOutput(_ output: MapViewModelOutput) {
        switch output {
        case .trackingStarted:
            print("Tracking started")
        case .trackingStopped:
            print("Tracking stopped")
        case .routeReset:
            print("Route reset")
        case .centerMap:
            print("Center Map Tapped")
        }
    }
}
