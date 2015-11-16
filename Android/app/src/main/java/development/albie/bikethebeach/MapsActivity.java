package development.albie.bikethebeach;

import android.support.v4.app.FragmentActivity;
import android.os.Bundle;
import android.widget.TextView;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

import java.util.ArrayList;

public class MapsActivity extends FragmentActivity implements OnMapReadyCallback, DataFetchable{

    private GoogleMap mMap;
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
    public void fetchRoutesFinish(ArrayList<Route> routes){
        TextView tv = (TextView) findViewById(R.id.mainTv);

        if(routes==null || routes.size() ==0){
            tv.setText("Error in downloaded Route data.");
            return;
        }
        String data = "";
        for(int i =0; i< routes.get(0).getCoords().size();i++){
            data += routes.get(0).getCoords().get(i).getLat()+", "+routes.get(0).getCoords().get(i).getLongi()+"\n";
        }
        tv.setText(data);
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
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;

        LatLng sydney = new LatLng(39.71056240000001, -75.12029530000001);
        mMap.addMarker(new MarkerOptions().position(sydney).title("Marker in Rowan"));
        mMap.moveCamera(CameraUpdateFactory.newLatLng(sydney));
        mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(sydney.latitude, sydney.longitude), 15.0f));
    }

}
