package com.example.accidentreporter;

import android.net.Uri;

import androidx.annotation.NonNull;

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

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),"Model")
                .setMethodCallHandler(((call, result) -> {
                    if(call.method.equals("startModel")){
                        System.out.println("Model started");
                        String imagePath=call.argument("imagePath");
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
                }));
    }
}
