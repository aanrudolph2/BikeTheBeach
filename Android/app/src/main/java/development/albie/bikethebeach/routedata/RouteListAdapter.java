package development.albie.bikethebeach.routedata;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Currency;

import development.albie.bikethebeach.R;
import development.albie.bikethebeach.activities.RouteListActivity;


public class RouteListAdapter extends BaseAdapter {
    private final Context context;
    private ArrayList<Route> routes;
    public RouteListAdapter(Context context, ArrayList<Route> routes) {
        this.context = context;
        this.routes = routes;
    }

    @Override
    public int getCount() {
        return routes.size();
    }

    @Override
    public Object getItem(int pos) {
        return routes.get(pos);
    }

    @Override
    public long getItemId(int pos) {
        return 0l;
        //just return 0 if your list items do not have an Id variable.
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        LayoutInflater inflater = (LayoutInflater) context
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View rowView = inflater.inflate(R.layout.row_route_list, parent, false);

        TextView routeNameTv= (TextView) rowView.findViewById(R.id.routeName);

        ImageView imageView = (ImageView) rowView.findViewById(R.id.icon);

        routeNameTv.setText("Route "+ String.valueOf(position+1));



        return rowView;
    }


} 