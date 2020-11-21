package com.example.accidentreporter;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Build;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;

public class MyLocationForegroundService extends Service {
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        System.out.println("foreground service started");
        Intent intent1 = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, intent, 0);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "147")
                .setContentTitle("Location Tracker")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setColor(Color.rgb(128, 131, 224))
                .setCategory(NotificationCompat.CATEGORY_MESSAGE)
                .setLargeIcon(BitmapFactory.decodeResource(this.getResources(),R.mipmap.ic_light))
                .setStyle(new NotificationCompat.BigTextStyle()
                        .bigText("Tracks you continuosly to keep you safe"))
                .setPriority(NotificationCompat.PRIORITY_HIGH);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel("147", "963", NotificationManager.IMPORTANCE_HIGH);
            NotificationManager notificationManager = (NotificationManager) getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
        NotificationManagerCompat notificationManagerCompat = NotificationManagerCompat.from(this);
        startForeground(1, builder.build());
        FusedLocationProviderClient fusedLocationProviderClient;
        fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(this);
        try{
            LocationRequest locationRequest=new LocationRequest();
            locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY)
                    .setInterval(5000)
                    .setFastestInterval(3000)
                    .setSmallestDisplacement(10f);
            Intent intent2=new Intent(this,MyLocationService.class);
            intent2.setAction(MyLocationService.ACTION_PROCESS_UPDATE);
            PendingIntent pendingIntent1=PendingIntent.getBroadcast(this,862,intent2,0);
            fusedLocationProviderClient.requestLocationUpdates(locationRequest,pendingIntent1);
        }catch (SecurityException ex){

        }

        return START_STICKY;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
    @Override
    public void onDestroy() {
        stopForeground(true);
        stopSelf();
        super.onDestroy();
    }
}
