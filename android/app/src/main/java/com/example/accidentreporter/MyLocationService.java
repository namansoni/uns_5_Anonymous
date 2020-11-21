package com.example.accidentreporter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;

import com.google.android.gms.location.LocationResult;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.SetOptions;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

public class MyLocationService extends BroadcastReceiver {
    public static final String ACTION_PROCESS_UPDATE="com.example.dorona.UPDATE_LOCATION";
    @Override
    public void onReceive(Context context, Intent intent) {
        if(intent!=null){

            final String action=intent.getAction();
            String userId=MainActivity.getInstance().userId;
            System.out.println(userId);
            System.out.println(action);
            if(ACTION_PROCESS_UPDATE.equals(action)){
                System.out.println("MYLOCATIONSERVICE CALL HUA HAI");
                LocationResult result=LocationResult.extractResult(intent);
                System.out.println(result);
                if(result!=null){
                    System.out.println(result.getLastLocation().getLatitude());
                    Location location=result.getLastLocation();
                    Map<String,Object> locationData=new HashMap<>();
                    locationData.put("latitude", location.getLatitude());
                    locationData.put("longitude", location.getLongitude());
                    locationData.put("altitude", location.getAltitude());
                    locationData.put("timestamp",System.currentTimeMillis());
                    Geocoder geocoder;
                    geocoder=new Geocoder(context.getApplicationContext(), Locale.getDefault());
                    List<Address> addresses;
                    try {
                        addresses=geocoder.getFromLocation(location.getLatitude(), location.getLongitude(),1);
                        System.out.println(addresses.get(0).getLocality());
                        System.out.println(addresses.get(0).getPostalCode());
                        if(addresses.size()>0 && addresses.get(0).getAdminArea()!=null
                                && addresses.get(0).getSubAdminArea()!=null && addresses.get(0).getPostalCode()!=null){
                            SharedPreferences sharedPreferences=context.getSharedPreferences("Location",Context.MODE_PRIVATE);
                            SharedPreferences.Editor editor=sharedPreferences.edit();
                            String pincode=sharedPreferences.getString("pincode","");
                            if(pincode==""){
                                editor.putString("pincode",addresses.get(0).getPostalCode());
                                editor.putString("latitude",String.valueOf(location.getLatitude()));
                                editor.putString("longitude",String.valueOf(location.getLongitude()));
                                editor.putString("adminArea",addresses.get(0).getAdminArea());
                                editor.putString("subAdminArea",addresses.get(0).getSubAdminArea());
                                editor.commit();
                                Map<String,Object> address=new HashMap<>();
                                address.put("adminArea",addresses.get(0).getAdminArea());
                                address.put("subAdminArea",addresses.get(0).getSubAdminArea());
                                address.put("pincode",addresses.get(0).getPostalCode());
                                FirebaseFirestore.getInstance()
                                        .collection("Users")
                                        .document(userId)
                                        .set(address, SetOptions.merge());
                            }
                            if(pincode!="" && !pincode.equals(addresses.get(0).getPostalCode())){
                                String adminArea=sharedPreferences.getString("adminArea","");
                                String subAdminArea=sharedPreferences.getString("subAdminArea","");
                                if(adminArea!="" && subAdminArea!="" && pincode!=""){
                                    Map<String,Object> address=new HashMap<>();
                                    address.put("adminArea",addresses.get(0).getAdminArea());
                                    address.put("subAdminArea",addresses.get(0).getSubAdminArea());
                                    address.put("pincode",addresses.get(0).getPostalCode());
                                    FirebaseFirestore.getInstance()
                                            .collection("Users")
                                            .document(userId)
                                            .set(address, SetOptions.merge());
                                    FirebaseFirestore.getInstance()
                                            .collection("Locations")
                                            .document(adminArea)
                                            .collection(adminArea)
                                            .document(subAdminArea)
                                            .collection(subAdminArea)
                                            .document(pincode)
                                            .collection(pincode)
                                            .document(userId)
                                            .delete()
                                            .addOnSuccessListener(new OnSuccessListener<Void>() {
                                                @Override
                                                public void onSuccess(Void aVoid) {
                                                    editor.putString("pincode",addresses.get(0).getPostalCode());
                                                    editor.putString("latitude",String.valueOf(location.getLatitude()));
                                                    editor.putString("longitude",String.valueOf(location.getLongitude()));
                                                    editor.putString("adminArea",addresses.get(0).getAdminArea());
                                                    editor.putString("subAdminArea",addresses.get(0).getSubAdminArea());
                                                    editor.commit();
                                                }
                                            });
                                }
                            }
                            FirebaseFirestore db=FirebaseFirestore.getInstance();
                            db.collection("Locations").document(addresses.get(0).getAdminArea())
                                    .collection(addresses.get(0).getAdminArea())
                                    .document(addresses.get(0).getSubAdminArea())
                                    .collection(addresses.get(0).getSubAdminArea())
                                    .document(addresses.get(0).getPostalCode())
                                    .collection(addresses.get(0).getPostalCode())
                                    .document(userId)
                                    .set(locationData).addOnSuccessListener(new OnSuccessListener<Void>() {
                                @Override
                                public void onSuccess(Void aVoid) {
                                    System.out.println("Successfully location updated");
//                                    NotificationCompat.Builder builder=new NotificationCompat.Builder(context,"123456")
//                                            .setContentTitle("Location Updated")
//                                            .setSmallIcon(R.mipmap.ic_launcher)
//                                            .setColor(Color.rgb(128,131,224))
//                                            .setCategory(NotificationCompat.CATEGORY_MESSAGE)
//                                            .setStyle(new NotificationCompat.BigTextStyle()
//                                                    .bigText("Latitude:"+location.getLatitude()+" Longitude:"+location.getLongitude()+
//                                                            '\n'+addresses.get(0).getPostalCode()))
//                                            .setPriority(NotificationCompat.PRIORITY_HIGH);
//                                    if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.O){
//                                        NotificationChannel channel=new NotificationChannel("123456","123456", NotificationManager.IMPORTANCE_HIGH);
//                                        NotificationManager notificationManager= (NotificationManager) getSystemService(context,NotificationManager.class);
//                                        notificationManager.createNotificationChannel(channel);
//                                    }
//                                    NotificationManagerCompat notificationManagerCompat=NotificationManagerCompat.from(context);
//                                    notificationManagerCompat.notify(123,builder.build());
                                }
                            });
                        }


                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }
}
