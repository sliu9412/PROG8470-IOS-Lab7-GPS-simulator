# PROG8470-IOS-Lab7-GPS-simulator

Lab7 UIKit project of PROG8470 IOS development of Conestoga College. This SPA project use MapKit api and MKMapView to simulate location and other info.

## MKMapView

Import MKMapViewDelegate and CLLocationManagerDelegate and implement.

![](doc/images/2023-07-14-18-12-15-image.png)

Bind property with the MKMapView of the viewController

![](doc/images/2023-07-14-18-10-48-image.png)

Set the delegate, accuracy, and related authorization in the viewWillAppear hook.

![](doc/images/2023-07-14-18-16-33-image.png)

The implement delegate will import the locationManager function, this is the place to update location and related info continuously.

![](doc/images/2023-07-14-18-19-19-image.png)

## Running Screenshot

![](doc/images/2023-07-14-18-24-50-image.png)

![](doc/images/2023-07-14-18-24-06-image.png)
