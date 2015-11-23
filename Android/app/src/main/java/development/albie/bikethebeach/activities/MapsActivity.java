package development.albie.bikethebeach.activities;

import android.graphics.Color;
import android.location.Location;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.PolylineOptions;

import java.util.ArrayList;

import development.albie.bikethebeach.routedata.DataAcquisition;
import development.albie.bikethebeach.routedata.DataFetchable;
import development.albie.bikethebeach.R;
import development.albie.bikethebeach.routedata.Route;

public class MapsActivity extends FragmentActivity implements OnMapReadyCallback, DataFetchable, GoogleMap.OnMyLocationChangeListener
{

    private GoogleMap mMap;
    public ArrayList<LatLng> polylines = new ArrayList<>();

    private int map_prev_padding = 10;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_maps);
        // Obtain the SupportMapFragment and get notified when the map is ready to be used.
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);

        DataAcquisition da = new DataAcquisition(this);
        da.getRoutes();
    }

    /*
     * Because data fetching is asyncronous, this is the callback function that gets called after calling da.getRoutes();
     */
    public void fetchRoutesFinish(ArrayList<Route> routes)
    {
        if(routes==null || routes.size() ==0)
        {
            System.out.println("Error in downloaded Route data.");
            return;
        }

        for(int i =0; i< routes.get(0).getCoords().size();i++){
            //double lat = routes.get(0).getCoords().get(i).getLat();
            //double longi = routes.get(0).getCoords().get(i).getLongi();
            polylines.add(new LatLng(routes.get(0).getCoords().get(i).getLat(),routes.get(0).getCoords().get(i).getLongi()));
            //polylines.add(new LatLng(lat,longi));
            //System.out.println("LAT" + routes.get(0).getCoords().get(i).getLat());
        }

        createRoute(mMap);
        startPreview(mMap, routes);
    }

    /**
     * Manipulates the map once available.
     * This callback is triggered when the map is ready to be used.
     * This is where we can add markers or lines, add listeners or move the camera. In this case,
     * we just add a marker near Sydney, Australia.
     * If Google Play services is not installed on the device, the user will be prompted to install
     * it inside the SupportMapFragment. This method will only be triggered once the user has
     * installed Google Play services and returned to the app.
     */
    @Override
    public void onMapReady(GoogleMap googleMap)
    {
        mMap = googleMap;
    }

    public void createRoute(GoogleMap googleMap)
    {
        mMap = googleMap;
        System.out.println("POLYLINES" + polylines.toString());
        PolylineOptions opts = new PolylineOptions().addAll(polylines).width(5).color(Color.BLUE);
        mMap.addPolyline(opts);
        mMap.setMyLocationEnabled(true);
        mMap.setOnMyLocationChangeListener(this);
    }

    public void startPreview(GoogleMap googleMap, final ArrayList<Route> routes)
    {
        double max_north, max_south;
        double max_east, max_west;
        max_north = max_south = routes.get(0).getCoords().get(0).getLat();
        max_east = max_west = routes.get(0).getCoords().get(0).getLongi();

        double temp_lat  = 0.0;
        double temp_long = 0.0;
        for(int i =0; i< routes.get(0).getCoords().size();i++){
            temp_lat = routes.get(0).getCoords().get(i).getLat();
            if(temp_lat > max_north)
                max_north = temp_lat;
            if(temp_lat < max_south)
                max_south = temp_lat;

            temp_long = routes.get(0).getCoords().get(i).getLongi();
            if(temp_long > max_east)
                max_east = temp_long;
            if(temp_long < max_west)
                max_west = temp_long;
        }

        LatLngBounds map_prev_bounds =
                new LatLngBounds(new LatLng(max_south, max_west), new LatLng(max_north, max_east));

        mMap.moveCamera(CameraUpdateFactory.newLatLngBounds(map_prev_bounds, 10));

        //this isnt working error saying map size cant be zero even though its the value of map prev
        //padding must investigate further
        //System.out.println(map_prev_padding);
        //mMap.moveCamera(CameraUpdateFactory.newLatLngBounds(map_prev_bounds, map_prev_padding));

        final Button button = (Button) findViewById(R.id.start_nav_button);
        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                if (mMap.getMyLocation() != null) {
                    double user_lat = mMap.getMyLocation().getLatitude();
                    double user_long = mMap.getMyLocation().getLongitude();
                    mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(user_lat, user_long), 19));
                } else {
                    mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(routes.get(0).getCoords().get(0).getLat(),
                            routes.get(0).getCoords().get(0).getLongi()), 19));
                }

            }
        });

    }
    @Override
    public void onMyLocationChange(Location location)
    {
        if(!onCourse(location))
        {
            Log.d("Location", "Off Course");
        }
    }

    public boolean onCourse(Location location)
    {
        for(int i = 0; i < polylines.size() - 1; i ++)
        {
            LatLng p1 = polylines.get(i);
            LatLng p2 = polylines.get(i + 1);

            LatLng pos = new LatLng(location.getLatitude(), location.getLongitude());

            if(Math.abs((p2.longitude - p1.longitude) * pos.longitude + (p1.latitude - p2.latitude) * pos.latitude
            + (p1.longitude - p2.longitude) * p1.latitude + (p2.latitude - p1.latitude) * p1.longitude) /
                    Math.sqrt(Math.pow(p2.longitude - p1.longitude, 2) + Math.pow(p2.latitude - p1.latitude, 2)) < 0.00002f)
            {
                return true;
            }
        }
        return false;
    }
}
