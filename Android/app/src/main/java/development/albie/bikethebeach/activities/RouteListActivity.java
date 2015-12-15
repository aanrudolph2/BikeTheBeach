package development.albie.bikethebeach.activities;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.location.Location;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.Toast;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.PolylineOptions;

import java.util.ArrayList;

import development.albie.bikethebeach.R;
import development.albie.bikethebeach.routedata.DataAcquisition;
import development.albie.bikethebeach.routedata.DataFetchable;
import development.albie.bikethebeach.routedata.Route;
import development.albie.bikethebeach.routedata.RouteListAdapter;

/**
 * Created by Albert on 11/23/2015.
 */
public class RouteListActivity extends FragmentActivity implements DataFetchable {

    private Context mContext;
    public ArrayList<Route> routes = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_routes_list);
        mContext = this;
        DataAcquisition da = new DataAcquisition(this);
        da.getRoutes();
    }

    /*
     * Because data fetching is asyncronous, this is the callback function that gets called after calling da.getRoutes();
     */
    public void fetchRoutesFinish(ArrayList<Route> routes)
    {
        if(routes==null || routes.size() == 0)
        {
            System.out.println("Error in downloaded Route data.");
            return;
        }

        this.routes = routes;
        RouteListAdapter adapter = new RouteListAdapter(mContext, routes);
        ListView list = (ListView) findViewById(R.id.routesList);
        list.setAdapter(adapter);
        setListener(list);

    }

    public void setListener(ListView lv){

        //This is where we can create the modal for edit  delete
        lv.setOnItemClickListener(new AdapterView.OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                // Start the CAB using the ActionMode.Callback defined above
                Toast.makeText(mContext, "Loading Route " + String.valueOf(position+1), Toast.LENGTH_SHORT).show();
                RouteListActivity act = (RouteListActivity) mContext;
                act.startPreview(routes.get(position));
                view.setSelected(true);

                //THIS NEEDS TO PASS IN THE APPROPRIATE ROUTE DATA TO THE PREVIEW ACT
            }
        });

    }

    public void startPreview(Route selected_route){
        Intent mapIntent = new Intent(this, MapsActivity.class);
        Bundle route_bundle = new Bundle();
        route_bundle.putParcelable("SELECTED_ROUTE", selected_route);
        mapIntent.putExtras(route_bundle);
        this.startActivity(mapIntent);
    }

}
