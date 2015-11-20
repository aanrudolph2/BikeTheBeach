package development.albie.bikethebeach.routedata;

import android.content.Context;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Created by Albert on 11/16/2015.
 */
public class DataAcquisition{

    private  ArrayList<Route> routes;
    private  DataFetchable mContext;

        public DataAcquisition(DataFetchable mContext){
            this.mContext = mContext;
        }

    /*
     * Returns whether the routes data has be downloaded or not.
     */
    public boolean isDownloaded(){
        if(routes == null || routes.size() != 0){
            return false;
        }else{
            return true;
        }
    }

    /*
     * Begins execution of getting routes
     */
        public  void getRoutes(){
            // Instantiate the RequestQueue.
            RequestQueue queue = Volley.newRequestQueue((Context) mContext);
            routes  = new ArrayList<>();

            String url ="http://rawgit.com/aanrudolph2/BikeTheBeach/master/routes.json";
            //String url ="http://api.geonames.org/citiesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&lang=de&username=demo";

            CustomRequest jsObjRequest = new CustomRequest(Request.Method.GET, url, null,
                    new Response.Listener<JSONObject>() {
                        @Override
                        public void onResponse(JSONObject response) {

                            try{
                                int i = 1;
                                while(response.get("Route "+i)!=null){
                                    JSONArray name = (JSONArray) response.get("Route "+i);

                                    ArrayList<Coord> coords = new ArrayList<>();

                                    for(int j=0;j<name.length();j++){
                                        JSONArray nums   = name.getJSONArray(j);
                                        double lat = nums.getDouble(0);
                                        double longi = nums.getDouble(1);
                                        coords.add(new Coord(lat, longi));
                                    }
                                    routes.add(new Route(coords, i));
                                    i++;
                                }
                            }catch( JSONException e){
                            }

                            System.out.println(routes);
                            System.out.println(response);
                            mContext.fetchRoutesFinish(routes);
                        }
                    }, new Response.ErrorListener() {
                @Override
                public void onErrorResponse(VolleyError error) {
                    System.out.println("errorrr");
                }
            });


            queue.add(jsObjRequest);
        }

}
