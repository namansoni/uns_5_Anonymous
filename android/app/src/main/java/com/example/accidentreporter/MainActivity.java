package com.example.accidentreporter;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.mlkit.vision.common.InputImage;
import com.google.mlkit.vision.label.ImageLabel;
import com.google.mlkit.vision.label.ImageLabeler;
import com.google.mlkit.vision.label.ImageLabeling;
import com.google.mlkit.vision.label.automl.AutoMLImageLabelerLocalModel;
import com.google.mlkit.vision.label.automl.AutoMLImageLabelerOptions;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Locale;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    public String userId = "";
    static MainActivity instance;

    public static MainActivity getInstance() {
        return instance;
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        instance = this;

    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "Model")
                .setMethodCallHandler(((call, result) -> {
                    if (call.method.equals("startModel")) {
                        System.out.println("Model started");
                        String imagePath = call.argument("imagePath");
                        System.out.println(imagePath);
                        AutoMLImageLabelerLocalModel localModel =
                                new AutoMLImageLabelerLocalModel.Builder()
                                        .setAssetFilePath("models/manifest.json")
                                        // or .setAbsoluteFilePath(absolute file path to manifest file)
                                        .build();
                        AutoMLImageLabelerOptions autoMLImageLabelerOptions =
                                new AutoMLImageLabelerOptions.Builder(localModel)
                                        .setConfidenceThreshold(0.0f)  // Evaluate your model in the Firebase console
                                        // to determine an appropriate value.
                                        .build();
                        ImageLabeler labeler = ImageLabeling.getClient(autoMLImageLabelerOptions);
                        System.out.println("Model started");
                        InputImage image;
                        try {
                            image = InputImage.fromFilePath(this, Uri.fromFile(new File(imagePath)));
                            labeler.process(image)
                                    .addOnSuccessListener(new OnSuccessListener<List<ImageLabel>>() {
                                        @Override
                                        public void onSuccess(List<ImageLabel> labels) {
                                            // Task completed successfully
                                            // ...
                                            System.out.println("Sucessfull");
                                            System.out.println(labels.get(0).getText());
                                            System.out.println(labels.get(0).getConfidence());
                                            result.success(labels.get(0).getText());
                                        }
                                    })
                                    .addOnFailureListener(new OnFailureListener() {
                                        @Override
                                        public void onFailure(@NonNull Exception e) {
                                            // Task failed with an exception
                                            // ...
                                        }
                                    });
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }

                    if (call.method.equals("startLocation")) {
                        userId = call.argument("uid").toString();
                        System.out.println(userId);

                        Intent intent = new Intent(this, MyLocationForegroundService.class);
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent);
                        } else {
                            startService(intent);
                        }
                    }
                    if (call.method.equals("getpincode")) {
                        FusedLocationProviderClient fusedLocationProviderClient;
                        fusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(this);
                        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                            // TODO: Consider calling
                            //    ActivityCompat#requestPermissions
                            // here to request the missing permissions, and then overriding
                            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                            //                                          int[] grantResults)
                            // to handle the case where the user grants the permission. See the documentation
                            // for ActivityCompat#requestPermissions for more details.
                            return;
                        }
                        fusedLocationProviderClient.getLastLocation().addOnSuccessListener(new OnSuccessListener<Location>() {
                            @Override
                            public void onSuccess(Location location) {
                                Geocoder geocoder;
                                geocoder=new Geocoder(getApplicationContext(), Locale.getDefault());
                                List<Address> addresses;
                                try {
                                    addresses=geocoder.getFromLocation(location.getLatitude(), location.getLongitude(),1);
                                    System.out.println(addresses.get(0).getPostalCode());
                                    result.success(addresses.get(0).getPostalCode());
                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            }
                        });
                    }
                }));
    }
}
