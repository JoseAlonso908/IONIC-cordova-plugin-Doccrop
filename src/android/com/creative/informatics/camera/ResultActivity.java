package com.creative.informatics.camera;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.os.Bundle;
import android.os.Environment;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by K on 9/29/2017.
 */

public class ResultActivity extends Activity {

    private Bitmap mResultBmp;
    private Bitmap mFinalBmp;
    private ImageView imgView;
    private Button rotateButton;
    private Button finishButton;
    private File pictureFile;
    private final String TAG = "ResultActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getResources().getIdentifier("result_view", "layout", getPackageName()));

        imgView = findViewById(getResources().getIdentifier("resultview", "id", getPackageName()));
        String path = getIntent().getStringExtra("resultpath");
        mResultBmp = BitmapFactory.decodeFile(path);
        imgView.setImageBitmap(mResultBmp);
        mFinalBmp = mResultBmp;

        rotateButton = findViewById(getResources().getIdentifier("rotate", "id", getPackageName()));

        rotateButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mFinalBmp = RotateBitmap(mResultBmp,90);
                imgView.setImageBitmap(mFinalBmp);
                mResultBmp = mFinalBmp;
            }
        });

        finishButton = findViewById(getResources().getIdentifier("finish", "id", getPackageName()));

        finishButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //String result = BitmapToString(mFinalBmp);
                storeImage(mFinalBmp);

                String result = pictureFile.getAbsolutePath();

                JSONObject obj = new JSONObject();
                try {
                    obj.put("data", result);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                Config.request.results.put(obj);
                Config.pendingRequests.resolveWithSuccess(Config.request);

                finish();
            }
        });

    }

    public static Bitmap RotateBitmap(Bitmap source, float angle)
    {
        Matrix matrix = new Matrix();
        matrix.postRotate(angle);
        return Bitmap.createBitmap(source, 0, 0, source.getWidth(), source.getHeight(), matrix, true);
    }


    public static String BitmapToString(Bitmap bitmap) {
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);
            byte[] b = baos.toByteArray();
            String temp = Base64.encodeToString(b, Base64.DEFAULT);
            return temp;
        } catch (NullPointerException e) {
            return null;
        } catch (OutOfMemoryError e) {
            return null;
        }
    }

    private void storeImage(Bitmap image) {
        pictureFile = getOutputMediaFile();
        if (pictureFile == null) {
            Log.d(TAG,
                    "Error creating media file, check storage permissions: ");// e.getMessage());
            return;
        }
        try {
            FileOutputStream fos = new FileOutputStream(pictureFile);
            image.compress(Bitmap.CompressFormat.PNG, 90, fos);
            fos.close();
        } catch (FileNotFoundException e) {
            Log.d(TAG, "File not found: " + e.getMessage());
        } catch (IOException e) {
            Log.d(TAG, "Error accessing file: " + e.getMessage());
        }
    }

    private File getOutputMediaFile(){
        File mediaStorageDir = new File(Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES), "CameraScan");

        if (! mediaStorageDir.exists()){
            if (! mediaStorageDir.mkdirs()){
                return null;
            }
        }

        String timeStamp = new SimpleDateFormat("ddMMyyyy_HHmm").format(new Date());
        File mediaFile;
        String mImageName="Result_"+ timeStamp +".jpg";
        mediaFile = new File(mediaStorageDir.getPath() + File.separator + mImageName);
        return mediaFile;
    }
}
