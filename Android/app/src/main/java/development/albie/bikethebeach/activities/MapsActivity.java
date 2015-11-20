package development.albie.bikethebeach.activities;

import android.graphics.Color;
import android.location.Location;
import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
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
        TextView tv = (TextView) findViewById(R.id.mainTv);

        if(routes==null || routes.size() ==0)
        {
            tv.setText("Error in downloaded Route data.");
            return;
        }
        String data = "";
        for(int i =0; i< routes.get(0).getCoords().size();i++){
            data += routes.get(0).getCoords().get(i).getLat()+", "+routes.get(0).getCoords().get(i).getLongi()+"\n";
            //double lat = routes.get(0).getCoords().get(i).getLat();
            //double longi = routes.get(0).getCoords().get(i).getLongi();
            polylines.add(new LatLng(routes.get(0).getCoords().get(i).getLat(),routes.get(0).getCoords().get(i).getLongi()));
            //polylines.add(new LatLng(lat,longi));
            //System.out.println("LAT" + routes.get(0).getCoords().get(i).getLat());
        }
        tv.setText(data);
        createRoute(mMap);
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
        LatLng sydney = new LatLng(39.71056240000001, -75.12029530000001);
        LatLng test = new LatLng(39.7111543617113, -75.12760716460377);
        mMap.addMarker(new MarkerOptions().position(test).title("Marker in Rowan"));
        mMap.moveCamera(CameraUpdateFactory.newLatLng(test));
        mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(test.latitude, test.longitude), 15.0f));
        mMap.setOnMyLocationChangeListener(this);

        //mMap.addPolyline(new PolylineOptions().addAll(polylines).width(15.0f).color(Color.RED));

        //PolylineOptions opts = new PolylineOptions().addAll(polylines).width(5).color(Color.BLUE);
        //mMap.addPolyline(opts);
        //mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(test,39));
        //polylines.add(new LatLng(test.latitude,test.longitude));
        //System.out.println("WTF" + polylines.toString());
    }

    public void createRoute(GoogleMap googleMap)
    {
        mMap = googleMap;
        LatLng test = new LatLng(39.7111543617113, -75.12760716460377);
        System.out.println("POLYLINES" + polylines.toString());
        PolylineOptions opts = new PolylineOptions().addAll(polylines).width(5).color(Color.BLUE);
        mMap.addPolyline(opts);
        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(test, 39));
        mMap.setMyLocationEnabled(true);
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
