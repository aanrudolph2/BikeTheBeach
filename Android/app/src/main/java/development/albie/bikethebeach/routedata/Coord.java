package development.albie.bikethebeach.routedata;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by Albert on 11/13/2015.
 */
public class Coord implements Parcelable{

    private double lat;
    private double longi;

    public Coord(double lat, double longi){
        this.lat = lat;
        this.longi = longi;
    }

    protected Coord(Parcel in) {
        lat   = in.readDouble();
        longi = in.readDouble();
    }

    public double getLat(){
        return lat;
    }

    public double getLongi(){
        return longi;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeDouble(lat);
        dest.writeDouble(longi);
    }

    public static final Creator<Coord> CREATOR = new Creator<Coord>() {
        @Override
        public Coord createFromParcel(Parcel in) {
            return new Coord(in);
        }

        @Override
        public Coord[] newArray(int size) {
            return new Coord[size];
        }
    };
}
