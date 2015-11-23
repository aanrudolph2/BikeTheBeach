package development.albie.bikethebeach.routedata;

/**
 * Created by Albert on 11/13/2015.
 */
public class Coord {

    private double lat;
    private double longi;

    public Coord(double lat, double longi){
        this.lat = lat;
        this.longi = longi;
    }

    public double getLat(){
        return lat;
    }

    public double getLongi(){
        return longi;
    }
}
