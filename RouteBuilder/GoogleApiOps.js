	var apiKey = 'AIzaSyBUyIV-JfLai3CEzPCOIRmWrfZU8-c4hm4';

	var map;					// Stores Google Map object
	var snappedPolyline;		// Stores Polyline object
	var markers = [];			// Array of Google Marker Objects

	MAX_VERTS_PER_PAGE = 100;

	function initializeMapAPI()
	{
		var mapOptions =
		{
			zoom: 17,
			center: {lat: 41.143353, lng: -73.236580},
			streetViewControl : false,
			mapTypeControl : false,
			styles : [{featureType : "poi", elementType : "labels", stylers : [{visibility : "off"}]}]
		};
		map = new google.maps.Map(document.getElementById('map'), mapOptions);
		
		map.addListener('click', addMarker);
		snappedPolyline = new google.maps.Polyline({strokeColor: 'blue', strokeWeight: 5, map : map, strokeOpacity : 0.5});
		snappedPolyline.addListener('click', insertMarker);
	}

	function getRouteObject(routeName)
	{
		var coordsOutput = {};
		coordsOutput[routeName] = new Array();
		var coords = snappedPolyline.getPath()['j'];

		for(var i = 0; i < coords.length; i ++)
		{
			coordsOutput[routeName].push([coords[i].lat(), coords[i].lng()])
		}
		return coordsOutput;
	}

	// Call Snap To Road API
	function runSnapToRoad(startIndex, coords)
	{
		var pathValues = new Array();

		// Load next Vertices
		var tmp = markers.slice(startIndex, startIndex + MAX_VERTS_PER_PAGE);
		for (var i = 0; i < tmp.length; i ++)
		{
			pathValues.push(markers[i + startIndex].position.lat() + "," + markers[i + startIndex].position.lng());
		}

		if(pathValues.length > 0)
		{
			$.get('https://roads.googleapis.com/v1/snapToRoads',
			{
				interpolate: true,
				key: apiKey,
				path: pathValues.join('|')
			},
			function(data)
			{
				for (var i = 0; i < data.snappedPoints.length; i ++)
				{
					var latlng = new google.maps.LatLng(
						data.snappedPoints[i].location.latitude,
						data.snappedPoints[i].location.longitude
					);
					
					if(data.snappedPoints[i].originalIndex)
					{
						markers[data.snappedPoints[i].originalIndex + startIndex].setPosition(latlng);
					}
					coords.push(latlng);
				}

				runSnapToRoad(startIndex + MAX_VERTS_PER_PAGE, coords);
			});
		}
		else
		{
			snappedPolyline.setPath(coords);
		}
	}
	
	// Drag Marker
	function dragMarker(event)
	{
		runSnapToRoad(0, []);
	}

	// Remove Marker
	function removeMarker(event)
	{
		var idx = markers.indexOf(this);
		var removed = markers.splice(idx, 1);
		removed[0].setMap(null);
		runSnapToRoad(0, []);
	}

	// Add marker
	function addMarker(event)
	{
		var markerTmp = new google.maps.Marker({position : event.latLng, map : map, draggable : true});

		markerTmp.addListener('dragend', dragMarker);
		markerTmp.addListener('click', removeMarker);

		markers.push(markerTmp);

		runSnapToRoad(0, []);
	}
	
	// Add Midpoint Marker
	function insertMarker(event)
	{
		var distances = [];
		// Convenience Declaration
		var dist = google.maps.geometry.spherical.computeDistanceBetween;
		for(var i = 0; i < markers.length - 1; i ++)
		{
			distances.push(
			{
				index : i,
				value : dist(event.latLng, markers[i].getPosition()) + dist(event.latLng, markers[i + 1].getPosition())
			});
		}
		// Determine where in the array to place the new marker
		distances.sort(function(a, b){return a.value - b.value});
		
		// Add the new marker
		var markerTmp = new google.maps.Marker({position : event.latLng, map : map, draggable : true});
		markerTmp.addListener('dragend', dragMarker);
		markerTmp.addListener('click', removeMarker);
		markers.splice(distances[0].index + 1, 0, markerTmp);
		runSnapToRoad(0, []);
	}