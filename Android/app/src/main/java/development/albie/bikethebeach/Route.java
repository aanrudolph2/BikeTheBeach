package development.albie.bikethebeach;

import java.util.ArrayList;

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
