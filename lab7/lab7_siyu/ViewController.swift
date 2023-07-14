//
//  ViewController.swift
//  lab7_siyu
//
//  Created by user on 2023-03-08.
//

import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var Map: MKMapView!
    @IBOutlet var CurrentSpeedLabel: UILabel!
    @IBOutlet var MaxSpeedLabel: UILabel!
    @IBOutlet var DistanceLabel: UILabel!
    @IBOutlet var AverageSpeedLabel: UILabel!
    @IBOutlet var MaxAccelerationLabel: UILabel!
    @IBOutlet var OverSpeedBar: UILabel!
    @IBOutlet var DuringTripBar: UILabel!

    @IBAction func StartTripButton(_ sender: UIButton) {
        is_start = true
    }

    @IBAction func StopTripButton(_ sender: UIButton) {
        is_start = false
        trip_state = (
            is_initial: true,
            initial_timestamp: Date(),
            elapsed_time: 0.0,
            sourceLocation: CLLocation(),
            current_speed: 0.00,
            previous_speed: 0.00,
            max_speed: 0.00,
            average_speed: 0.00,
            acceleration: 0.00,
            max_acceleration: 0.00,
            distance: 0.00
        )
        UpdateLabels()
    }

    var LocationManager = CLLocationManager()
    var overspeed = 33.5 // 115.0?
    // updated infomation when calling UpdateMap
    var region = MKCoordinateRegion()
    var span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    var pin = MKPointAnnotation()
    // updated information when calling UpdateState
    let green_color = UIColor(red: 125 / 255, green: 170 / 255, blue: 85 / 255, alpha: 1)
    var trip_state = (
        is_initial: true,
        initial_timestamp: Date(),
        elapsed_time: 0.0,
        sourceLocation: CLLocation(),
        current_speed: 0.00,
        previous_speed: 0.00,
        max_speed: 0.00,
        average_speed: 0.00,
        acceleration: 0.00,
        max_acceleration: 0.00,
        distance: 0.00
    ) {
        willSet {
            if !newValue.is_initial {
                DuringTripBar.backgroundColor = green_color
                if newValue.current_speed > overspeed {
                    OverSpeedBar.backgroundColor = UIColor.red
                } else {
                    OverSpeedBar.backgroundColor = green_color
                }
            } else {
                DuringTripBar.backgroundColor = UIColor.lightGray
                OverSpeedBar.backgroundColor = UIColor.lightGray
            }
        }
    }

    // switch to start or stop trip
    var is_start = false

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil && is_start {
//            manager.startUpdatingLocation()
            let location = locations.first!
            if trip_state.is_initial {
                trip_state.sourceLocation = location
                trip_state.initial_timestamp = location.timestamp
                trip_state.is_initial = false
            }
            UpdateState(location)
            UpdateMap(location.coordinate)
        }
    }

    func UpdateState(_ newLocation: CLLocation) {
        // the total time after start trip
        let total_elapse_time = newLocation.timestamp.timeIntervalSince(trip_state.initial_timestamp)
        // time gap after the previous update
        let time_gap = total_elapse_time - trip_state.elapsed_time
        // after getting time gap, update elapsed time
        trip_state.elapsed_time = total_elapse_time
        // exchange previous speed and current time
        trip_state.previous_speed = trip_state.current_speed
        trip_state.current_speed = newLocation.speed
        // get the max speed
        trip_state.max_speed = max(trip_state.current_speed, trip_state.max_speed)
        // speed gap after the previous update
        let speed_gap = trip_state.current_speed - trip_state.previous_speed
        // if total_elapes_time / time gap is 0, the acceleration will be infinite
        if time_gap != 0 {
            trip_state.acceleration = abs(speed_gap / time_gap)
            trip_state.max_acceleration = max(trip_state.acceleration, trip_state.max_acceleration)
            trip_state.distance = newLocation.distance(from: trip_state.sourceLocation)
            trip_state.average_speed = trip_state.distance / trip_state.elapsed_time
        }
        // set all the labels
        UpdateLabels()
    }

    func UpdateMap(_ newLocation_coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(center: newLocation_coordinate, span: span)
        Map.removeAnnotation(pin)
        pin.coordinate = newLocation_coordinate
        Map.setRegion(region, animated: true)
        Map.addAnnotation(pin)
    }

    private func UpdateLabels() {
        CurrentSpeedLabel.text = String(trip_state.current_speed) + " km/h"
        MaxSpeedLabel.text = String(trip_state.max_speed) + " km/h"
        AverageSpeedLabel.text = String(format: "%.2f", trip_state.average_speed) + " km/h"
        DistanceLabel.text = String(format: "%.2f", trip_state.distance / 1000) + " km"
        MaxAccelerationLabel.text = String(format: "%.2f", trip_state.max_acceleration) + " m/s^2"
    }

    override func viewWillAppear(_ animated: Bool) {
        LocationManager.delegate = self
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest
        LocationManager.requestWhenInUseAuthorization()
        LocationManager.startUpdatingLocation()
    }
}
