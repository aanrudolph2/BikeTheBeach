package development.albie.bikethebeach.routedata;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.ArrayList;

import development.albie.bikethebeach.routedata.Coord;

/**
 * Created by Albert on 11/13/2015.
 */
public class Route implements Parcelable {

    private ArrayList<Coord> points;
    private int number;

    public Route(ArrayList<Coord> points, int number) {
        this.points = points;
        this.number = number;
    }

    protected Route(Parcel in) {
        points = new ArrayList<Coord>();
        in.readTypedList(points, Coord.CREATOR);
        number = in.readInt();
    }

    public ArrayList<Coord> getCoords() {
        return points;
    }

    public int getNum() {
        return number;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeTypedList(points);
        dest.writeInt(number);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    public static final Creator<Route> CREATOR = new Creator<Route>() {
        @Override
        public Route createFromParcel(Parcel in) {
            return new Route(in);
        }

        @Override
        public Route[] newArray(int size) {
            return new Route[size];
        }
    };
}
