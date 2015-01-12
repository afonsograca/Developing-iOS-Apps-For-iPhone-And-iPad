//
//  Photo+Annotation.swift
//  Photomania Map
//
//  Created by Afonso Graça on 25/11/14.
//  Copyright (c) 2014 Afonso Graça. All rights reserved.
//

import Foundation
import MapKit

extension Photo : MKAnnotation { //Annotation
	
	var coordinate : CLLocationCoordinate2D {
		get { return CLLocationCoordinate2D(latitude: self.latitude.doubleValue, longitude: self.longitude.doubleValue) }
	}
}