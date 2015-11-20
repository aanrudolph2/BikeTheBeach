package development.albie.bikethebeach.routedata;

import java.util.ArrayList;

import development.albie.bikethebeach.routedata.Coord;

/**
 * Created by Albert on 11/13/2015.
 */
public class Route {

    private ArrayList<Coord> points;
    private int number;

    public Route( ArrayList<Coord> points, int number){
        this.points = points;
        this.number = number;
    }

    public ArrayList<Coord> getCoords(){
        return points;
    }

    public int getNum(){
        return number;
    }
}
